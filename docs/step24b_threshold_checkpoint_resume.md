# Step 24b — Checkpoint/resume threshold robustness

## Purpose

Step 24b replaces the long single-save threshold-robustness run with a checkpointed runner.

The previous production attempt was interrupted by a Windows restart before final files were written. The original script saved the final `.mat` and manifest only at the end, so a mid-run restart could lose the whole run. The checkpointed runner saves after each threshold scenario and after each bootstrap contrast.

## New script

```text
experiments/rerun_v2/run_readiness_threshold_checkpointed.m
```

## What is checkpointed

The script saves one scenario checkpoint for each scenario:

```text
scenario_easier_tie.mat
scenario_baseline.mat
scenario_easier_boundary.mat
scenario_harder_boundary.mat
scenario_harder_tie.mat
```

It also saves one bootstrap checkpoint for each threshold contrast:

```text
bootstrap_easier_tie_BS_low_minus_easier_tie_BS_high.mat
bootstrap_baseline_BS_low_minus_baseline_BS_high.mat
bootstrap_easier_boundary_BS_low_minus_easier_boundary_BS_high.mat
bootstrap_harder_boundary_BS_low_minus_harder_boundary_BS_high.mat
bootstrap_harder_tie_BS_low_minus_harder_tie_BS_high.mat
```

The checkpoint files are stored under:

```text
results/processed/rerun_v2/threshold_robustness_checkpointed/checkpoints/
```

## Resume behavior

When the script starts, it checks for existing scenario checkpoint files.

- If a scenario checkpoint exists, the script loads it and skips that scenario simulation.
- If a scenario checkpoint does not exist, the script runs that scenario and saves it immediately.
- After all scenario checkpoints are available, it computes or loads bootstrap checkpoints.
- If interrupted again, rerunning the same command resumes from the last complete checkpoint.

## Output folders

The checkpointed production writes to a separate output tag:

```text
results/raw/rerun_v2/threshold_robustness_checkpointed/
results/processed/rerun_v2/threshold_robustness_checkpointed/
```

This avoids confusion with the interrupted empty folders:

```text
results/raw/rerun_v2/threshold_robustness/
results/processed/rerun_v2/threshold_robustness/
```

## Test command

Run this first:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('tests/rerun_v2')
addpath('experiments/rerun_v2')
run_threshold_checkpoint_tests
```

Expected result:

```text
ALL RERUN V2 THRESHOLD CHECKPOINT TESTS PASSED
```

## Production command

After the test passes, run:

```octave
cd('C:/Users/cafga/boundary-spanning-relational-readiness')
addpath('src')
addpath('experiments/rerun_v2')
run_readiness_threshold_checkpointed
```

If Windows restarts again, run the same command again. The script should skip completed scenario checkpoints and resume.

## Final output files

When all scenarios and bootstraps are complete, the script writes:

```text
results/raw/rerun_v2/threshold_robustness_checkpointed/threshold_checkpointed_raw_YYYYMMDD_HHMMSS.mat
results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_checkpointed_processed_YYYYMMDD_HHMMSS.mat
results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_checkpointed_manifest_YYYYMMDD_HHMMSS.txt
```

## Notes

- Diagnostic alerts can occur in this robustness block, especially in `harder_tie`.
- Alerts do not necessarily indicate code failure. They may indicate limited estimability under stricter thresholds.
- Censored trajectories remain censored and are not converted into artificial event times.
