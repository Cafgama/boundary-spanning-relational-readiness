# Step 10 — Pilot diagnostics and design gate

## Purpose

Step 10 reads the processed production-pilot output and generates a compact diagnostic report before final production parameters are locked.

This step does not run simulations. It only analyzes an existing processed pilot `.mat` file.

## New script

```text
experiments/rerun_v2/analyze_production_pilot.m
```

Usage:

```octave
analyze_production_pilot
```

or:

```octave
analyze_production_pilot('path/to/production_pilot_processed_YYYYMMDD_HHMMSS.mat')
```

If no file is provided, the script uses the latest:

```text
results/processed/rerun_v2/pilot/production_pilot_processed_*.mat
```

## What the script checks

The diagnostic script reports:

- pilot design: `NG`, `NT`, `T_max`, `n_boot`, seed base, bootstrap seed;
- condition-level readiness probability;
- censoring probability;
- RMST;
- T50, T90, T95 and their estimability flags;
- contrast-level RMST difference and confidence interval;
- readiness-probability difference and confidence interval;
- T95 difference, confidence interval, and bootstrap valid share;
- diagnostic alerts.

## Diagnostic alerts

The script raises text alerts when:

- a condition has readiness probability below 0.95;
- T50 is not estimable;
- T90 is not estimable;
- T95 is not estimable;
- bootstrap valid share for T50, T90, or T95 is below 0.50.

These alerts are not necessarily errors. In a small pilot, low valid shares for upper-tail quantiles can be expected. Their purpose is to prevent us from treating a weak pilot diagnostic as a final manuscript result.

## Output

The script writes a diagnostic report under:

```text
results/processed/rerun_v2/pilot/
```

with filename pattern:

```text
production_pilot_diagnostics_YYYYMMDD_HHMMSS.txt
```

## New tests

```text
tests/rerun_v2/test_pilot_diagnostics.m
tests/rerun_v2/run_diagnostic_tests.m
```

The test uses a synthetic processed pilot structure. It does not run simulations.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_diagnostic_tests
```

Expected result:

```text
ALL RERUN V2 DIAGNOSTIC TESTS PASSED
```

## Actual pilot diagnostic command

After tests pass, run:

```octave
analyze_production_pilot
```

Expected result:

```text
RERUN V2 PILOT DIAGNOSTICS PASSED
```

## Interpretation rule

Step 10 is a design gate, not a manuscript-result step. It helps decide final production settings such as `NG`, `NT`, `T_max`, `n_boot`, final condition set, and which metrics can be reported reliably.
