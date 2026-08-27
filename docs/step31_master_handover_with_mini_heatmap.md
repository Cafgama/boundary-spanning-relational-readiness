# Step 31 — Master handover update with mini heatmap

## Purpose

Add the validated mini heatmap to the master manuscript-results handover as a sixth computational block.

The mini heatmap is treated as a visual synthesis of the translation-capability and boundary-spanner workload mechanisms. It is not a replacement for the final-core, translation-grid, workload-grid, selection-rule, or threshold-robustness evidence blocks.

## Files changed

- `experiments/rerun_v2/build_manuscript_results_handover.m`
- `tests/rerun_v2/test_manuscript_handover_builder.m`

## Required source handovers

The master handover now expects six source documents in `docs/`:

1. `final_core_results_handover.md`
2. `translation_grid_results_handover.md`
3. `workload_grid_results_handover.md`
4. `mini_heatmap_results_handover.md`
5. `selection_rule_results_handover.md`
6. `threshold_robustness_results_handover.md`

## Conceptual placement

The new mini-heatmap block appears after the workload grid and before robustness checks. This keeps the manuscript logic clean:

1. mechanism decomposition;
2. translation-capability grid;
3. workload/capacity grid;
4. visual design-map synthesis;
5. selection-rule robustness;
6. threshold robustness.

## New claim-map row

The master handover now includes a design-map synthesis row:

- Computational support: the mini heatmap jointly displays translation capability and boundary-spanner workload, showing the lowest RMST in the high-translation, low-load region.
- Manuscript discipline: treat this as a reader-facing synthesis of already-tested mechanisms, not as a replacement for the main inferential blocks.

## New guardrail

The handover now explicitly states that the mini heatmap is a visual design map. It does not add a new causal identification strategy and should not be described as a replacement for the main final-core, translation-grid, and workload-grid tests.

## Commands

From Octave:

```octave
clear
clc
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_manuscript_handover_tests
```

Expected:

```text
ALL RERUN V2 MANUSCRIPT HANDOVER TESTS PASSED
```

Then:

```octave
build_manuscript_results_handover
```

Expected:

```text
RERUN V2 MANUSCRIPT RESULTS HANDOVER PASSED
sources included: 6
```

## Output

The updated master handover is:

```text
docs/manuscript_results_handover.md
```
