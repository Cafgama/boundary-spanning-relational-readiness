# Step 32 — Final artifact package for manuscript production

## Purpose

This step organizes the rerun_v2 computational outputs into a manuscript-facing artifact package.

The step does **not** run simulations and does **not** recompute statistics. It only checks whether the expected handovers, CSVs, and figure files exist locally, and then writes a Markdown index that can be used by the manuscript-writing track.

## Files added

- `scripts/rerun_v2/build_final_artifact_index.py`
- `tests/rerun_v2/test_final_artifact_index.py`
- `docs/step32_final_artifact_package.md`

## Output generated locally

When run successfully, the script writes:

- `docs/final_artifact_index.md`

## What the index contains

The generated index lists:

1. master and source handovers;
2. final-core tables and figure-data CSVs;
3. translation-grid tables and figure-data CSVs;
4. workload-grid tables and figure-data CSVs;
5. mini-heatmap tables, matrix CSVs, and figure files;
6. selection-rule robustness tables and figure-data CSVs;
7. threshold-robustness tables and figure-data CSVs;
8. a recommended manuscript package mapping each result block to likely main-text or appendix placement.

## Recommended manuscript package

The script records the following recommended package:

| Placement | Candidate table/figure | Primary artifact | Role |
|---|---|---|---|
| Main text | Conceptual architecture schematic | To be drawn separately | Model/design explanation |
| Main text | Final core mechanism table or compact interval plot | `final_core_contrasts.csv` | Core mechanism decomposition |
| Main text | Translation grid line/table | `translation_grid_condition_estimands.csv` | Translation-capability mechanism |
| Main text | Workload grid line/table | `workload_grid_condition_estimands.csv` | Role-capacity mechanism |
| Main text | Mini heatmap | `mini_heatmap_rmst_heatmap.pdf` | Reader-facing design-map synthesis |
| Appendix/robustness | Selection-rule robustness table | `selection_rule_contrasts.csv` | Actor-capacity robustness |
| Appendix/robustness | Threshold-robustness table | `threshold_contrasts.csv` | Readiness-threshold robustness |

## Interpretation guardrails

- The dependent variable remains time to relational coordination readiness.
- Censored trajectories are not converted into artificial event times.
- The mini heatmap is a visual design map, not an independently bootstrapped causal test.
- Claims must remain at the level of relational delay risk and readiness.
- This packaging step does not change any scientific result.

## Commands

From PowerShell:

```powershell
cd C:\Users\cafga\boundary-spanning-relational-readiness
git pull
python tests\rerun_v2\test_final_artifact_index.py
python scripts\rerun_v2\build_final_artifact_index.py --strict
```

Expected test output:

```text
ALL RERUN V2 FINAL ARTIFACT INDEX TESTS PASSED
```

Expected index-builder output:

```text
RERUN V2 FINAL ARTIFACT INDEX PASSED
missing required artifacts: 0
```

If strict mode fails because an expected artifact is missing, rerun the corresponding export or figure-generation script, then rerun the artifact index builder.

## Completion criterion

Step 32 is complete when:

- the Python test passes;
- `build_final_artifact_index.py --strict` passes with zero missing required artifacts;
- `docs/final_artifact_index.md` exists and lists the manuscript package.
