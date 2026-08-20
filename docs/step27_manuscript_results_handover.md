# Step 27 — Master computational handover for the manuscript

## Purpose

Step 27 consolidates the completed rerun_v2 computational evidence into one manuscript-facing handover document:

```text
docs/manuscript_results_handover.md
```

This step does not run simulations and does not recompute statistics. It reads the validated source handovers already produced by the analysis/export steps and writes a master synthesis for the writing track.

## New script

```text
experiments/rerun_v2/build_manuscript_results_handover.m
```

Usage:

```octave
build_manuscript_results_handover
```

## Required source handovers

The builder expects these files to exist under `docs/`:

```text
docs/final_core_results_handover.md
docs/translation_grid_results_handover.md
docs/workload_grid_results_handover.md
docs/selection_rule_results_handover.md
docs/threshold_robustness_results_handover.md
```

These files are generated locally by the previous export scripts. If any file is missing, rerun the corresponding export script before building the master handover.

## What the master handover contains

The generated document includes:

1. computational scope completed;
2. master claim map;
3. non-negotiable interpretation guardrails;
4. recommended manuscript placement;
5. figure-data and table-data path checklist;
6. claims ready for the writing track;
7. claims not supported by the computational design;
8. source handovers appended verbatim.

The verbatim appendices preserve the final numerical values, confidence intervals, diagnostic alerts, and exported file paths.

## New tests

```text
tests/rerun_v2/test_manuscript_handover_builder.m
tests/rerun_v2/run_manuscript_handover_tests.m
```

The test uses synthetic source handovers. It does not run simulations.

## Local validation command

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_manuscript_handover_tests
```

Expected result:

```text
ALL RERUN V2 MANUSCRIPT HANDOVER TESTS PASSED
```

## Real master handover command

After the test passes and all five source handovers exist, run:

```octave
build_manuscript_results_handover
```

Expected result:

```text
RERUN V2 MANUSCRIPT RESULTS HANDOVER PASSED
```

Then inspect:

```text
docs/manuscript_results_handover.md
```

## Interpretation guardrails carried into the master handover

- The dependent variable is time to relational coordination readiness, not R&D performance, innovation success, patents, project completion, or financial value.
- Censored trajectories are not converted into artificial event times.
- RMST uses observed time `T_tilde`; event quantiles are reported only when estimable.
- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.
- `agent_first` remains the baseline model; `edge_uniform` is robustness.
- The hardest tie-readiness threshold has non-estimable low-translation event quantiles and must be written as a bounded/censoring result.

## Next computational step after Step 27

After `docs/manuscript_results_handover.md` is generated and reviewed, the next step is to create the final manuscript figure/table production layer from the rerun_v2 CSVs.
