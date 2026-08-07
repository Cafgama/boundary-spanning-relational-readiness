# Step 7 — Hierarchical paired bootstrap

## Purpose

This step adds the bootstrap procedure required for manuscript-facing comparisons in the rerun-v2 computational pipeline.

The old pipeline compared graph-level summaries. The rerun-v2 design requires pooled marginal estimands and a bootstrap that respects the nested simulation structure.

## Bootstrap design

The new function is:

```text
src/hierarchical_paired_bootstrap.m
```

It requires two matched results structures containing:

```text
graph_id
trajectory_id
T_tilde
delta
```

The bootstrap samples in two levels:

1. matched graph identifiers are sampled with replacement;
2. within each selected graph, matched trajectory identifiers are sampled with replacement.

The same sampled graph/trajectory positions are used in both compared conditions.

This preserves the paired experimental design when comparing, for example:

```text
RB_low versus BS_low
BS_low versus BS_high
BS_high at one parameter value versus BS_high at another parameter value
```

## Estimands recomputed in every bootstrap sample

For each bootstrap sample, the function recomputes:

```text
RMST
readiness_probability
censoring_probability
T50
T90
T95
```

The quantile estimability logic comes from:

```text
src/compute_event_time_estimands.m
```

If a quantile is not estimable in a bootstrap sample, its bootstrap difference is recorded as `NaN` for that metric only. The output records the valid bootstrap share for each metric.

## Difference convention

All differences use:

```text
condition_x - condition_y
```

For time metrics, a positive value means condition_y is faster/lower.

For readiness probability, a positive value means condition_x has higher readiness probability.

This convention is deliberately explicit in the output fields:

```text
B.difference_convention
B.time_metric_interpretation
B.probability_metric_interpretation
```

## Output fields

The function returns structure `B` with:

```text
B.n_boot
B.seed
B.n_graphs
B.n_matched_trajectories
B.metric_names
B.observed_x
B.observed_y
B.observed_difference
B.ci_low
B.ci_high
B.bootstrap_valid_share
B.bootstrap_differences
```

## Tests added

The test runner is:

```text
tests/rerun_v2/run_bootstrap_tests.m
```

It runs:

```text
test_hierarchical_paired_bootstrap_complete_data
test_hierarchical_paired_bootstrap_censored_quantiles
test_hierarchical_paired_bootstrap_matching_errors
```

The tests check:

- complete-data observed differences;
- finite bootstrap intervals for RMST;
- censored quantiles remain non-estimable when appropriate;
- unmatched graph identifiers fail loudly;
- unmatched trajectory identifiers fail loudly.

## Local command

From the Octave GUI:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
run_bootstrap_tests
```

Expected final line:

```text
ALL RERUN V2 HIERARCHICAL BOOTSTRAP TESTS PASSED
```

## Stop rule

Do not run production simulations until these bootstrap tests pass locally.
