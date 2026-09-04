# E5 closure — competence switching under scarce interface capacity

## Status

**Closed production experiment.**

Frozen pre-data checkpoint:

`lock/scarce-capacity-competence-switching-preE5`

Production source commit:

`744538c48869b24439125d625c8d180a12bf45a0`

Production workflow run:

`33815992624`

Permanent result archive commit:

`767fa629288f29cca2db7b0fa03695cdd5d3da9e`

The full 38,400-row raw production output is stored permanently in the repository as a gzip archive under `results/raw/e5/`; processed summaries, frozen evaluation cells, metrics, and SHA-256 provenance are stored under `results/processed/e5/` and `results/manifests/e5_production_manifest.txt`.

## 1. Production integrity

The production workflow completed successfully for all eight preregistered concentration slices and the final combine/evaluate job.

The permanent archive contains:

- 38,400 concentrated finite-capacity trajectories;
- 192 stochastic summary cells;
- R = 200 per concentrated cell;
- k in {4,7,8,9,10,11,13,15};
- ell_s in {0.70,0.80,0.90,1.00};
- Omega in {0.6,1.0,1.5};
- matched and uniform capacity policies.

All pathwise invariants remained satisfied in production:

1. competence monotonicity under common random numbers;
2. capacity-constrained first passage cannot precede its paired no-capacity counterfactual;
3. the no-premium case ell_s = ell_o reproduces homogeneous competence exactly.

No stochastic result was used to refit the deterministic threshold or redefine the E5 grid.

## 2. Global deterministic-to-stochastic agreement

Across all 192 cells, the preregistered Model v0.8 deterministic architecture advantage and the stochastic RMST architecture advantage have

- Pearson correlation = 0.9668836378;
- MAE = 5.032342 attempts;
- RMSE = 7.645982 attempts;
- sign agreement = 0.953125 = 183/192 cells.

Thus the deterministic theory predicts not only the qualitative competence-switching structure but also the architecture-ranking sign in more than 95% of the preregistered stochastic cells.

### Matched capacity

For the 96 matched-capacity cells:

- Pearson correlation = 0.9766272553;
- sign agreement = 1.000000.

Every stochastic matched-capacity cell preserves the deterministic prediction that concentration is advantageous over the diffuse ordinary benchmark in this E5 design.

### Uniform capacity

For the 96 uniform-capacity cells:

- Pearson correlation = 0.9137768050;
- sign agreement = 0.90625 = 87/96 cells.

All nine sign disagreements occur under uniform capacity. This is consistent with the interpretation that finite-window stochastic corrections become scientifically relevant when responsibility-capacity mismatch is present.

## 3. Competence-rescuable regime

The preregistered deterministic map contains nine distinct uniform-capacity competence-rescuable architecture cells, each evaluated on the four-point stochastic competence grid.

For these nine cells:

- the exact preregistered coarse switch level is recovered in 6/9 cases;
- mean absolute coarse-grid switching error = 0.0333333 in ell_s;
- all nine cells become favorable to concentration at some preregistered competence level by ell_s = 1.

The three coarse-grid deviations are one grid step (0.1) and occur on both sides of the deterministic root: two stochastic switches occur one step earlier than the deterministic coarse prediction and one occurs one step later.

This supports the competence-switching mechanism while showing that the deterministic threshold should be interpreted as a mean-field regime boundary, not as an exact finite-C stochastic switching point.

## 4. Critical correction: `unrescuable` is not a universal stochastic label

The strongest E5 correction concerns the preregistered deterministic label `unrescuable`.

There are two distinct uniform-capacity architecture cells in this regime (eight grid rows across the four competence levels), both at Omega = 1.0. At ell_s = 1.0 the deterministic model still predicts concentration to be slower than the diffuse benchmark:

- k = 4: deterministic architecture advantage = +2.681796 attempts;
- k = 7: deterministic architecture advantage = +0.083578 attempts.

The finite-C stochastic RMST results reverse both signs:

- k = 4: stochastic architecture advantage = -5.570 attempts;
- k = 7: stochastic architecture advantage = -8.090 attempts.

Both event fractions are 1.0, so this is not a censoring artifact.

Therefore the E5 data do **not** support the stronger statement that deterministic `unrescuable` cells are impossible to rescue stochastically. The original raw-data label remains unchanged for reproducibility, but subsequent theory and manuscript language should call this region **mean-field unrescuable** or **deterministically unrescuable**.

This correction is scientifically useful: the discrepancy is concentrated near a regime boundary and demonstrates that finite-window fluctuations can shift architecture rankings even when the deterministic first-moment theory remains highly predictive globally.

## 5. Frozen interpretation

E5 supports four claims.

### Claim A — competence and allocation interact

A specialist competence premium can reverse the ranking between concentrated and diffuse interface architectures. The relevant question is not whether competence helps in isolation, but whether the improvement in productive learning is sufficient to compensate for the admission losses induced by capacity mismatch.

### Claim B — matching capacity to responsibility is structurally powerful

Matched capacity removes first-order responsibility-capacity mismatch. In the E5 parameter region all matched-capacity cells are structural wins in deterministic theory and all preserve the predicted architecture-ranking sign stochastically.

### Claim C — the switching boundary is predictive but stochastic

The deterministic competence threshold is an effective regime coordinate, not an exact finite-C first-passage threshold. Finite-window randomness shifts the observed switching level by approximately one 0.1 competence-grid step in the few cells that disagree.

### Claim D — boundary disagreements motivate distributional analysis

The failures of the deterministic sign prediction occur only under uniform capacity and cluster near switching boundaries. Mean first-passage comparisons alone therefore do not fully characterize the finite system. The next experiment must examine distributional delay and response to an exogenous perturbation without refitting E5.

## 6. Consequence for E6

E6 will be a new, explicitly post-E5 experiment. It will not alter E5 classifications or thresholds.

The E6 design should test whether concentrated and diffuse architectures that have similar mean first-passage performance can differ materially in tail delay and resilience when a temporary capacity-allocation shock pushes the interface toward or across local overload.

The shock mechanism, grid, endpoints, seed schedule, and tail estimands must be frozen before E6 production data are generated.
