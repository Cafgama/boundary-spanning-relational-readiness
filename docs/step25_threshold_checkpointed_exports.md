# Step 25 — Checkpointed threshold robustness diagnostics and export

## Purpose

Step 25 reads the final checkpointed threshold-robustness output and exports clean CSVs plus a manuscript-facing handover document.

This step does not run simulations. It only analyzes the completed checkpointed `.mat` file.

## New script

```text
experiments/rerun_v2/analyze_threshold_checkpointed_results.m
```

Usage:

```octave
analyze_threshold_checkpointed_results
```

or:

```octave
analyze_threshold_checkpointed_results('path/to/threshold_checkpointed_processed_YYYYMMDD_HHMMSS.mat')
```

If no file is provided, the script uses the latest:

```text
results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_checkpointed_processed_*.mat
```

## Source experiment

The source production script is:

```text
experiments/rerun_v2/run_readiness_threshold_checkpointed.m
```

It compares `BS_low` and `BS_high` across five readiness-threshold scenarios:

```text
easier_tie
baseline
easier_boundary
harder_boundary
harder_tie
```

## Outputs

The export script writes:

```text
results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_condition_estimands.csv
results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_contrasts.csv
results/figure_data/rerun_v2/threshold_robustness_checkpointed/threshold_condition_estimands.csv
results/figure_data/rerun_v2/threshold_robustness_checkpointed/threshold_contrasts.csv
docs/threshold_robustness_results_handover.md
```

## What the script reports

Condition-level values:

- condition id;
- scenario id and label;
- theta and q;
- translation level;
- readiness probability;
- censoring probability;
- RMST;
- T50, T90, T95;
- estimability flags.

Contrast-level values:

- `BS_low minus BS_high` within each scenario;
- RMST difference and 95% CI;
- readiness-probability difference and 95% CI;
- T50, T90, and T95 differences and 95% CIs;
- bootstrap valid shares.

## Interpretation logic

Differences are computed as:

```text
BS_low minus BS_high
```

For time metrics, positive differences mean that `BS_high` reaches readiness faster/lower.

The key questions are:

1. Does translation-capable boundary spanning reduce RMST across threshold scenarios?
2. Does it reduce upper-tail delay when T95 is estimable?
3. Does the hardest tie-threshold scenario reveal an estimability boundary for `BS_low`?

## Expected nuance

The hardest scenario:

```text
harder_tie: theta = 0.85, q = 0.80
```

may produce alerts for `harder_tie_BS_low`, such as:

```text
LOW_READINESS_PROBABILITY
T50_NOT_ESTIMABLE
T90_NOT_ESTIMABLE
T95_NOT_ESTIMABLE
LOW_BOOTSTRAP_VALID_SHARE_T50/T90/T95
```

These alerts are not automatically errors. They indicate that the low-translation condition can fail to reach readiness often enough under a stringent tie-level threshold. The correct response is to report the estimability boundary, not to replace censored observations with artificial event times.

## New tests

```text
tests/rerun_v2/test_threshold_checkpointed_exports.m
tests/rerun_v2/run_threshold_export_tests.m
```

The test uses a synthetic processed threshold-robustness structure. It does not run simulations.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_threshold_export_tests
```

Expected result:

```text
ALL RERUN V2 THRESHOLD CHECKPOINTED EXPORT TESTS PASSED
```

## Actual export command

After tests pass, run:

```octave
analyze_threshold_checkpointed_results
```

Expected result:

```text
RERUN V2 THRESHOLD CHECKPOINTED EXPORTS PASSED
```

Then inspect or share:

```text
docs/threshold_robustness_results_handover.md
```

## Guardrails

- Results refer to time to relational coordination readiness, not R&D performance or innovation success.
- RMST uses observed time `T_tilde`.
- Event quantiles are reported only when estimable.
- Censored trajectories are not converted into artificial event times.
- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.
