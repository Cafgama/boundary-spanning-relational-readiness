# Step 24 — Readiness-threshold robustness production

## Purpose

Step 24 tests whether the translation-capability mechanism remains robust when the readiness criteria are changed.

The model has two readiness thresholds:

- `theta`: tie-level relational-confidence threshold;
- `q`: boundary-level readiness proportion threshold.

## New production script

```text
experiments/rerun_v2/run_readiness_threshold_robustness.m
```

## Default production design

```text
NG = 50
NT = 50
T_max = 50000
n_boot = 10000
pi_out = 0.55
pi_BS_low = 0.55
pi_BS_high = 0.65
architecture = boundary_spanning
selection_rule = agent_first
```

## Threshold scenarios

| Scenario | theta | q | Interpretation |
|---|---:|---:|---|
| `easier_tie` | 0.75 | 0.80 | Easier tie-level readiness |
| `baseline` | 0.80 | 0.80 | Baseline readiness criteria |
| `easier_boundary` | 0.80 | 0.70 | Easier boundary-level readiness |
| `harder_boundary` | 0.80 | 0.90 | Harder boundary-level readiness |
| `harder_tie` | 0.85 | 0.80 | Harder tie-level readiness |

For each scenario, the script runs:

```text
<scenario>_BS_low
<scenario>_BS_high
```

## Contrasts

The script computes one paired hierarchical bootstrap contrast per scenario:

```text
<scenario>_BS_low_minus_<scenario>_BS_high
```

For time metrics, positive values mean that `BS_high` is faster/lower than `BS_low`.

## Diagnostic logic

This run may generate diagnostic alerts under very hard readiness thresholds. Those alerts are not automatically code failures. They tell us whether all quantiles remain estimable.

Interpretation rule:

- if the scenario is fully estimable, interpret RMST and quantile contrasts;
- if upper-tail quantiles are not estimable, interpret RMST and readiness probability and report the estimability limitation.

No censored trajectory is converted into an artificial event time.

## Outputs

The production script writes:

```text
results/raw/rerun_v2/threshold_robustness/
results/processed/rerun_v2/threshold_robustness/
```

## New tests

```text
tests/rerun_v2/test_readiness_threshold_robustness.m
tests/rerun_v2/run_threshold_robustness_tests.m
```

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_threshold_robustness_tests
```

Expected result:

```text
ALL RERUN V2 READINESS-THRESHOLD ROBUSTNESS TESTS PASSED
```

## Production command

After tests pass:

```octave
run_readiness_threshold_robustness
```

Expected final message:

```text
RERUN V2 READINESS-THRESHOLD ROBUSTNESS PASSED
```

## Expected runtime

This run has:

```text
10 conditions x 50 graphs x 50 trajectories = 25,000 trajectories
5 contrasts x 10,000 bootstrap replications
```

Practical estimate:

```text
7 to 11 hours likely
up to 14 hours conservatively
```
