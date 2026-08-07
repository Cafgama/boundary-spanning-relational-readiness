# Step 8 — Smoke simulation pipeline

## Purpose

Step 8 adds a small end-to-end smoke simulation. It is not a production experiment and must not be used for scientific interpretation.

Its purpose is to verify that the rerun_v2 computational chain works from network generation to saved outputs:

```text
generator -> dynamics -> raw results -> event-time estimands -> hierarchical paired bootstrap -> versioned files
```

## New files

```text
experiments/rerun_v2/run_smoke_pipeline.m
tests/rerun_v2/test_smoke_pipeline.m
tests/rerun_v2/run_smoke_tests.m
docs/step8_smoke_pipeline.md
```

## Smoke configuration

The smoke script uses deliberately small settings:

```text
NG = 3
NT = 4
T_max = 2000
theta = 0.60
q = 0.50
n_boot = 50
```

These settings are only for testing whether the pipeline runs. They are not the production parameterization.

## Conditions

The smoke test compares two matched conditions:

```text
RB_low  = random_bridging, ordinary cross-boundary success
BS_high = boundary_spanning, translation-capable boundary spanning
```

The same graph identifiers and trajectory identifiers are used in both conditions, so the hierarchical paired bootstrap can run on real simulated smoke data.

## Outputs

The script writes only inside versioned rerun_v2 folders:

```text
results/raw/rerun_v2/smoke/
results/processed/rerun_v2/smoke/
```

The generated files have timestamped names:

```text
smoke_pipeline_raw_YYYYMMDD_HHMMSS.mat
smoke_pipeline_processed_YYYYMMDD_HHMMSS.mat
smoke_pipeline_manifest_YYYYMMDD_HHMMSS.txt
```

This prevents overwriting old results.

## What is validated

The smoke test checks that:

1. output files are created;
2. output files are inside rerun_v2 directories;
3. each condition has 12 trajectories;
4. each trajectory has `T`, `T_tilde`, `delta`, `converged`, `graph_id`, and `trajectory_id`;
5. `T_tilde` is finite and non-missing;
6. `delta` contains only 0 or 1;
7. `converged` equals `delta`;
8. event-time estimands are computed;
9. hierarchical paired bootstrap runs with 3 graphs and 12 matched trajectories.

## Local command

From Octave GUI, after pulling the branch:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_smoke_tests
```

Expected final message:

```text
ALL RERUN V2 SMOKE TESTS PASSED
```

## Interpretation

Passing Step 8 means the local rerun_v2 pipeline can run a small end-to-end simulation without breaking.

It does not mean the production results are ready. The next step is to create production-ready experiment scripts with manifests and then run small pilot batches before full production.
