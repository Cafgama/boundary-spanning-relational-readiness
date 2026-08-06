# Step 5 — Event-time fields

This step adds the locked rerun-v2 censoring convention to the dynamics code.

## Scientific reason

The old pipeline sometimes treated `T_max` as if it were an observed readiness time. That is not acceptable for the rerun.

The rerun must distinguish:

```text
T        = first-passage time if readiness is reached; NaN otherwise
T_tilde  = observed time; T if reached, T_max if censored
delta    = event indicator; 1 if reached, 0 if censored
```

This preserves right-censoring and prevents censored trajectories from being misread as real readiness events at `T_max`.

## Files changed

```text
src/run_dynamics_fast.m
src/run_dynamics_fast_edge_uniform.m
```

## Files added

```text
tests/rerun_v2/assert_event_time_fields.m
tests/rerun_v2/test_event_time_fields_agent_first.m
tests/rerun_v2/test_event_time_fields_edge_uniform.m
tests/rerun_v2/run_event_time_tests.m
```

## Agent-first dynamics

`run_dynamics_fast.m` now returns:

- `out.T`
- `out.T_tilde`
- `out.delta`
- `out.converged`

For convergence at `t = 0`:

```text
T = 0
T_tilde = 0
delta = 1
converged = 1
```

For convergence at `t > 0`:

```text
T = t
T_tilde = t
delta = 1
converged = 1
```

For non-convergence:

```text
T = NaN
T_tilde = P.T_max
delta = 0
converged = 0
```

## Edge-uniform dynamics

`run_dynamics_fast_edge_uniform.m` previously initialized `T = P.T_max`. That has been corrected.

It now uses the same event-time convention as the agent-first function.

## Local test command

From the repository root in Octave:

```octave
addpath('src')
addpath('tests/rerun_v2')
run_event_time_tests
```

Expected result:

```text
ALL RERUN V2 EVENT-TIME TESTS PASSED
```

## Why this matters for later steps

The next step will compute manuscript-facing estimands from `T_tilde` and `delta`:

- RMST from `T_tilde`;
- readiness probability from `delta`;
- event-time quantiles only when enough events are observed.

This step must pass locally before any new simulations are run.
