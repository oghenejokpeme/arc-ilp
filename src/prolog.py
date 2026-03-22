import os
import shutil
import subprocess

from config import PL_ROOT, RULESETS_ROOT, RunPaths, grid_shape, read_task

COLORS_10 = set(range(10))

COLOR_NAMES = [
    "black",
    "blue",
    "red",
    "green",
    "yellow",
    "gray",
    "pink",
    "orange",
    "aqua",
    "maroon",
]

BASE_GROUND_PREDS = ["in_state/4"]
for _c in COLOR_NAMES:
    BASE_GROUND_PREDS.append(f"{_c}/1")

FIXED_BIAS = (
    "head_pred(out_state, 4).\n"
    "type(out_state, (ex, row_id, col_id, color)).\n\n"
    "body_pred(in_state, 4).\n"
    "type(in_state, (ex, row_id, col_id, color)).\n\n"
)

COLORS_BIAS = (
    "".join(f"body_pred({c}, 1).\n" for c in COLOR_NAMES)
    + "\n"
    + "".join(f"type({c}, (color,)).\n" for c in COLOR_NAMES)
    + "\n"
)

CONSTRAINTS = (
    "%% BECAUSE WE DO NOT LEARN FROM INTERPRETATIONS\n"
    ":-\n"
    "    clause(C),\n"
    "    #count{V : var_type(C,V,ex)} != 1.\n\n"
)


def cells_to_predicates(grid_pairs: list[dict]) -> list[dict]:
    """ARC grid pairs -> [{"bk": [str], "exs": {"pos": [str], "neg": [str]}}]."""
    result = []
    for pair_id, pair in enumerate(grid_pairs):
        input_grid, output_grid = pair["input"], pair["output"]
        input_rows, input_cols = grid_shape(input_grid)
        output_rows, output_cols = grid_shape(output_grid)

        bk = []
        for row in range(input_rows):
            for col in range(input_cols):
                bk.append(f"in_state({pair_id},{row},{col},{input_grid[row][col]}).")

        pos = []
        neg = []
        for row in range(output_rows):
            for col in range(output_cols):
                actual_color = output_grid[row][col]
                pos.append(f"pos(out_state({pair_id},{row},{col},{actual_color})).")
                for color in COLORS_10:
                    if color != actual_color:
                        neg.append(f"neg(out_state({pair_id},{row},{col},{color})).")

        result.append({"bk": bk, "exs": {"pos": pos, "neg": neg}})
    return result


def format_exs(predicates: list[dict]) -> str:
    """Flatten predicate dicts into exs.pl content."""
    pos = []
    for p in predicates:
        for e in p["exs"]["pos"]:
            pos.append(e)
    neg = []
    for p in predicates:
        for e in p["exs"]["neg"]:
            neg.append(e)
    return "\n".join(pos + neg) + "\n"


def format_test_pl(exs: list[str], grounded: list[str]) -> str:
    """Combine sorted test examples and grounded BK into test.pl content."""
    exs_sorted = sorted(exs)
    return "\n".join(exs_sorted) + "\n\n" + "".join(grounded)


def parse_ruleset(ruleset_path: str) -> tuple[list[str], list[str], list[str]]:
    """Parse a ruleset file -> (grounding_terms, body_pred_facts, type_facts)."""
    terms, body_preds, type_facts = [], [], []
    seen = set()
    with open(ruleset_path) as f:
        for line in f:
            if line.startswith(":-") or ":- %" not in line:
                continue
            head_def, var_types = line.split(":- %")
            pred = head_def.split("(")[0]
            var_types = var_types.strip()
            arity = len(var_types.split(","))

            # Simple ruleset variables and types check
            # Ensure the number of variables equal the type declarations
            try:
                assert len(head_def.split(",")) == len(var_types.split(","))
            except AssertionError:
                msg = f"Variables and type definitions don't match in ruleset: {head_def}"
                raise Exception(msg)
            if arity == 1:
                var_types = var_types + ","
                
            term = f"{pred}/{arity}"
            body = f"body_pred({pred}, {arity})."
            type_fact = f"type({pred}, ({var_types}))."

            if term not in seen:
                terms.append(term)
                seen.add(term)
            if body not in seen:
                body_preds.append(body)
                seen.add(body)
            if type_fact not in seen:
                type_facts.append(type_fact)
                seen.add(type_fact)
    return terms, body_preds, type_facts


