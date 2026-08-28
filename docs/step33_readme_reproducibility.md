# Step 33 — README and reproducibility documentation

## Purpose

This step adds the repository-level reproducibility layer for the rerun_v2 computational track.

The goal is to make the repository understandable to a future reader who wants to know:

- what the model studies;
- what the dependent variable is;
- which branch contains the validated rerun_v2 pipeline;
- how to install Python dependencies;
- how to run Octave tests;
- how to regenerate production simulations;
- how to export manuscript-facing data;
- how to generate the mini heatmap figure;
- how to build the final artifact index;
- which claims are allowed and which claims are outside the computational design.

## Files added

- `README.md`
- `requirements.txt`
- `tests/rerun_v2/test_repository_reproducibility_docs.py`

## README scope

The README explicitly states that the dependent variable is time to relational coordination readiness, not R&D performance, innovation output, patents, project completion, financial value, or scientific quality.

It identifies the six validated manuscript-facing blocks:

1. final core mechanism;
2. translation-capability grid;
3. boundary-spanner workload grid;
4. mini heatmap synthesis;
5. selection-rule robustness;
6. readiness-threshold robustness.

It gives the main commands for:

- installing Python packages;
- setting Octave paths;
- running test suites;
- running production simulations;
- exporting manuscript-facing handovers and CSVs;
- generating the mini heatmap figure;
- building the final artifact index.

## Python dependencies

The repository now includes:

```text
requirements.txt
```

with:

```text
numpy
pandas
matplotlib
```

These are sufficient for the current Python scripts in `scripts/rerun_v2/`.

## Test

The new smoke test is:

```powershell
python tests\rerun_v2\test_repository_reproducibility_docs.py
```

Expected output:

```text
ALL RERUN V2 REPRODUCIBILITY DOC TESTS PASSED
```

## Run instructions for Carlos

From PowerShell:

```powershell
cd C:\Users\cafga\boundary-spanning-relational-readiness
git pull
python tests\rerun_v2\test_repository_reproducibility_docs.py
```

Then optionally confirm that the artifact index still passes:

```powershell
python tests\rerun_v2\test_final_artifact_index.py
python scripts\rerun_v2\build_final_artifact_index.py --strict
```

## Status

After this step, the repository has a public-facing README and a minimal reproducibility test that checks the presence of the main commands, guardrails, and Python dependencies.
