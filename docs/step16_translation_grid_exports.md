# Step 16 — Translation-grid diagnostics and export

## Purpose

Step 16 reads the processed translation-grid production output and exports manuscript-facing CSVs plus a Markdown handover for the writing track.

This step does not run simulations. It only reads an existing processed translation-grid `.mat` file.

## New script

```text
experiments/rerun_v2/analyze_translation_grid_results.m
```

Usage:

```octave
analyze_translation_grid_results
```

or:

```octave
analyze_translation_grid_results('path/to/translation_grid_processed_YYYYMMDD_HHMMSS.mat')
```

If no file is provided, the script uses the latest:

```text
results/processed/rerun_v2/translation_grid/translation_grid_processed_*.mat
```

## Inputs

The script expects a processed file containing:

```text
translation_grid
estimands
bootstraps
config
```

The `translation_grid` structure must contain:

- run metadata;
- grid configuration;
- conditions;
- condition-level estimands;
- bootstrap contrasts;
- diagnostic alert count.

## Outputs

The script writes:

```text
results/processed/rerun_v2/translation_grid/translation_grid_condition_estimands.csv
results/processed/rerun_v2/translation_grid/translation_grid_contrasts.csv
results/figure_data/rerun_v2/translation_grid/translation_grid_condition_estimands.csv
results/figure_data/rerun_v2/translation_grid/translation_grid_contrasts.csv
docs/translation_grid_results_handover.md
```

## Condition CSV

The condition CSV contains:

- condition identifier;
- architecture;
- `pi_out`;
- `pi_BS`;
- readiness probability;
- censoring probability;
- RMST;
- T50, T90, and T95;
- estimability flags.

## Contrast CSV

The contrast CSV contains:

- contrast identifier;
- X and Y condition identifiers;
- number of bootstrap replications;
- number of graphs;
- number of matched trajectories;
- RMST difference and confidence interval;
- readiness-probability difference and confidence interval;
- T50, T90, and T95 differences, intervals, and bootstrap valid shares;
- interpretation labels.

Differences are computed as:

```text
condition X minus condition Y
```

For time metrics:

```text
positive difference = condition Y is faster/lower
negative difference = condition X is faster/lower
```

## Monotonicity diagnostic

The script evaluates whether RMST and T95 decrease monotonically as `pi_BS` increases.

The relevant checks are:

```text
RMST_monotonic_decreasing
T95_monotonic_decreasing
```

These are diagnostic flags for the writing track. They should not be interpreted as a separate statistical test by themselves; the contrast intervals provide the inferential evidence.

## Test

New test files:

```text
tests/rerun_v2/test_translation_grid_exports.m
tests/rerun_v2/run_translation_export_tests.m
```

The test uses a synthetic processed translation-grid structure. It does not run simulations.

## Local validation commands

First pull the latest branch:

```powershell
cd C:\Users\cafga\boundary-spanning-relational-readiness
git pull
```

Then run the synthetic export test in Octave:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_translation_export_tests
```

Expected result:

```text
ALL RERUN V2 TRANSLATION-GRID EXPORT TESTS PASSED
```

After the test passes, run the real export:

```octave
analyze_translation_grid_results
```

Expected result:

```text
RERUN V2 TRANSLATION-GRID EXPORTS PASSED
```

## Writing-track handover

The key file for the writing track is:

```text
docs/translation_grid_results_handover.md
```

It includes:

- source and reproducibility metadata;
- exported file paths;
- condition-level estimands;
- contrast-level results;
- monotonicity diagnostics;
- claim status;
- interpretation guardrails.
