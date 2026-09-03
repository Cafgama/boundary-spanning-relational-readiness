# E4 results — out-of-sample learning-timescale validation

## Status

**Closed.** The preregistered E4 production run used `R=200` per cell and completed successfully in GitHub Actions run `33808674936`.

The frozen pre-E4-evaluation checkpoint is:

`lock/scarce-capacity-learning-timescale-preE4-eval`

E4 changes the learning rate `alpha` while holding the structural allocation fixed. The primary out-of-sample values are `alpha in {0.06, 0.10, 0.12}`; `alpha=0.08` is a bridge to E3.

## Primary out-of-sample predictive performance

Across the 63 primary **uniform-capacity** OOS cells, Model v0.8 achieved:

- Pearson correlation for mean first-passage time: **0.995118**
- MAE for mean first-passage time: **2.20587 attempts**
- RMSE for mean first-passage time: **3.29590 attempts**
- Pearson correlation for mean capacity delay: **0.991759**
- MAE for mean capacity delay: **1.58802 attempts**
- RMSE for mean capacity delay: **3.02760 attempts**

No parameter was fit to E4.

By learning rate, the delay correlations were:

- `alpha=0.06`: **0.996576**
- `alpha=0.10`: **0.997267**
- `alpha=0.12`: **0.875949**

The lower correlation at `alpha=0.12` occurs in a regime where predicted and observed delays are mostly near zero, so absolute errors remain small (MAE **1.41221**, RMSE **2.40654**).

## Regime reversals

### h = 13/15

Uniform capacity changes from strongly bottlenecked under slow learning to effectively safe under faster learning.

Averaged over `Omega in {0.6,1.0,1.5}`, mean paired delays were approximately:

- `alpha=0.06`: **44.90**
- `alpha=0.08`: **44.71**
- `alpha=0.10`: **1.47**
- `alpha=0.12`: **0**

This follows the preregistered movement of `Psi` from above one to below one.

### h = 14/15

The E3 stochastic knife-edge becomes deterministic under slow learning and disappears under faster learning.

Average mean paired delays over the three Omega values:

- `alpha=0.06`: **46.02**
- `alpha=0.08`: **13.46**
- `alpha=0.10`: **0.052**
- `alpha=0.12`: **0**

This supports the interpretation of the E3 knife-edge as a finite-window boundary layer anchored to the deterministic timescale gate rather than to a special value of concentration.

### h = 1 exact endpoint

The preregistered exact regime reversal was reproduced in all replications.

For `alpha=0.06`:

- `Omega=0.6`: `DeltaT = 21`
- `Omega=1.0`: `DeltaT = 45`
- `Omega=1.5`: `DeltaT = 75`

For `alpha in {0.08,0.10,0.12}`, `DeltaT=0` at all three Omega values.

Thus maximum concentration can be either perfectly safe or deterministically bottlenecked without changing responsibility, capacity, or demand allocation; only the learning timescale changes.

## Matched-capacity residual

Matched capacity has no deterministic mismatch penalty in the fluid model, but finite-window sampling can still cause delay.

Across OOS matched cells, the overall mean delay residual was **0.6953 attempts**. It decreases strongly with faster learning:

- `alpha=0.06`: mean cell delay **4.64**
- `alpha=0.10`: **0.246**
- `alpha=0.12`: **0.060**

This is consistent with a stochastic boundary correction that becomes negligible when readiness moves farther from exhaustion.

## Interpretation

E4 provides an out-of-sample validation of the central timescale claim:

> capacity mismatch does not determine readiness delay by itself; its effect depends on whether local exhaustion occurs before or after the learning process reaches the readiness scale.

The structural coordinate `Lambda` determines local mismatch, `chi=Omega*Lambda` determines whether exhaustion is encountered within a window, and `Psi=Lambda*t0/C` orders exhaustion relative to nominal learning. Model v0.8 uses the complete active-set sequence to determine post-onset delay amplitude.

## Provenance

Official artifact: `e4-learning-timescale-screening`

GitHub Actions run: `33808674936`

The immutable raw and full processed E4 CSVs remain in the workflow artifact. The preregistered OOS metrics are committed in `results/processed/e4_oos_metrics.csv`.
