import os
import signal
import threading
import warnings
import traceback
from multiprocessing import Process, Queue
from queue import Empty
from typing import Any

from config import (
    Config,
    RunPaths,
    grid_shape,
    read_task,
)
from prolog import write_files

warnings.filterwarnings("ignore")


def output_map(test_data: list[dict]) -> dict:
    """Build sample -> row -> col -> color lookup from ARC test grids."""
    result = {}
    for sid, pair in enumerate(test_data):
        grid = pair["output"]
        nr, nc = grid_shape(grid)
        rows = {}
        for r in range(nr):
            cols = {}
            for c in range(nc):
                cols[c] = grid[r][c]
            rows[r] = cols
        result[sid] = rows
    return result


def _worker(fn, args, queue, hard_timeout=0):
    """Run fn(*args) in a new process group, with a hard os._exit kill timer."""
    os.setsid()
    if hard_timeout:
        t = threading.Timer(hard_timeout, os._exit, args=(1,))
        t.daemon = True
        t.start()
    queue.put(fn(*args))


def run_isolated(fn, args, timeout) -> Any | None:
    """Run fn(*args) in an isolated process group. Returns result or None on timeout."""
    queue: Queue = Queue()
    proc = Process(target=_worker, args=(fn, args, queue, timeout))
    proc.start()
    proc.join(timeout=timeout)
    if proc.is_alive():
        try:
            if proc.pid is not None:
                os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except OSError:
            pass
        proc.join(timeout=5)
        return None
    try:
        return queue.get_nowait()
    except Empty:
        return None


def _learn(task_id: str, paths: RunPaths, cfg: Config) -> str | None:
    """Invoke Popper to learn a program; writes program and scores to disk on success."""
    from popper.util import Settings, order_prog, format_rule
    from popper.loop import learn_solution

    settings = Settings(
        cmd_line=False,
        quiet=cfg.popper_quiet,
        kbpath=paths.root,
        timeout=cfg.timeout,
        use_memory=cfg.popper_memory,
        reject_last=cfg.reject_last,
    )
    try:
        program, score, _ = learn_solution(settings)
    except Exception as e:
        print(e)
        traceback.print_exc()
        return None
    if not program:
        return None

    text = "\n".join(format_rule(settings.order_rule(r)) for r in order_prog(program)) + "\n"
    tp, fn, tn, fp, size = score
    write_files(
        {
            paths.program: text,
            paths.scores: f"tp:{tp} fn:{fn} tn:{tn} fp:{fp} size:{size}",
        }
    )
    return text


def learn_program(task_id: str, paths: RunPaths, cfg: Config) -> str | None:
    """Run Popper learning in an isolated process."""
    print("Learning program")
    return run_isolated(_learn, (task_id, paths, cfg), timeout=cfg.timeout + 20)


def _validate(test_file: str, expected: dict) -> bool:
    """Consult a Prolog file via janus and query each cell against expected output."""
    from janus_swi import consult, query_once, janus

    consult(test_file)
    for sid, rows in expected.items():
        for rid, cols in rows.items():
            for cid, color in cols.items():
                try:
                    r = query_once(f"out_state({sid},{rid},{cid},Color)")
                    if r is None or r.get("Color") != color:
                        return False
                except janus.PrologError:
                    return False
    return True


def test_program(task_id: str, paths: RunPaths) -> bool | None:
    """Validate learned program against ARC test cases."""
    print("Testing learned solution")
    if not os.path.exists(paths.program):
        return None

    with open(paths.program) as f:
        program = f.read()
    with open(paths.test) as f:
        facts = f.read()

    test_file = os.path.join(paths.root, "test_program.pl")
    write_files({test_file: ":- style_check(-singleton).\n" + facts + program})

    expected = output_map(read_task(task_id)["test"])
    result = run_isolated(_validate, (test_file, expected), timeout=60)

    if os.path.exists(test_file):
        os.remove(test_file)
    return result
