# E7 — robustness and scaling

## Status

**Pre-data design.** No E7 stochastic production result has been generated or inspected.

E7 starts from the frozen post-E6 checkpoint:

`lock/scarce-capacity-transient-shock-postE6`

and asks whether the mechanisms established in E1–E6 survive changes in system size, absolute capacity scale, readiness threshold, and cross-module pairing structure.

E7 is deliberately not a new broad exploratory sweep. It is a falsification-oriented robustness program.

## 1. Scientific target

The core theory currently separates four mechanisms:

1. responsibility concentration (`H`) focuses learning;
2. responsibility–capacity mismatch (`Lambda`) creates local overload;
3. scarcity (`Omega`) turns mismatch into peak stress `chi = Omega*Lambda`;
4. the relative ordering of learning and exhaustion times determines whether congestion actually delays readiness.

E7 asks whether those claims depend critically on the baseline choices `n=4`, `C=60`, `Theta=0.8`, and product / maximum-entropy pairing.

The E7 success criterion is therefore qualitative and mechanistic, not numerical reproduction of E3–E6.

## 2. Frozen common parameters

Unless a panel explicitly varies one quantity:

- one-heavy responsibility family;
- symmetric modules;
- `w0 = 0.4`;
- `alpha = 0.08`;
- homogeneous competence `ell = 1`;
- transferable actor learning;
- capacity reset each demand window;
- persistent learning state across windows;
- first passage defined by `min(WA,WB) >= Theta`;
- maximum windows = 20;
- matched policy means `x=p`;
- uniform policy means `x_i=1/n`.

Homogeneous `ell=1` is selected because E7 tests structural robustness rather than competence heterogeneity, which was already isolated in E5.

## 3. Panel A — system-size scaling at fixed capacity per actor

### Question

Does the reentrant concentration–congestion mechanism survive when the number of interface-capable actors changes?

### Design

`n in {4,8,16}`.

Keep baseline capacity per actor fixed at 15:

`C = 15*n`.

Thus a uniform-capacity actor always has exactly 15 slots, independent of `n`.

Use:

`Omega in {0.6,1.0,1.5}`.

Concentration grid:

`h in {0,0.25,0.50,0.75,0.90,1.00}`.

Policies:

`matched`, `uniform`.

`Theta=0.8`.

`R=500` per cell.

Total stochastic trajectories:

`3*3*6*2*500 = 54,000`.

### Exact preregistered identities

At `h=0`, `p` is uniform, so matched and uniform capacity are identical. Therefore their trajectories must be identical under common random numbers.

At `h=1`, all demand goes to actor 1. With `ell=1`, `w0=.4`, `alpha=.08`, `Theta=.8`, exactly 14 productive encounters are required. Uniform capacity supplies 15 slots to actor 1 for every `n` in this panel. Since the smallest demand window has at least 36 attempts,

`T_matched = T_uniform = 14`

for every `n` and `Omega`.

Therefore the uniform-minus-matched delay is exactly zero at both concentration endpoints.

### Primary robustness prediction

For every `(n,Omega)` there should exist at least one intermediate `h` with positive mean uniform-minus-matched delay, producing the same qualitative reentrant pattern observed at `n=4`.

### Reduced-theory evaluation

For every product-pairing cell, compute the v0.8 active-set fluid prediction before stochastic production.

Primary comparison:

- sign agreement between predicted and observed uniform-minus-matched mean delay;
- Pearson correlation of predicted and observed delays;
- location of the maximum observed delay versus the maximum deterministic prediction.

No parameter is refit by `n`.

## 4. Panel B — absolute capacity scale

### Question

Does the safe/bottleneck switching law respond to absolute per-actor capacity as predicted by the learning-versus-exhaustion argument?

### Design

Fix:

- `n=4`;
- `Theta=.8`;
- product pairing.

Use:

`C in {40,60,120}`,

so uniform capacity per actor is exactly:

`{10,15,30}`.

Use:

`Omega in {0.6,1.0,1.5}`,

`h in {0,0.50,0.90,1.00}`,

policies `matched`, `uniform`,

`R=500`.

Total trajectories:

`3*3*4*2*500 = 36,000`.

### Exact endpoint prediction at h=1

For `Theta=.8`, exactly 14 productive encounters are required.

At `C=40`, uniform actor capacity is 10, so concentration complete cannot reach readiness in the first window. Since all demand is actor 1 and `ell=1`,

`T_free = 14`,

`T_uniform = D + 4`,

so

`DeltaT = D - 10`.

Therefore the exact uniform penalty is:

- `14` at `Omega=.6` (`D=24`);
- `30` at `Omega=1` (`D=40`);
- `50` at `Omega=1.5` (`D=60`).

At `C=60` and `C=120`, uniform actor capacity is at least 14 and the exact endpoint penalty is zero.

This is a preregistered, parameter-free test of the timescale mechanism.

## 5. Panel C — readiness-threshold robustness

### Question

Does changing the operational definition of readiness shift the safe/bottleneck boundary exactly through the implied learning requirement rather than changing the mechanism itself?

### Design

Fix:

- `n=4`;
- `C=60`;
- `Omega=1`;
- product pairing.

Use:

`Theta in {0.7,0.8,0.9}`,

