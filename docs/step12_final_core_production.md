# Step 12 — Final core production

## Purpose

Step 12 creates the final-core production script for the three central conditions of the rerun-v2 pipeline.

This is the first manuscript-facing production script, but it is limited to the core mechanism:

- `RB_low`
- `BS_low`
- `BS_high`

and the three central contrasts:

- `RB_low_minus_BS_low`
- `BS_low_minus_BS_high`
- `RB_low_minus_BS_high`

Translation grids, workload grids, switching maps, and robustness analyses are not run in Step 12. They should be implemented only after the final core run is validated.

## Default final-core design

```text
NG = 50
NT = 50
T_max = 50000
n_boot = 10000
theta = 0.80
q = 0.80
pi_out = 0.55
pi_BS_low = 0.55
pi_BS_high = 0.65
```

This produces:

```text
3 conditions x 50 graphs x 50 trajectories = 7500 trajectories
```

plus three hierarchical paired bootstraps with 10,000 bootstrap replications each.

## New script

```text
experiments/rerun_v2/run_final_core_production.m
```

Default usage:

```octave
run_final_core_production
```

Outputs are written to:

```text
results/raw/rerun_v2/final_core/
results/processed/rerun_v2/final_core/
```

The script writes:

```text
final_core_raw_YYYYMMDD_HHMMSS.mat
final_core_processed_YYYYMMDD_HHMMSS.mat
final_core_manifest_YYYYMMDD_HHMMSS.txt
```

## Test mode

The same script accepts a small config for testing:

```octave
config = struct();
config.run_type = 'final_core_test';
config.output_tag = 'final_core_test';
config.NG = 2;
config.NT = 3;
config.T_max = 2000;
config.n_boot = 20;
run_final_core_production(config)
```

This keeps the production logic and test logic in one script while avoiding accidental long runs during tests.

## New tests

```text
tests/rerun_v2/test_final_core_production.m
tests/rerun_v2/run_final_core_tests.m
```

The test runs the final-core script in small test mode and verifies:

- all three conditions are present;
- each condition has the expected trajectory count;
- `T_tilde`, `delta`, `converged`, `graph_id`, and `trajectory_id` are valid;
- estimands are created;
- bootstraps are created;
- raw, processed, and manifest files are saved;
- test outputs go only to `results/.../rerun_v2/final_core_test/`.

## Local validation command

Before running production, validate the final-core script in test mode:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_final_core_tests
```

Expected result:

```text
ALL RERUN V2 FINAL CORE TESTS PASSED
```

## Actual production command

Only after the final-core tests pass, run:

```octave
run_final_core_production
```

Expected result:

```text
RERUN V2 FINAL CORE PRODUCTION PASSED
```

## Important interpretation rule

The final-core results are manuscript-facing only after the run completes and the processed output is inspected. Any diagnostic alerts should be reviewed before values are sent to the manuscript-writing chat.

## Next step after successful final-core production

After Step 12 passes and the final-core output is inspected, the next computational steps should implement the additional experiment families one at a time:

1. translation-capability grid;
2. boundary-spanner workload grid;
3. translation-workload switching map;
4. robustness analyses;
5. final CSV/table/figure generation;
6. `docs/manuscript_results_handover.md`.
