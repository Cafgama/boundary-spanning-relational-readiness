# Step 22 — Selection-rule robustness diagnostics and export

## Purpose

Step 22 reads the processed selection-rule robustness output and exports clean CSVs plus a manuscript-facing handover document.

This step does not run simulations. It only analyzes an existing processed `.mat` file.

## New script

```text
experiments/rerun_v2/analyze_selection_rule_results.m
```

Usage:

```octave
analyze_selection_rule_results
```

or:

```octave
analyze_selection_rule_results('path/to/selection_rule_processed_YYYYMMDD_HHMMSS.mat')
```

If no file is provided, the script uses the latest:

```text
results/processed/rerun_v2/selection_rule_robustness/selection_rule_processed_*.mat
```

## Source experiment

The source production script is:

```text
experiments/rerun_v2/run_selection_rule_robustness.m
```

The experiment compares three mechanism conditions:

```text
RB_low
BS_low
BS_high
```

under two interaction-selection rules:

```text
agent_first
edge_uniform
```

## Outputs

The export script writes:

```text
results/processed/rerun_v2/selection_rule_robustness/selection_rule_condition_estimands.csv
results/processed/rerun_v2/selection_rule_robustness/selection_rule_contrasts.csv
results/figure_data/rerun_v2/selection_rule_robustness/selection_rule_condition_estimands.csv
results/figure_data/rerun_v2/selection_rule_robustness/selection_rule_contrasts.csv
docs/selection_rule_results_handover.md
```

## What the script reports

The script exports condition-level values:

- condition id;
- mechanism condition;
- architecture;
- selection rule;
- readiness probability;
- censoring probability;
- RMST;
- T50, T90, T95;
- estimability flags.

It also exports contrast-level values:

- RMST difference and 95% CI;
- readiness-probability difference and 95% CI;
- T50, T90, T95 differences and 95% CIs;
- bootstrap valid shares.

## Interpretation logic

The baseline rule is `agent_first`, because it represents scarce actor attention and interaction capacity.

The robustness rule is `edge_uniform`, because it removes most of the actor-level overload mechanism by giving every edge similar activation opportunity.

The main diagnostic question is:

> Does the BS-low bottleneck penalty weaken or disappear under edge-uniform selection?

If yes, the result supports the interpretation that the bottleneck mechanism depends on actor-level interaction-capacity scarcity.

The secondary question is:

> Does translation-capable boundary spanning remain faster than low-translation boundary spanning under edge-uniform selection?

If yes, the translation mechanism is robust to the alternative selection rule.

## New tests

```text
tests/rerun_v2/test_selection_rule_exports.m
tests/rerun_v2/run_selection_export_tests.m
```

The test uses a synthetic processed selection-rule structure. It does not run simulations.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_selection_export_tests
```

Expected result:

```text
ALL RERUN V2 SELECTION-RULE EXPORT TESTS PASSED
```

## Actual export command

After tests pass, run:

```octave
analyze_selection_rule_results
```

Expected result:

```text
RERUN V2 SELECTION-RULE EXPORTS PASSED
```

Then inspect or share:

```text
docs/selection_rule_results_handover.md
```

## Guardrails

- This robustness run does not replace the baseline agent-first model.
- Results refer to time to relational coordination readiness, not R&D performance or innovation success.
- Censored trajectories are not converted into artificial event times.
- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.