`h in {0,0.50,0.90,1.00}`,

policies `matched`, `uniform`,

`R=500`.

Total trajectories:

`3*4*2*500 = 12,000`.

### Exact productive-event requirements

For `w0=.4`, `alpha=.08`:

- `K_0.7 = 9`;
- `K_0.8 = 14`;
- `K_0.9 = 22`.

At `h=1`, uniform actor capacity is 15.

Therefore:

- `Theta=.7`: exact uniform penalty `0`;
- `Theta=.8`: exact uniform penalty `0`;
- `Theta=.9`: first window serves 15 useful events, then readiness requires seven more in the second window. With `D=60`, `T_uniform=67`, `T_free=22`, so exact penalty `45`.

This tests whether the endpoint switch follows the learning requirement itself.

## 6. Panel D — pairing robustness

### Question

Does the concentration–mismatch mechanism depend on the maximum-entropy product pairing assumption?

### Pairing alternatives

Core product pairing:

`P_ij = p_i p_j`.

Robustness pairing: perfect rank-assortative coupling for symmetric modules:

`P_ij = p_i * I(i=j)`.

This keeps exactly the same marginal responsibility distribution `p` on both modules while changing only cross-module correlation.

It is deliberately an extreme stress test rather than a new calibrated pairing model.

### Design

Fix:

- `n=4`;
- `C=60`;
- `Theta=.8`;
- `ell=1`.

Use:

`Omega in {0.6,1.0,1.5}`,

`h in {0,0.50,0.75,0.90,1.00}`,

policies `matched`, `uniform`,

pairing modes `product`, `assortative`,

`R=500`.

Total trajectories:

`3*5*2*2*500 = 30,000`.

### Exact identities

Within either pairing mode, at `h=0`, matched and uniform capacity are identical.

At `h=1`, all pairing modes collapse to the same single active pair. With 15 uniform slots and `K=.8=14`, all policies and pairing modes have `T=14`.

### Mechanistic prediction

The reentrant endpoint structure should survive the pairing change: zero penalty at `h=0`, zero penalty at `h=1`, and positive mismatch penalty for at least one intermediate concentration.

The product pairing can create collateral bilateral blocking because an active actor can be paired with an exhausted actor on the opposite side. Perfect assortative pairing removes this cross-rank externality. Therefore the uniform-capacity penalty is expected to be weaker under assortative pairing in much of the intermediate regime. This is a directional prediction, not a pathwise invariant.

## 7. Assortative reduced theory

For perfectly assortative symmetric pairing, pair `i-i` is attempted with probability `p_i`.

While actor `i` retains capacity,

`dz_i/ds = -p_i`.

Therefore its exhaustion threshold remains

`s_i = x_i/p_i`.

Unlike product pairing, exhaustion of another rank does not multiply actor `i`'s exposure by an active-mass factor `A`.

For active actor `i`, the mean residual learning state obeys

`r_i(t+1) = (1-alpha*p_i*ell_i) r_i(t)`

during the part of each window before that actor exhausts.

E7 will implement this deterministic assortative benchmark separately and compare it with stochastic assortative simulations without fitting parameters.

## 8. Legacy bridge

E7 will not introduce a new pair-specific `w_ij` capacity model.

Reason: replacing transferable actor learning by relation-specific learning changes the state semantics and would constitute a new mechanism rather than a robustness check.

The bridge to the original boundary-spanning model is instead the already validated legacy comparison:

- agent-first selection produced the boundary-spanner bottleneck;
- edge-uniform selection largely removed the low-competence bottleneck;
- translation/competence effects persisted.

This existing result is used only as provenance showing that the explicit-capacity theory generalizes the implicit actor-capacity scarcity discovered in the legacy network model.

## 9. Total E7 stochastic budget

Panel A: 54,000 trajectories.

Panel B: 36,000 trajectories.

Panel C: 12,000 trajectories.

Panel D: 30,000 trajectories.

Total:

`132,000` trajectories.

The panels will run independently and in slices after `R=1` slice-equivalence tests.

## 10. Frozen evaluation hierarchy

E7 is considered supportive of robustness if all exact identities pass and the following qualitative mechanisms survive:

1. concentration endpoints remain non-bottlenecked when the productive-learning requirement fits inside the carrier's per-window capacity;
2. intermediate mismatch creates positive delay in the scaling panel;
3. reducing per-actor capacity below the learning requirement creates the exact predicted endpoint delay;
4. increasing `Theta` above the same per-window capacity creates the exact predicted endpoint delay;
5. the reentrant mismatch pattern survives the change from product to assortative pairing.

Reduced-theory accuracy is reported using sign agreement, Pearson correlation, MAE, and RMSE. It is not refit.

Any failure of an exact identity is a code/model implementation failure and blocks production.

Any failure of a qualitative robustness prediction is a scientific result and must not be repaired by changing the frozen grid after data inspection.

## 11. Production data policy

Every E7 production panel must archive permanently in Git:

- compressed raw CSV;
- processed summary;
- frozen theory-prediction table;
- evaluation cells;
- metrics;
- manifest containing source lock, workflow run, row counts, replication count, and SHA-256 digests.

GitHub Actions artifacts are supplementary copies only and must not be the sole preservation layer.
