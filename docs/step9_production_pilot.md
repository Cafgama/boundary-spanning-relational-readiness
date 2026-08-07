# Step 9 — Production pilot pipeline

## Purpose

Step 9 adds a medium-small production pilot after the smoke test. The pilot is not a final manuscript result. Its purpose is to validate the full rerun_v2 comparison structure before any long production simulation.

The pilot checks:

1. whether the three central conditions run together;
2. whether trajectory-level outputs contain the required event-time fields;
3. whether outputs are saved only under versioned rerun_v2 pilot folders;
4. whether pooled marginal estimands are computed;
5. whether hierarchical paired bootstraps run for the central contrasts;
6. whether manifests are written for reproducibility.

## Pilot design

The pilot uses:

```text
NG = 10 graph realizations
NT = 20 trajectories per graph
T_max = 10000
n_boot = 500
```

The conditions are:

```text
RB_low  : random_bridging, pi_out = 0.55, pi_BS = 0.55
BS_low  : boundary_spanning, pi_out = 0.55, pi_BS = 0.55
BS_high : boundary_spanning, pi_out = 0.55, pi_BS = 0.65
```

The central contrasts are:

```text
RB_low_minus_BS_low
BS_low_minus_BS_high
RB_low_minus_BS_high
```

## Important interpretation rule

The pilot is a computational validation run, not a manuscript result. It may show patterns similar to the final expected results, but those values must not be used as final paper estimates.

## Files added

```text
experiments/rerun_v2/run_production_pilot.m
tests/rerun_v2/test_production_pilot.m
tests/rerun_v2/run_pilot_tests.m
docs/step9_production_pilot.md
```

## Output paths

The pilot writes raw outputs to:

```text
results/raw/rerun_v2/pilot/
```

and processed outputs plus manifest to:

```text
results/processed/rerun_v2/pilot/
```

This protects all old results and separates the pilot from smoke outputs.

## Required local command

From Octave GUI, after `git pull`:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_pilot_tests
```

Expected final message:

```text
ALL RERUN V2 PRODUCTION PILOT TESTS PASSED
```

## Success criteria

The pilot passes only if:

- all three conditions are present;
- each condition has exactly `NG * NT` rows;
- `graph_id`, `trajectory_id`, `T_tilde`, and `delta` are present;
- `delta` contains only 0/1;
- `T_tilde` contains no NaN;
- `converged` equals `delta`;
- raw, processed, and manifest files exist;
- output files are saved under rerun_v2 pilot paths;
- all three central bootstrap contrasts are present.

## Next step

If the pilot passes, the next step is to inspect pilot outputs and decide whether to proceed to final production scripts or adjust runtime/replication settings first.
