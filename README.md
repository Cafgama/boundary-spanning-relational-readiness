# Boundary-spanning relational readiness

Simulation code and analysis workflow for a computational study of boundary-spanning role design and relational-readiness delay in modular R&D collaborations.

The model studies how cross-boundary interaction architecture, translation capability, and boundary-spanner workload affect the time required for a collaboration network to reach relational coordination readiness. The dependent variable is time to relational coordination readiness, not R&D performance, innovation output, patents, project completion, financial value, or scientific quality.

## Repository status

This branch contains the validated `rerun_v2` computational pipeline. The current working branch is:

```bash
rerun/balanced-survival-bootstrap
```

The computational evidence base is organized around six manuscript-facing blocks:

1. final core mechanism;
2. translation-capability grid;
3. boundary-spanner workload grid;
4. mini heatmap synthesis;
5. selection-rule robustness;
6. readiness-threshold robustness.

The master handover is generated at:

```text
docs/manuscript_results_handover.md
```

The final artifact index is generated at:

```text
docs/final_artifact_index.md
```

## Software requirements

The simulation pipeline uses GNU Octave. The figure and artifact-index utilities use Python.

Tested locally with:

- GNU Octave 10.3.0;
- Python 3.13;
- `numpy`;
- `pandas`;
- `matplotlib`.

Install Python dependencies with:

```bash
python -m pip install -r requirements.txt
```

On Windows, if `python` is not recognized, try `py` instead.

## Quick start

From PowerShell or a terminal:

```powershell
cd C:\Users\cafga\boundary-spanning-relational-readiness
git branch --show-current
git pull
```

The branch should be `rerun/balanced-survival-bootstrap`.

## Octave setup

In GNU Octave:

```octave
clear
clc
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
```

## Smoke and validation tests

The following tests check the rerun_v2 components without rerunning the full production simulations:

```octave
run_generator_tests
run_event_time_tests
run_estimand_tests
run_bootstrap_tests
run_smoke_tests
run_pilot_tests
run_diagnostic_tests
run_high_horizon_tests
run_final_core_tests
run_final_export_tests
run_translation_grid_tests
run_translation_export_tests
run_workload_grid_tests
run_workload_export_tests
run_selection_rule_tests
run_selection_export_tests
run_threshold_checkpoint_tests
run_threshold_export_tests
run_mini_heatmap_tests
run_manuscript_handover_tests
```

Python-side tests:

```powershell
python tests\rerun_v2\test_mini_heatmap_figure_script.py
python tests\rerun_v2\test_final_artifact_index.py
python tests\rerun_v2\test_repository_reproducibility_docs.py
```

## Main production runs

The production simulations are computationally expensive. Run them only when results need to be regenerated.

In Octave:

```octave
run_final_core_production
run_translation_grid_production
run_workload_grid_production
run_selection_rule_robustness
run_readiness_threshold_checkpointed
run_mini_heatmap_production
```

Approximate observed runtimes on the local Windows machine used in the project:

| Block | Approximate runtime |
|---|---:|
| Final core | 3.9 h |
| Translation grid | 4.4 h |
| Workload grid | 3.5 h |
| Selection-rule robustness | 4.5 h |
| Readiness-threshold checkpointed robustness | 40.7 h |
| Mini heatmap | 11.8 h |

The threshold robustness run is checkpointed by scenario to reduce restart risk.

## Export manuscript-facing results

After production runs, export the clean CSVs and handover files:

```octave
analyze_final_core_results
repair_final_core_handover_filename
analyze_translation_grid_results
analyze_workload_grid_results
analyze_selection_rule_results
analyze_threshold_checkpointed_results
analyze_mini_heatmap_results
build_manuscript_results_handover
```

The exports write to:

```text
results/processed/rerun_v2/...
results/figure_data/rerun_v2/...
docs/*_results_handover.md
```

The master handover consolidates the individual handovers:

```text
docs/manuscript_results_handover.md
```

## Generate the mini heatmap figure

The mini heatmap uses RMST as the cell value and visually integrates translation capability and boundary-spanner workload.

```powershell
python scripts\rerun_v2\plot_mini_heatmap.py
```

Expected outputs:

```text
figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.png
figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.pdf
figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap_caption.txt
```

## Build the final artifact index

After all exports and figures are available, build the final local artifact index:

```powershell
python scripts\rerun_v2\build_final_artifact_index.py --strict
```

Expected result:

```text
missing required artifacts: 0
RERUN V2 FINAL ARTIFACT INDEX PASSED
```

Output:

```text
docs/final_artifact_index.md
```

## Output policy

Large raw and processed simulation outputs are generated locally under `results/`. This repository keeps the folder structure using `.gitkeep` files. Before public release, decide whether large `.mat`, `.csv`, and figure outputs should be committed, archived through a release, or deposited in an external repository.

## Interpretation guardrails

Use the computational results to support statements about relational-readiness delay only.

Do not claim that the model demonstrates improvements in:

- R&D performance;
- innovation quality;
- patenting;
- financial value;
- project completion;
- scientific output quality.

Censored trajectories must not be converted into artificial event times. RMST is based on observed `T_tilde`; event quantiles are reported only when estimable. Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers. The mini heatmap is a visual design map and should not be described as independently bootstrapped causal evidence.

## Suggested manuscript package

Main text:

- final core mechanism;
- translation-capability grid;
- workload/capacity grid;
- mini heatmap synthesis.

Appendix or robustness section:

- selection-rule robustness;
- readiness-threshold robustness.

For the complete manuscript-facing evidence bridge, see:

```text
docs/manuscript_results_handover.md
```
