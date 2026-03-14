import argparse
import time
from dataclasses import replace

from config import Config, run_paths
from prolog import setup_universal, build_task
from solve import learn_program, test_program


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="ARC-ILP solver")
    p.add_argument("task", help="task ID to run")
    p.add_argument("--ruleset", type=str, default="default", help="ruleset name or path to file")
    p.add_argument("--max-vars", type=int, default=6)
    p.add_argument("--max-body", type=int, default=6)
    p.add_argument("--timeout", type=int, default=60)
    p.add_argument("--nruns", type=int, default=1)
    p.add_argument("--reject-last", action="store_true", help="reject last solution from the start")
    p.add_argument("--no-quiet", action="store_true", help="disable Popper quiet mode")
    p.add_argument("--memory", action="store_true", help="enable Popper memory")
    return p.parse_args()


def run_once(task_id: str, cfg: Config) -> bool:
    """Single build -> learn -> test attempt."""
    paths = run_paths(task_id, cfg)
    build_task(task_id, paths)
    t0 = time.monotonic()
    program = learn_program(task_id, paths, cfg)
    elapsed = time.monotonic() - t0
    print(program)
    if program is None:
        print(f"No solution found ({elapsed:.1f}s)")
        print("-" * 150 + "\n")
        return False
    result = test_program(task_id, paths)
    print(f"Correct solution: {task_id}? {result} ({elapsed:.1f}s)")
    print("-" * 150 + "\n")
    return bool(result)


def find_solution(task_id: str, cfg: Config) -> bool:
    """Try up to cfg.nruns attempts."""
    print(f"{task_id}\n")
    for run in range(cfg.nruns):
        print(f"Run - {run}:")
        run_cfg = replace(cfg, reject_last=True) if run > 0 else cfg
        if run_once(task_id, run_cfg):
            return True
    return False


def main():
    args = parse_args()
    cfg = Config(
        ruleset=args.ruleset,
        max_vars=args.max_vars,
        max_body=args.max_body,
        timeout=args.timeout,
        nruns=args.nruns,
        reject_last=args.reject_last,
        popper_quiet=not args.no_quiet,
        popper_memory=args.memory or args.nruns > 1,
    )

    print(f"Generating universal predicates. Ruleset: {cfg.ruleset}\n")
    setup_universal(cfg.ruleset, cfg.max_vars, cfg.max_body)
    find_solution(args.task, cfg)


if __name__ == "__main__":
    main()
