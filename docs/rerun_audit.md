# Rerun audit — Step 0

Repository: `Cafgama/boundary-spanning-relational-readiness`

Audit branch created after this audit: `rerun/balanced-survival-bootstrap`

Audited base commit: `68d25a46ca94d9aaf6c52aab6b494346d4e165cc`

Date: 2026-08-06

## Purpose

This document records the Step 0 repository audit for the balanced single-responsibility rerun of the boundary-spanning relational-readiness model. No model code was changed during Step 0.

The rerun is governed by the computational handover. The main locked decisions are:

- Random bridging (RB) is the main reference architecture.
- Modular benchmark (MB) is retained only as an appendix calibration benchmark.
- Boundary spanning (BS) must use balanced single-responsibility allocation.
- Agent-first interaction selection is the baseline.
- Manuscript-facing estimands are RMST, readiness probability, and estimable event-time quantiles.
- Censored trajectories must not be converted into artificial event times.
- Bootstrap must be hierarchical and paired across graphs and trajectories.
- Old results must be preserved.

## Current repository structure

The README describes an intended structure using `src/octave/`, `src/python/`, `scripts/`, `config/`, `docs/`, `seeds/`, `results/reference_results/`, and `figures/`.

The actual repository currently uses:

```text
experiments/
figures/
figures/Old/
figures/paper/
python/
python/.ipynb_checkpoints/
results/checkpoints/
results/figure_data/
results/processed/
results/raw/
results/table_data/
src/
tables/
tests/
```

This mismatch means the README is not yet a reliable reproduction guide.

A repository hygiene issue was also identified: the repository contains `.gitignore.txt` rather than `.gitignore`, so ignore rules are probably not active. Generated outputs, checkpoints, figures, notebook checkpoints, and `.mat` results are tracked in GitHub. This should be fixed later, after preserving the old state.

## Network generation files

Main file:

```text
src/generate_network.m
```

Supporting wrapper:

```text
src/safe_generate_network.m
```

Duplicate local wrapper:

```text
src/run_single_experiment.m
```

### RB generation

RB is generated inside `add_random_bridging_edges()` in `src/generate_network.m`. It samples exactly `P.k` university-industry pairs uniformly without replacement and assigns them as ordinary cross-boundary ties. This is broadly aligned with the locked RB definition.

### BS generation

BS is generated inside `add_boundary_spanning_edges()` in `src/generate_network.m`.

The current rule is:

```text
select BU and BI
allow candidate pair if u is in BU OR i is in BI
sample k candidate pairs uniformly
```

This only guarantees that each cross-boundary tie involves at least one boundary spanner. It does not guarantee the new locked design:

- exactly one boundary-spanner endpoint per cross-boundary BS tie;
- opposite endpoint must be non-BS;
- k/2 assigned relationships from university-side spanners when k is even;
- k/2 assigned relationships from industry-side spanners when k is even;
- assigned loads distributed as evenly as possible;
- realized workload diagnostics recorded.

Therefore `src/generate_network.m` must be refactored after tests are written.

## Dynamics and readiness files

Relevant files:

```text
src/run_dynamics_fast.m
src/run_dynamics_fast_edge_uniform.m
src/compute_readiness.m
```

`src/run_dynamics_fast.m` implements the agent-first baseline and correctly returns `T = NaN` and `converged = 0` for non-converged trajectories. This is aligned with the new censoring rule, although we still need explicit manuscript-facing fields such as `T_tilde` and `delta`.

`src/run_dynamics_fast_edge_uniform.m` currently initializes `T = P.T_max`, so non-converged edge-uniform trajectories can be returned with `T_max` as if it were an event time. This is incompatible with the rerun design and must be corrected before robustness runs.

`src/compute_readiness.m` computes readiness only over `EB`, the cross-boundary edge list. This is conceptually aligned, but stronger tests should verify that `EB` contains only cross-boundary ties.

## Time summaries and percentile files

Relevant files:

```text
src/summarize_results.m
src/summarize_by_graph.m
src/graph_level_summary_from_results.m
src/graph_metric_vector_from_results.m
src/process_raw_result_file.m
```

Current summaries use two old families of statistics:

- converged-only event times;
- censored statistics that substitute `T_max` for non-converged runs.

The rerun requires manuscript-facing pooled marginal estimands:

- RMST = mean observed time `T_tilde`;
- readiness probability = mean `delta`;
- event-time quantiles only when estimable;
- no substitution of `T_max` as an observed event quantile;
- no averaging of graph-specific medians or graph-specific percentiles for manuscript estimates.

Therefore the old graph-level summary and figure-data functions must be treated as old-pipeline functions until replaced.

## Bootstrap files

Current files:

```text
src/paired_bootstrap_difference.m
src/bootstrap_graph_difference.m
src/compare_graph_metric.m
```

These functions bootstrap graph-level vectors or paired graph-level summaries. They are useful for the old pipeline but do not implement the locked hierarchical paired bootstrap.

The rerun requires a new bootstrap that samples:

