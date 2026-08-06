# Step 2 — Generator tests first

Branch: `rerun/balanced-survival-bootstrap`

Base state protected in Step 1. This step adds structural tests only. No model source code was changed.

## Purpose

The rerun requires the network generator to satisfy stricter architectural rules before any production simulation is rerun.

The tests added here encode the locked rules for:

- Random bridging (RB) as the reference architecture;
- balanced single-responsibility boundary spanning (BS);
- matched RB-BS within-module network generation;
- identical BS-low and BS-high networks under the same graph seed.

## New files

```text
tests/rerun_v2/setup_rerun_v2_tests.m
tests/rerun_v2/assert_no_duplicate_rows.m
tests/rerun_v2/assert_balanced_bs_network.m
tests/rerun_v2/test_RB_exact_k.m
tests/rerun_v2/test_BS_balanced_single_responsibility.m
tests/rerun_v2/test_matched_network_invariants.m
tests/rerun_v2/test_BS_low_high_identical_network.m
tests/rerun_v2/run_generator_tests.m
```

## What the tests check

### RB tests

- exact cross-boundary tie count equals `k`;
- no duplicate cross-boundary ties;
- cross-boundary endpoints belong to different modules;
- RB ties have `edge_type = 2`;
- fixed seed reproduces the same RB network.

### BS tests

- exact cross-boundary tie count equals `k`;
- every cross-boundary BS tie has exactly one boundary-spanner endpoint;
- the opposite endpoint is non-BS;
- BS ties have `edge_type = 3`;
- when `k` is even, `k/2` relationships are assigned to university-side spanners and `k/2` to industry-side spanners;
- assigned workload differs by at most one within each side;
- total assigned workload equals `k`;
- expected maximum load is checked for `b = 1, 2, 4, 6`.

### Matched-design tests

- matched RB and BS graphs generated from the same seed have identical within-module adjacency;
- RB and BS both have exactly `k` cross-boundary ties;
- BS-low and BS-high have identical complete networks under the same graph seed.

## Expected behavior before Step 3

These tests are intentionally stricter than the old smoke tests.

Expected old-code behavior:

- `test_RB_exact_k` should pass or mostly pass.
- `test_matched_network_invariants` should pass if internal graph generation remains aligned under common seeds.
- `test_BS_low_high_identical_network` should pass because `pi_BS` is not used by network generation.
- `test_BS_balanced_single_responsibility` is expected to fail against the old generator.

The expected BS failure is scientifically useful. It confirms that the test detects the old at-least-one-spanner rule, which is not the locked balanced single-responsibility rule.

## How to run locally

From the repository root:

```bash
git checkout rerun/balanced-survival-bootstrap
octave --path src --path tests/rerun_v2 --eval "run_generator_tests"
```

Alternative:

```bash
cd tests/rerun_v2
octave --eval "run_generator_tests"
```

## Execution note

The assistant environment used for this step does not have GNU Octave installed, so the tests were added but not executed here. Carlos should run the command above locally. The first diagnostic to inspect is whether the BS balanced single-responsibility test fails for the expected reason.

## Next decision gate

Before modifying `src/generate_network.m`, we must lock the balanced-allocation algorithm in pseudocode:

1. how boundary spanners are selected;
2. how side responsibility is split;
3. how workloads are assigned within each side;
4. how non-BS opposite endpoints are selected;
5. how duplicates are avoided;
6. under which parameter combinations the algorithm can fail.
