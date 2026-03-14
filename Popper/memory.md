# Popper Memory

The memory system persists learned search information across runs, allowing subsequent runs on the same task to skip redundant work. Everything is stored in a single `memory.pkl` file in the task directory.

## What is saved

Two categories of data are saved:

**Constraints** are nogoods that prune the hypothesis space. During a run, Popper tests candidate programs and derives constraints that eliminate provably unhelpful regions of the search space:

- SPECIALISATION: program P is consistent but doesn't cover all positives. No program containing P's body (or more) can do better, so prune P and all specialisations.
- GENERALISATION: program P covers negatives. Any program with a subset of P's body also covers those negatives, so prune all generalisations.
- BANISH: (noisy mode) prune a program and its generalisations when neither spec/gen applies.
- UNSAT: a body pattern has no satisfying substitution. Any program containing it is dead.

**Combiner state** consists of programs that were found useful and their coverage data:

- `prog_lookup`: hash to program (frozenset of rules)
- `coverage_pos` / `coverage_neg`: hash to bitarray of which examples are covered
- `saved_progs`: set of program hashes the combiner knows about
- `inconsistent`: programs found inconsistent during combination (recursive/PI)

## Why both are needed

Constraints alone are not sufficient. When Popper tests a consistent program that covers some positives, two things happen:

1. A SPECIALISATION constraint is added. This prunes the program itself and all specialisations from future generation (the nogood matches when all body literals are present, regardless of additional literals).
2. The program is added to the combiner. It may be part of the optimal multi-rule solution.

On a subsequent run, the loaded constraints prevent the generator from reproducing these programs. If the combiner state isn't also loaded, those programs are permanently lost. For tasks requiring multi-rule solutions (e.g. colour mapping where each rule handles one colour), the combiner needs all component rules to find the combination that covers all examples.

## Assumptions

- Examples do not change between runs. The coverage bitarrays are tied to specific positive/negative examples. If examples change, the loaded coverage data is invalid.
- The bias file and background knowledge remain the same. Constraints reference predicates and variable structures defined by the bias. Changing the bias would make loaded constraints nonsensical.
