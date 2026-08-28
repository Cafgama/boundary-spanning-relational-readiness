# Step 34 — Computational track closure

## Purpose

This step closes the rerun_v2 computational track and creates a concise bridge back to manuscript writing.

The closure document is not a new analysis. It checks that the required manuscript-facing artifacts are present and that the main interpretation guardrails remain explicit.

## Files added

- `scripts/rerun_v2/build_computational_closure.py`
- `tests/rerun_v2/test_computational_closure.py`
- `docs/step34_computational_track_closure.md`

## Generated local output

When run locally, the closure builder writes:

- `docs/computational_track_closure.md`

## Required local prerequisites

The closure builder assumes that the previous steps have already generated:

- `docs/manuscript_results_handover.md`
- `docs/final_artifact_index.md`
- `figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.pdf`
- `figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.png`
- `figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap_caption.txt`
- `README.md`
- `requirements.txt`

## Commands

From PowerShell:

```powershell
cd C:\Users\cafga\boundary-spanning-relational-readiness
git pull
python tests\rerun_v2\test_computational_closure.py
python scripts\rerun_v2\build_computational_closure.py --strict
```

Expected test output:

```text
ALL RERUN V2 COMPUTATIONAL CLOSURE TESTS PASSED
```

Expected closure output:

```text
RERUN V2 COMPUTATIONAL TRACK CLOSURE PASSED
```

## Closure criteria

The computational track is closed when:

1. all six evidence blocks are represented in `docs/manuscript_results_handover.md`;
2. `docs/final_artifact_index.md` reports zero missing required artifacts;
3. the mini heatmap figure files are present;
4. the README and `requirements.txt` exist;
5. the closure document reports zero missing required artifacts and zero phrase-check warnings.

## Interpretation guardrails preserved

The closure script checks that the project still explicitly states the most important guardrails:

- the endpoint is time to relational coordination readiness;
- the results are not R&D performance or innovation success;
- censored trajectories are not converted into artificial event times;
- the mini heatmap is a visual design map, not independently bootstrapped causal evidence.

## Next step

After Step 34 passes, the computational track can be handed back to the manuscript-writing track. Any additional computational work should be treated as a new extension rather than as a prerequisite for the current manuscript package.