1. matched graph identifiers with replacement;
2. matched trajectory identifiers within each selected graph with replacement;
3. the same sampled indices across conditions in a focal comparison.

The bootstrap estimand function must compute pooled marginal RMST, readiness probability, and estimable event-time quantiles.

## Experiment scripts

Current experiment scripts:

```text
experiments/run_debug_baseline.m
experiments/run_full_baseline.m
experiments/run_pilot_baseline.m
experiments/run_resumable_architecture.m
experiments/run_resumable_mechanism_condition.m
experiments/run_resumable_translation_condition.m
experiments/run_resumable_load_condition.m
experiments/run_resumable_selection_rule_condition.m
experiments/run_resumable_threshold_condition.m
experiments/export_existing_graph_summaries.m
experiments/analyze_graph_level_comparison.m
experiments/build_figure_data_csvs.m
experiments/build_table_data_csvs.m
```

Most scripts write to unversioned folders such as `results/raw/`, `results/processed/`, and `results/checkpoints/`. For the rerun, new outputs must go to versioned paths such as `results/raw/rerun_v2/`, `results/processed/rerun_v2/`, and `results/figure_data/rerun_v2/`.

The current scripts do not store a complete manifest with graph seeds, trajectory seeds, code commit, workload diagnostics, `T_tilde`, and `delta`.

`experiments/build_figure_data_csvs.m` also contains hard-coded locked Figure 03 values. The rerun figure-data layer should be generated only from versioned processed outputs.

## Existing tests

Current tests include:

```text
tests/run_all_tests.m
tests/run_test_file.m
tests/test_params.m
tests/test_network_generation.m
tests/test_compute_readiness.m
tests/test_dynamics_small.m
tests/test_dynamics_fast.m
tests/test_dynamics_edge_uniform.m
tests/test_single_experiment.m
tests/test_summarize_results.m
tests/test_export_summary_csv.m
tests/test_graph_summary.m
tests/test_process_raw_results.m
tests/test_paired_bootstrap_difference.m
tests/test_compare_graph_metric.m
tests/test_configure_mechanism_condition.m
```

The existing network-generation tests check basic validity and the old condition that each BS tie involves at least one spanner. They do not test the new balanced single-responsibility requirement.

Required new tests include:

- RB exact-k tests;
- BS exactly-one-spanner-endpoint tests;
- BS non-spanner opposite endpoint tests;
- k/2 responsibility split tests;
- balanced workload tests;
- BS-low and BS-high identical adjacency tests;
- matched graph and trajectory seed tests;
- event-time censoring tests with `T`, `T_tilde`, and `delta`;
- pooled marginal metric tests;
- hierarchical paired bootstrap toy-data tests.

## Obsolete, duplicated, or incompatible paths

Likely old-pipeline or deprecated after rerun:

```text
src/graph_level_summary_from_results.m
src/graph_metric_vector_from_results.m
src/summarize_by_graph.m
experiments/analyze_graph_level_comparison.m
experiments/export_existing_graph_summaries.m
experiments/build_figure_data_csvs.m
```

Duplicate wrapper:

```text
src/safe_generate_network.m
src/run_single_experiment.m local safe_generate_network()
```

Main incompatibilities:

- BS generator uses at-least-one-spanner logic instead of exactly-one balanced responsibility.
- Censored trajectories are still substituted with `T_max` in percentile calculations.
- Graph-level medians and percentiles are averaged for old outputs.
- Bootstraps are graph-level rather than hierarchical graph-trajectory bootstraps.
- Edge-uniform dynamics returns `T_max` for non-convergence.
- Result folders are not versioned by rerun.
- Full manifests are missing.
- Workload diagnostics are missing.

## Files expected to change later

Not changed in Step 0.

Expected additions or edits in later steps:

```text
src/generate_network.m
src/run_dynamics_fast.m
src/run_dynamics_fast_edge_uniform.m
src/compute_event_time_estimands.m
src/hierarchical_paired_bootstrap.m
src/create_rerun_manifest.m
src/validate_boundary_spanning_network.m
experiments/rerun_v2/*.m
tests/test_network_generation_balanced_bs.m
tests/test_event_time_metrics.m
tests/test_hierarchical_paired_bootstrap.m
tests/test_manifest_reproducibility.m
```

## Smallest safe sequence of changes

1. Protect old state by creating the rerun branch and versioned folders.
2. Add this audit and a manifest template.
3. Write tests for the new generator requirements before changing the generator.
4. Run tests against old code and confirm expected failures.
5. Discuss and lock the balanced-allocation algorithm.
6. Implement balanced BS generation.
7. Add `T_tilde` and `delta` fields.
8. Implement pooled marginal estimands.
9. Implement hierarchical paired bootstrap.
10. Run smoke tests before any production simulation.

## Step 0 conclusion

The repository is a useful prototype, but the current computational pipeline is not aligned with the locked rerun design. The biggest issues are the BS generator, censored percentile logic, old graph-level estimands, and non-hierarchical bootstrap. The next step is Step 1: protect the old computational state before modifying scientific code.
