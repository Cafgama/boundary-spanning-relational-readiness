# Step 11 — High-horizon pilot

## Purpose

Step 11 is a design-gate pilot created after the production pilot showed non-estimability alerts with `T_max = 10000`.

The goal is to isolate whether the alerts were mainly caused by the short pilot horizon. We therefore keep the same pilot size but increase the horizon to the planned final value.

## Design

```text
NG = 10 graphs
NT = 20 trajectories per graph
T_max = 50000
n_boot = 500
```

Conditions:

```text
RB_low  = random bridging, pi_out = 0.55, pi_BS = 0.55
BS_low  = boundary spanning, pi_out = 0.55, pi_BS = 0.55
BS_high = boundary spanning, pi_out = 0.55, pi_BS = 0.65
```

Contrasts:

```text
RB_low_minus_BS_low
BS_low_minus_BS_high
RB_low_minus_BS_high
```

## New script

```text
experiments/rerun_v2/run_high_horizon_pilot.m
```

## Output folders

```text
results/raw/rerun_v2/high_horizon_pilot/
results/processed/rerun_v2/high_horizon_pilot/
```

The script writes:

```text
high_horizon_pilot_raw_YYYYMMDD_HHMMSS.mat
high_horizon_pilot_processed_YYYYMMDD_HHMMSS.mat
high_horizon_pilot_manifest_YYYYMMDD_HHMMSS.txt
```

## Diagnostic alerts

The high-horizon pilot records diagnostic alerts when:

- readiness probability is below 0.95;
- T50, T90, or T95 are not estimable for a condition;
- bootstrap valid share for T50, T90, or T95 is below 0.50.

Alerts are not automatic failures. They indicate what must be discussed before final production.

## New tests

```text
tests/rerun_v2/test_high_horizon_pilot.m
tests/rerun_v2/run_high_horizon_tests.m
```

These tests execute the high-horizon pilot and verify that:

- the run type is `high_horizon_pilot`;
- `NG = 10`, `NT = 20`, `T_max = 50000`, `n_boot = 500`;
- all three central conditions exist;
- each condition has `NG * NT` trajectories;
- `T_tilde`, `delta`, and `converged` fields are valid;
- the three central bootstraps exist;
- raw, processed, and manifest files are saved under versioned rerun folders;
- alerts are recorded without being treated as code errors.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_high_horizon_tests
```

Expected terminal result:

```text
ALL RERUN V2 HIGH-HORIZON PILOT TESTS PASSED
```

## Interpretation rule

This is not the final production run. It answers one design-gate question:

> Do the pilot's non-estimability alerts mostly disappear when `T_max` is increased to 50000?

If yes, the final-production design can likely use:

```text
NG = 50
NT = 50
T_max = 50000
n_boot = 10000
```

If not, we must stop and discuss alternatives before final production.
