import json
import os
from dataclasses import dataclass

_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATA_ROOT = os.path.join(_PROJECT_ROOT, "data")
ARC_ROOT = os.path.join(DATA_ROOT, "arc-agi-v2")
PL_ROOT = os.path.join(_PROJECT_ROOT, "src", "pl")
SOL_ROOT = os.path.join(DATA_ROOT, "solutions")
RULESETS_ROOT = os.path.join(DATA_ROOT, "rulesets")
TRACKER_ROOT = os.path.join(DATA_ROOT, "tracker")


@dataclass(frozen=True)
class Config:
    ruleset: str = "default"
    max_vars: int = 6
    max_body: int = 6
    timeout: int = 60
    nruns: int = 1
    popper_quiet: bool = True
    popper_memory: bool = False
    reject_last: bool = False


@dataclass(frozen=True)
class RunPaths:
    root: str
    bk: str
    exs: str
    bias: str
    test: str
    program: str
    scores: str


def run_paths(task_id: str, cfg: Config) -> RunPaths:
    """Build RunPaths for a task, deriving the output folder name from config parameters."""
    ruleset_name = (
        os.path.splitext(os.path.basename(cfg.ruleset))[0]
        if cfg.ruleset != "default"
        else "default"
    )
    root = os.path.join(
        SOL_ROOT, task_id, f"{ruleset_name}_{cfg.max_vars}_{cfg.max_body}_{cfg.timeout}"
    )
    return RunPaths(
        root=root,
        bk=os.path.join(root, "bk.pl"),
        exs=os.path.join(root, "exs.pl"),
        bias=os.path.join(root, "bias.pl"),
        test=os.path.join(root, "test.pl"),
        program=os.path.join(root, f"{task_id}.pl"),
        scores=os.path.join(root, f"{task_id}_scores.txt"),
    )


def read_task(task_id: str, training: bool = True) -> dict:
    """Load an ARC task JSON from the training or evaluation set."""
    path = os.path.join(ARC_ROOT, "training" if training else "evaluation", f"{task_id}.json")
    with open(path) as f:
        return json.load(f)


def grid_shape(grid: list[list[int]]) -> tuple[int, int]:
    return len(grid), len(grid[0])