def format_bias(max_vars: int, max_body: int, body_preds: list[str], type_facts: list[str]) -> str:
    """Build bias.pl content string."""
    return (
        f"max_vars({max_vars}).\n"
        f"max_body({max_body}).\n"
        + FIXED_BIAS
        + "\n".join(body_preds)
        + "\n\n"
        + "\n".join(type_facts)
        + "\n"
        + COLORS_BIAS
        + CONSTRAINTS
    )


def format_groundings(base: list[str], extra: list[str]) -> str:
    """Build groundings.txt content string."""
    return "\n".join(base + extra) + "\n"


def write_files(files: dict[str, str]) -> None:
    """Write {path: content} pairs to disk."""
    for path, content in files.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(content)


def ground_bk(entries: list[str], out_dir: str, name: str) -> list[str]:
    """Run swipl grounder on entries. Returns grounded predicate lines."""
    grounder = os.path.abspath(os.path.join(PL_ROOT, "grounder.pl"))
    rules = os.path.abspath(os.path.join(PL_ROOT, "bk_rules.pl"))
    facts = os.path.abspath(os.path.join(PL_ROOT, "bk_facts.pl"))

    with open(os.path.join(PL_ROOT, "groundings.txt")) as f:
        ground_preds = ",".join(line.strip() for line in f)

    out_path = os.path.abspath(os.path.join(out_dir, f"{name}.pl"))
    temp_path = os.path.join(out_dir, f"{name}_temp.pl")

    temp_content = (
        f':- consult("{grounder}").\n'
        f':- consult("{rules}").\n'
        f':- consult("{facts}").\n\n'
        + "\n".join(entries)
        + "\n"
        + f"main :-\n\tPreds = [{ground_preds}],\n"
        + f"\tground_by_name(Preds, '{out_path}')."
    )

    try:
        with open(temp_path, "w") as f:
            f.write(temp_content)
        subprocess.run(
            ["swipl", "-q", "-s", temp_path, "-g", "main", "-t", "halt"],
            check=True,
            capture_output=True,
            text=True,
        )
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

    with open(out_path) as f:
        return f.readlines()


def setup_universal(ruleset: str, max_vars: int, max_body: int) -> None:
    """One-time setup: write groundings.txt, bk_rules.pl, bias.pl to PL_ROOT."""
    if os.path.isfile(ruleset):
        ruleset_path = ruleset
    else:
        ruleset_path = os.path.join(RULESETS_ROOT, f"{ruleset}.txt")
    terms, body_preds, type_facts = parse_ruleset(ruleset_path)

    with open(ruleset_path) as f:
        rules_content = f.read() + "\n\n"

    write_files(
        {
            os.path.join(PL_ROOT, "groundings.txt"): format_groundings(BASE_GROUND_PREDS, terms),
            os.path.join(PL_ROOT, "bk_rules.pl"): rules_content,
            os.path.join(PL_ROOT, "bias.pl"): format_bias(
                max_vars, max_body, body_preds, type_facts
            ),
        }
    )


def build_task(task_id: str, paths: RunPaths) -> None:
    """Full build pipeline for one task: parse grids, ground, write all files."""
    print("Generating task-specific predicates")
    data = read_task(task_id)

    train_preds = cells_to_predicates(data["train"])
    test_preds = cells_to_predicates(data["test"])

    os.makedirs(paths.root, exist_ok=True)

    # Ground training BK (swipl writes bk.pl directly)
    train_bk = []
    for p in train_preds:
        for e in p["bk"]:
            train_bk.append(e)
    ground_bk(train_bk, paths.root, "bk")

    # Ground test BK, then clean up intermediate file
    test_bk = []
    for p in test_preds:
        for e in p["bk"]:
            test_bk.append(e)
    grounded = ground_bk(test_bk, paths.root, "test_bk_grounded")
    grounded_path = os.path.join(paths.root, "test_bk_grounded.pl")
    if os.path.exists(grounded_path):
        os.remove(grounded_path)

    # Collect test examples
    test_exs = []
    for p in test_preds:
        for ex in (p["exs"]["pos"], p["exs"]["neg"]):
            for e in ex:
                test_exs.append(e)

    # Write remaining files
    write_files(
        {
            paths.exs: format_exs(train_preds),
            paths.test: format_test_pl(test_exs, grounded),
        }
    )
    shutil.copy(os.path.join(PL_ROOT, "bias.pl"), paths.root)
