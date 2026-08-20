# Step 29 — Mini heatmap translation-by-workload

## Purpose

Step 29 adds a compact translation-by-workload grid for manuscript visualization.

The goal is not to replace the core mechanism tests. The goal is to provide a reader-friendly design map showing how readiness delay changes jointly with:

- boundary-spanner translation capability; and
- per-spanner workload/capacity.

## Scientific role

The heatmap should be interpreted as a visual synthesis of two already-tested mechanisms:

1. translation capability; and
2. boundary-spanner workload.

It supports the managerial design logic:

```text
lower translation + higher workload  -> higher relational delay
higher translation + lower workload  -> lower relational delay
```

## Production script

```text
experiments/rerun_v2/run_mini_heatmap_production.m
```

Default production design:

```text
architecture = boundary_spanning
selection_rule = agent_first
pi_out = 0.55
pi_BS_grid = [0.55, 0.60, 0.70]
b_grid = [1, 2, 6]
NG = 50
NT = 50
T_max = 50000
theta = 0.80
q = 0.80
```

This produces a 3x3 grid, with one condition per translation-workload cell.

## Analysis/export script

```text
experiments/rerun_v2/analyze_mini_heatmap_results.m
```

This script reads the latest processed mini-heatmap file and exports:

```text
results/processed/rerun_v2/mini_heatmap/mini_heatmap_condition_estimates.csv
results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_RMST.csv
results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_T95.csv
results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_readiness_probability.csv
results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_condition_estimates.csv
results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_RMST.csv
results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_T95.csv
results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_readiness_probability.csv
docs/mini_heatmap_results_handover.md
```

## Tests

```text
tests/rerun_v2/test_mini_heatmap_pipeline.m
tests/rerun_v2/run_mini_heatmap_tests.m
```

The test runs a very small 2x2 grid. It validates that production, analysis, CSV export, and handover creation work. It is not a scientific run.

## Local test command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_mini_heatmap_tests
```

Expected result:

```text
ALL RERUN V2 MINI HEATMAP TESTS PASSED
```

## Production command

After tests pass:

```octave
run_mini_heatmap_production
```

Expected final result:

```text
RERUN V2 MINI HEATMAP PRODUCTION PASSED
```

Then export:

```octave
analyze_mini_heatmap_results
```

Expected final result:

```text
RERUN V2 MINI HEATMAP EXPORTS PASSED
```

## Expected figure

The preferred manuscript figure is an RMST heatmap:

- x-axis: `pi_BS`;
- y-axis: `load_per_spanner` or `b`;
- cell value: RMST;
- optional annotation inside each cell.

The figure should be described as a design map, not as a separate causal identification test.

## Guardrails

- The heatmap reports time to relational coordination readiness, not R&D performance.
- RMST is the primary heatmap metric.
- T95 is secondary and should be used only when estimable.
- Censored trajectories are not converted into artificial event times.
- This mini heatmap integrates two already-tested dimensions; it does not replace final-core, translation-grid, workload-grid, or robustness results.
