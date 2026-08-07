# Step 15 — Translation-grid production

## Purpose

Step 15 runs the final translation-capability grid for the rerun_v2 pipeline.

The final core run already confirmed the binary switching contrast:

```text
BS_low  = pi_BS 0.55
BS_high = pi_BS 0.65
```

The translation-grid run checks whether the effect is monotonic as translation capability increases.

## Scientific question

Does readiness delay decrease monotonically as boundary-spanning translation capability increases?

## Default production design

```text
architecture = boundary_spanning
pi_out = 0.55
pi_BS grid = [0.55, 0.60, 0.65, 0.70]
NG = 50 graph realizations
NT = 50 trajectories per graph
T_max = 50000
n_boot = 10000
theta = 0.80
q = 0.80
selection rule = agent_first
```

The condition names are:

```text
BS_pi_055
BS_pi_060
BS_pi_065
BS_pi_070
```

## New script

```text
experiments/rerun_v2/run_translation_grid_production.m
```

Default usage:

```octave
run_translation_grid_production
```

Small test usage:

```octave
config = struct();
config.run_type = 'translation_grid_test';
config.output_tag = 'translation_grid_test';
config.NG = 2;
config.NT = 3;
config.T_max = 2000;
config.n_boot = 20;
config.pi_BS_grid = [0.55, 0.65];
run_translation_grid_production(config)
```

## Outputs

Default production outputs are saved under:

```text
results/raw/rerun_v2/translation_grid/
results/processed/rerun_v2/translation_grid/
```

Files follow this pattern:

```text
translation_grid_raw_YYYYMMDD_HHMMSS.mat
translation_grid_processed_YYYYMMDD_HHMMSS.mat
translation_grid_manifest_YYYYMMDD_HHMMSS.txt
```

## Bootstrap contrasts

The script estimates adjacent grid contrasts:

```text
BS_pi_055_minus_BS_pi_060
BS_pi_060_minus_BS_pi_065
BS_pi_065_minus_BS_pi_070
```

It also estimates contrasts from the lowest translation capability to higher levels:

```text
BS_pi_055_minus_BS_pi_065
BS_pi_055_minus_BS_pi_070
```

For time metrics, a positive difference means the second condition is faster/lower.

## Diagnostics

The script raises alerts when:

- readiness probability is below 0.95;
- T50/T90/T95 is not estimable;
- RMST is not monotonically decreasing in pi_BS;
- T95 is not monotonically decreasing in pi_BS;
- bootstrap valid share for a quantile is below 0.50.

For the final production run, zero alerts are preferred but not required for code validity. If a monotonicity alert appears, we stop and interpret the result before changing anything.

## New tests

```text
tests/rerun_v2/test_translation_grid_production.m
tests/rerun_v2/run_translation_grid_tests.m
```

The test uses a tiny configuration and validates only the pipeline, not the scientific result.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_translation_grid_tests
```

Expected result:

```text
ALL RERUN V2 TRANSLATION-GRID TESTS PASSED
```

## After test validation

Only after the small test passes, run:

```octave
run_translation_grid_production
```

This may take several hours, although it has only four conditions and the same NG/NT/T_max/n_boot scale as the final core production.

## Interpretation guardrail

This step still concerns time to relational coordination readiness. It does not measure R&D performance, innovation success, project completion, or output quality.
