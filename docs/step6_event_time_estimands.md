# Step 6 — Manuscript-facing event-time estimands

## Purpose

Step 6 introduces the function used to compute manuscript-facing event-time estimands from first-passage simulations with administrative right censoring.

The central rule is:

> A censored trajectory contributes to RMST and readiness probability, but must not be treated as an observed event time for T50, T90, or T95.

This prevents `T_max` from being reported as an artificial readiness time.

## New source file

```text
src/compute_event_time_estimands.m
```

The function accepts either:

```octave
S = compute_event_time_estimands(results)
```

where `results` contains `T_tilde` and `delta`, or:

```octave
S = compute_event_time_estimands(T_tilde, delta)
```

It can also accept custom quantile probabilities:

```octave
S = compute_event_time_estimands(T_tilde, delta, [0.50; 0.90; 0.95])
```

## Required input semantics

```text
T        = event time if readiness was reached; NaN otherwise
T_tilde  = observed time; T if event, T_max if censored
delta    = event indicator; 1 if readiness was reached, 0 if censored
```

## Output estimands

The output structure includes:

```text
n
n_events
n_censored
readiness_probability
censoring_probability
RMST
T50
T90
T95
T50_estimable
T90_estimable
T95_estimable
quantile_probs
quantile_values
quantile_estimable
quantile_ranks
```

## Quantile rule

For a quantile probability `p`, the p-th event-time quantile is estimable only if at least `ceil(p*n)` observed events occurred.

If this condition is met, the quantile is the corresponding ordered observed event time.

If this condition is not met, the quantile is returned as `NaN`, and the estimability flag is zero.

Examples:

```text
n = 5
observed events = 3
T50 requires ceil(0.50*5) = 3 events, so T50 is estimable.
T90 requires ceil(0.90*5) = 5 events, so T90 is not estimable.
T95 requires ceil(0.95*5) = 5 events, so T95 is not estimable.
```

## Tests added

```text
tests/rerun_v2/assert_close.m
tests/rerun_v2/test_event_time_estimands_complete_data.m
tests/rerun_v2/test_event_time_estimands_censored.m
tests/rerun_v2/test_event_time_estimands_all_censored.m
tests/rerun_v2/test_event_time_estimands_struct_input.m
tests/rerun_v2/test_event_time_estimands_invalid_inputs.m
tests/rerun_v2/run_estimand_tests.m
```

## Local command

After pulling the branch, run:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
run_estimand_tests
```

Expected result:

```text
ALL RERUN V2 EVENT-TIME ESTIMAND TESTS PASSED
```

## Scientific consequence

After Step 6, manuscript-facing summaries should use:

- RMST for average observed time under censoring;
- readiness probability for probability of reaching readiness within `T_max`;
- event-time quantiles only when estimable.

Old summaries that substitute `T_max` into T50/T90/T95 should not be used for final manuscript claims.
