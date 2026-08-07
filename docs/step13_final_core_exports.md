# Step 13 — Final core diagnostics and export

## Purpose

Step 13 converts the successful final core production output into clean manuscript-facing artifacts.

It does not run simulations. It reads the processed final core `.mat` file and exports:

- condition-level estimands;
- contrast-level bootstrap results;
- figure-data CSVs;
- a Markdown handover for the writing chat.

## Main script

```text
experiments/rerun_v2/analyze_final_core_results.m
```

## Usage

Default usage:

```octave
analyze_final_core_results
```

This reads the latest file matching:

```text
results/processed/rerun_v2/final_core/final_core_processed_*.mat
```

Explicit usage:

```octave
analyze_final_core_results('path/to/final_core_processed_YYYYMMDD_HHMMSS.mat')
```

## Outputs

For the final core run, the script writes:

```text
results/processed/rerun_v2/final_core/final_core_condition_estimands.csv
results/processed/rerun_v2/final_core/final_core_contrasts.csv
results/figure_data/rerun_v2/final_core/final_core_condition_estimands.csv
results/figure_data/rerun_v2/final_core/final_core_contrasts.csv
docs/manuscript_results_handover.md
```

For synthetic or test runs, the handover file uses a suffix such as:

```text
docs/manuscript_results_handover_final_core_synthetic_export_test.md
```

## Condition-level CSV

The condition-level CSV contains one row per condition:

- `RB_low`
- `BS_low`
- `BS_high`

Main columns:

- architecture;
- pi_out;
- pi_BS;
- b;
- k;
- theta;
- q;
- T_max;
- n;
- n_events;
- n_censored;
- readiness_probability;
- censoring_probability;
- RMST;
- T50 and estimability flag;
- T90 and estimability flag;
- T95 and estimability flag.

## Contrast-level CSV

The contrast-level CSV contains one row per contrast:

- `RB_low_minus_BS_low`
- `BS_low_minus_BS_high`
- `RB_low_minus_BS_high`

Main columns:

- x condition;
- y condition;
- n_boot;
- n_graphs;
- n_matched_trajectories;
- RMST difference and 95 percent CI;
- readiness probability difference and 95 percent CI;
- T50/T90/T95 differences, confidence intervals, and valid shares;
- automatic interpretation labels.

Differences are computed as:

```text
condition_x minus condition_y
```

For time metrics, positive values mean that condition Y is faster/lower.

## Manuscript handover

The script writes:

```text
docs/manuscript_results_handover.md
```

This file is the bridge back to the writing chat. It includes:

- source file and reproducibility metadata;
- condition-level table;
- contrast-level table;
- claim status for the three core comparisons;
- interpretation guardrails.

## New tests

```text
tests/rerun_v2/test_final_core_exports.m
tests/rerun_v2/run_final_export_tests.m
```

The test uses a synthetic final core structure. It does not run production simulations.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_final_export_tests
```

Expected result:

```text
ALL RERUN V2 FINAL CORE EXPORT TESTS PASSED
```

## Actual final export command

After the test passes, run:

```octave
analyze_final_core_results
```

Expected result:

```text
RERUN V2 FINAL CORE EXPORTS PASSED
```

## Interpretation guardrails

The generated handover explicitly states that:

- results refer to time to relational coordination readiness;
- they are not R&D performance, innovation success, patents, or output quality;
- RMST uses `T_tilde`;
- event quantiles are reported only when estimable;
- censored trajectories are not converted into artificial event times;
- bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.
