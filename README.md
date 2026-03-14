# arc-ilp

An Inductive Logic Programming approach to solving [ARC-AGI-2](https://arcprize.org/) tasks. Uses [Popper](https://github.com/logic-and-learning-lab/Popper/) to learn Prolog programs that transform input grids into output grids.

## How it works

Each ARC task consists of input/output grid pairs (training examples) and a test input. The pipeline:

1. **Build** — Converts grids into Prolog predicates and grounds background knowledge using SWI-Prolog
2. **Learn** — Runs Popper (ILP) to induce a logic program from the training examples
3. **Test** — Validates the learned program against the held-out test grid

Its main utility is that you can provide a file with a set of predicates you'd like to use as background knowledge in the learning process. Here's an example of a valid rule:

```
adj(Example, R, C, NR, C) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, C, _),
    NR is R + 1.
```

It states that for an `Example`, the cell with coordinates `(NR, C)` is adjacent to the `(R, C)` cell. The primary thing to note is the comment after the head definition for `adj/4`. `ex, row_id, col_id, row_id, col_id` specify the types for the variables and is used in the body predicate and type declarations for Popper. A default set of background predicates is provided in `data/rulesets/default.txt`. 

The thing to remember when constructing background predicates is that the input and output grid for the examples in a given task are formalised as `in_state/4` and `out_state/4` respectively. They both have `Example`, `Row`, `Column`, and `Color` as variables. The facts for cell colors are also provided.

## Prerequisites

- Python 3.12+
- [SWI-Prolog](https://www.swi-prolog.org/Download.html) (`brew install swi-prolog` on macOS)
- [uv](https://docs.astral.sh/uv/) (recommended) or pip

## Setup

```bash
git clone https://github.com/oghenejokpeme/arc-ilp.git
cd arc-ilp
uv sync
```

This installs all dependencies including the bundled Popper fork. The fork adds search state persistence (memory) to upstream Popper, allowing the learner to save and restore its hypothesis search state between runs. This is useful for long running tasks and multiple retries. It might take 20+ minutes to find a solution for some tasks, and due to Popper's non-determinism, it might not find a solution that's correct on the test grid on one run but might on another. So in the case when it doesn't, it's useful to reduce the search space using what was learned in unsuccessful runs in subsequent ones.

The [ARC-AGI-2](https://github.com/arcprize/ARC-AGI-2) training and evaluation tasks are bundled in `data/arc-agi-v2/`. Popper currently learns a solution that passes on the test case with the provided `default` background predicate set on [these tasks](data/solvable.txt) in under 60 seconds with `max-var` and `max-body` set to 6 (more details on input parameters below).

## Usage

Run from the `src/` directory:

```bash
cd src
uv run main.py <task-id> [options]
```

### Arguments

| Argument | Default | Description |
|---|---|---|
| `task` | *(required)* | ARC task ID (e.g. `0d3d703e`) |
| `--ruleset` | `default` | Ruleset name or path to a custom ruleset file |
| `--max-vars` | `6` | Max variables in learned rules |
| `--max-body` | `6` | Max body literals per rule |
| `--timeout` | `60` | Popper timeout in seconds |
| `--nruns` | `1` | Number of learning attempts |
| `--no-quiet` | off | Show Popper output |
| `--memory` | off | Persist Popper search state between runs |
| `--reject-last` | off | Reject previous solution on first run. Only useful if memory has been used in a prior run |

### Examples

Solve a task with defaults:

```bash
uv run main.py 0d3d703e
```

```
Run - 0:
Generating task-specific predicates
Learning program
out_state(V0,V1,V2,V3):- blue(V3),run_length_v(V0,V1,V2,V5,V4),gray(V5).
out_state(V0,V1,V2,V3):- pink(V3),run_length_v(V0,V1,V2,V5,V4),red(V5).
out_state(V0,V1,V2,V3):- maroon(V3),run_length_v(V0,V1,V2,V5,V4),aqua(V5).
out_state(V0,V1,V2,V3):- yellow(V3),run_length_v(V0,V1,V2,V5,V4),green(V5).
out_state(V0,V1,V2,V3):- gray(V3),run_length_v(V0,V1,V2,V5,V4),blue(V5).
out_state(V0,V1,V2,V3):- aqua(V3),yellow(V5),nearest_color_right(V0,V1,V2,V5,V4).
out_state(V0,V1,V2,V3):- red(V3),run_length_v(V0,V1,V2,V5,V4),pink(V5).

Testing learned solution
Correct solution: 0d3d703e? True (1.7s)
```

Solve a task with a custom ruleset (see `data/rulesets/default.txt` for the full format):

```bash
uv run main.py 0d3d703e --ruleset ../data/rulesets/simple.txt
```

```
0d3d703e

Run - 0:
Generating task-specific predicates
Learning program
out_state(V0,V1,V2,V3):- blue(V3),in_state(V0,V1,V2,V4),gray(V4).
out_state(V0,V1,V2,V3):- aqua(V3),yellow(V5),nearest_color_right(V0,V1,V2,V5,V4).
out_state(V0,V1,V2,V3):- green(V3),yellow(V4),run_length_v(V0,V1,V2,V4,V5).
out_state(V0,V1,V2,V3):- gray(V3),blue(V4),in_state(V0,V1,V2,V4).
out_state(V0,V1,V2,V3):- red(V3),pink(V4),nearest_color_right(V0,V1,V5,V4,V2).
out_state(V0,V1,V2,V3):- yellow(V3),green(V4),run_length_v(V0,V1,V2,V4,V5).
out_state(V0,V1,V2,V3):- pink(V3),red(V4),in_state(V0,V1,V2,V4).
out_state(V0,V1,V2,V3):- maroon(V3),in_state(V0,V1,V2,V4),aqua(V4).

Testing learned solution
Correct solution: 0d3d703e? True (0.7s)
```

Explore a larger search space with Popper:

```bash
uv run main.py 0d3d703e --max-vars 8 --max-body 8 --timeout 120
```

Retry up to 3 times, rejecting failed solutions:

```bash
uv run main.py 0d3d703e --nruns 3
```

## Output

Results are written to `data/solutions/{task_id}/{ruleset}_{max_vars}_{max_body}_{timeout}/`:

- `bk.pl` — Grounded background knowledge
- `exs.pl` — Positive and negative examples
- `bias.pl` — Search bias constraints
- `{task_id}.pl` — Learned program (if found)
- `{task_id}_scores.txt` — Accuracy metrics
