# Step 21 — Selection-rule robustness production

## Purpose

Step 21 tests whether the core mechanism depends on the baseline interaction-selection rule.

The baseline model uses **agent-first selection**, where an actor is selected first and then one of its neighbors is selected. This preserves scarce actor attention and allows overloaded boundary spanners to become bottlenecks.

The robustness model uses **edge-uniform selection**, where each edge receives equal activation probability. This weakens the actor-level overload mechanism and therefore helps test whether the bottleneck result is specifically tied to scarce actor-level interaction capacity.

## New script

```text
experiments/rerun_v2/run_selection_rule_robustness.m
```

## Default production design

```text
NG = 50
NT = 50
T_max = 50000
n_boot = 10000
theta = 0.80
q = 0.80
pi_out = 0.55
pi_BS_low = 0.55
pi_BS_high = 0.65
```

## Conditions

The production run includes six conditions:

```text
RB_low_agent_first
RB_low_edge_uniform
BS_low_agent_first
BS_low_edge_uniform
BS_high_agent_first
BS_high_edge_uniform
```

The three base mechanisms are:

```text
RB_low  = random bridging with ordinary cross-boundary success
BS_low  = boundary spanning without translation advantage
BS_high = boundary spanning with translation capability
```

Each is evaluated under both selection rules:

```text
agent_first
edge_uniform
```

## Bootstrap contrasts

The script computes paired hierarchical bootstraps for:

```text
RB_low_agent_first_minus_RB_low_edge_uniform
BS_low_agent_first_minus_BS_low_edge_uniform
BS_high_agent_first_minus_BS_high_edge_uniform
RB_low_edge_uniform_minus_BS_low_edge_uniform
BS_low_edge_uniform_minus_BS_high_edge_uniform
RB_low_edge_uniform_minus_BS_high_edge_uniform
```

The first three compare each mechanism under the two selection rules. The last three reproduce the mechanism decomposition under edge-uniform selection.

## Output folders

Raw outputs:

```text
results/raw/rerun_v2/selection_rule_robustness/
```

Processed outputs:

```text
results/processed/rerun_v2/selection_rule_robustness/
```

The script writes:

```text
selection_rule_raw_YYYYMMDD_HHMMSS.mat
selection_rule_processed_YYYYMMDD_HHMMSS.mat
selection_rule_manifest_YYYYMMDD_HHMMSS.txt
```

## Tests

```text
tests/rerun_v2/test_selection_rule_robustness.m
tests/rerun_v2/run_selection_rule_tests.m
```

The test runs a small version of the pipeline:

```text
NG = 2
NT = 3
T_max = 2000
n_boot = 20
```

This test does not generate manuscript results. It only checks that:

- all six conditions are present;
- each condition has `T`, `T_tilde`, `delta`, and `converged`;
- `converged` equals `delta`;
- all expected bootstrap contrasts exist;
- raw, processed, and manifest files are created.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_selection_rule_tests
```

Expected result:

```text
ALL RERUN V2 SELECTION-RULE ROBUSTNESS TESTS PASSED
```

## Production command

After the test passes:

```octave
run_selection_rule_robustness
```

## Interpretation rule

This robustness step should not be used to replace the baseline model. Its purpose is to clarify the mechanism.

Expected interpretation pattern:

- If `BS_low` is much less penalized under edge-uniform selection, this supports the interpretation that the bottleneck mechanism depends on scarce actor-level interaction capacity.
- If `BS_high` remains faster under edge-uniform selection, this supports the robustness of the translation-capability effect.
- If the edge-uniform results eliminate the concentration penalty while preserving the translation advantage, this strengthens the distinction between **position alone**, **translation capability**, and **capacity/load**.

## Guardrails

- These results still refer only to time to relational coordination readiness.
- Do not interpret edge-uniform selection as the main behavioral model.
- Edge-uniform is a robustness assumption used to test the role of actor-level capacity constraints.
- Censored trajectories are not converted into artificial event times.
- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.
