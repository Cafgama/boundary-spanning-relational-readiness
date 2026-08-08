# Step 18 — Workload-grid production

## Purpose

Step 18 runs the workload/capacity grid for the rerun_v2 computational pipeline.

The scientific question is whether translation-capable boundary spanning becomes faster when the same cross-boundary tie budget is distributed across more designated boundary spanners per side.

This step tests the workload part of the design principle:

```text
right people + right place + right workload
```

## Design

The workload-grid production script holds fixed:

```text
architecture = boundary_spanning
pi_out = 0.55
pi_BS = 0.65
theta = 0.80
q = 0.80
k = 12
T_max = 50000
```

and varies:

```text
b = 1, 2, 4, 6
```

where `b` is the number of designated boundary spanners per side.

Approximate workload per spanner is:

```text
load = k / (2b)
```

Therefore the default grid corresponds to:

| b | Approximate load per spanner |
|---:|---:|
| 1 | 6.0 |
| 2 | 3.0 |
| 4 | 1.5 |
| 6 | 1.0 |

The expected pattern is decreasing readiness delay as `b` increases, because the same cross-boundary responsibility is distributed across more boundary-spanning actors.

## Production parameters

Default production settings:

```text
NG = 50
NT = 50
T_max = 50000
n_boot = 10000
seed_base = 808000
bootstrap_seed = 909000
```

The production run creates 4 conditions:

```text
BS_b_01
BS_b_02
BS_b_04
BS_b_06
```

and the following bootstrap contrasts:

```text
BS_b_01_minus_BS_b_02
BS_b_02_minus_BS_b_04
BS_b_04_minus_BS_b_06
BS_b_01_minus_BS_b_04
BS_b_01_minus_BS_b_06
```

Differences are computed as condition X minus condition Y. For time metrics, positive values mean that condition Y is faster/lower.

## Files added

```text
experiments/rerun_v2/run_workload_grid_production.m
tests/rerun_v2/test_workload_grid_production.m
tests/rerun_v2/run_workload_grid_tests.m
docs/step18_workload_grid_production.md
```

## Test command

Before production, run the small local test:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_workload_grid_tests
```

Expected result:

```text
ALL RERUN V2 WORKLOAD-GRID TESTS PASSED
```

The test uses a tiny configuration:

```text
NG = 2
NT = 3
T_max = 2000
n_boot = 20
b_grid = [1, 2, 4]
```

The test is not a manuscript result.

## Production command

After the test passes, run:

```octave
run_workload_grid_production
```

Expected final message:

```text
RERUN V2 WORKLOAD-GRID PRODUCTION PASSED
```

## Output paths

Production outputs are written to:

```text
results/raw/rerun_v2/workload_grid/
results/processed/rerun_v2/workload_grid/
```

The script writes:

```text
workload_grid_raw_YYYYMMDD_HHMMSS.mat
workload_grid_processed_YYYYMMDD_HHMMSS.mat
workload_grid_manifest_YYYYMMDD_HHMMSS.txt
```

## Diagnostic alerts

The script records alerts when:

- readiness probability is below 0.95;
- T50, T90, or T95 is not estimable;
- RMST is not monotonically decreasing as `b` increases;
- T95 is not monotonically decreasing as `b` increases;
- bootstrap valid share is too low for event-time quantiles.

Alerts are not automatically manuscript conclusions. They are design-gate diagnostics that indicate whether we should stop and inspect the workload experiment before exporting results.

## Interpretation rule

This step does not measure R&D performance or project output. It measures time to relational coordination readiness under alternative boundary-spanning capacity allocations.

If the production run confirms the expected pattern, the safe manuscript claim is:

```text
For a fixed cross-boundary tie budget and translation capability, distributing boundary-spanning responsibility across more boundary spanners reduces readiness delay and upper-tail delay.
```

If the monotonicity alert appears, we should not claim a smooth workload effect without additional analysis.
