# E6 — transient capacity shock and tail risk

## Status

**Pre-data design.** No E6 stochastic production result has been generated or inspected.

E6 starts from the frozen post-E5 checkpoint

`lock/scarce-capacity-competence-switching-postE5`.

E5 established that the deterministic first-moment theory predicts architecture rankings very well globally but that finite-window stochastic corrections can shift rankings near switching boundaries. E6 therefore asks a different question: **how much delay risk is hidden in the distribution when interface capacity is temporarily reduced?**

E6 does not refit E5 thresholds and does not change the learning or demand-generation rules.

## 1. Natural-language world

Two modules are building cross-boundary coordination readiness through repeated interactions.

Each actor has:

- a responsibility share `p_i`, determining how much cross-boundary demand reaches that actor;
- a baseline capacity allocation `c_i`, determining how many interactions the actor can process in a capacity window;
- a learning effectiveness `ell_i`, determining the probability that an admitted interaction produces useful transferable learning;
- a persistent actor-level learning state `w_i`.

Normally, each capacity window begins with the baseline actor capacities.

E6 introduces one temporary system-wide disruption: during the **first capacity window only**, every actor retains only a fraction `gamma` of baseline interaction capacity. The lost capacity disappears for that window. Demand responsibility, demand pairing, competence, and learning rules do not change. From the second window onward, baseline capacity is fully restored.

This is a minimal transient capacity-loss shock. It represents situations such as a temporary loss of interface bandwidth, operational disruption, or a short-lived reduction in available coordination time.

The shock is deliberately global rather than carrier-specific in E6. A carrier-specific outage would introduce a second mechanism — localization/substitutability of the disruption — and is reserved for robustness or a later extension.

## 2. Why this shock is the minimal extension

Three shock mechanisms were considered.

### A. Demand surge

Increase `D` temporarily while capacity remains fixed.

Advantage: analytically equivalent to increasing global scarcity.

Disadvantage: it changes the demand process rather than capacity and is nearly redundant with changing `Omega`.

### B. Carrier-specific outage

Reduce the capacity of the high-responsibility carrier only.

Advantage: directly tests specialist fragility.

Disadvantage: immediately introduces a new modelling choice about whether lost capacity or responsibility can be reassigned, so it mixes capacity loss with substitutability.

### C. Proportional global capacity loss — selected

Scale all baseline actor capacities down for one window and restore them afterward.

Advantage: one new mechanism only; architecture and demand shares remain unchanged; the shock has an immediate analytical interpretation in the existing local-stress coordinate.

**E6 selects C.**

## 3. Shock semantics

Let baseline integer actor capacities in one module be

\[
c_i,\qquad \sum_i c_i=C.
\]

Let

\[
\gamma\in[0,1]
\]

be the retained-capacity fraction during the shock window.

For the first capacity window define

\[
\boxed{c_i^{shock}=\lfloor \gamma c_i\rfloor.}
\]

For all later windows:

\[
\boxed{c_i^{normal}=c_i.}
\]

The floor rule makes the shock capacities nested pathwise as `gamma` decreases and avoids stochastic capacity allocation.

The realized retained module capacity is stored as

\[
\gamma_{real}=\frac{\sum_i c_i^{shock}}{C}.
\]

The shock lasts exactly one capacity window of `D` attempted interactions.

During the shock window:

1. demand pairs are generated exactly as in E5;
2. a pair is admitted only if both endpoints have remaining shock capacity;
3. admitted interactions consume one unit from both endpoints;
4. blocked attempts consume no capacity and produce no learning;
5. admitted endpoints independently generate useful learning with probability `ell_i`;
6. learning state persists after the shock;
7. the attempt clock advances for every attempted pair.

At the second window boundary, baseline capacities are restored and normal Model v0.7 dynamics continue.

## 4. Analytical shock coordinate

Ignoring integer rounding, proportional capacity retention changes local offered load from

\[
\omega_i=\Omega\frac{p_i}{x_i}
\]

to

\[
\boxed{\omega_i^{shock}=\frac{\omega_i}{\gamma}.}
\]

Therefore peak stress becomes

\[
\boxed{\chi_{shock}=\frac{\chi}{\gamma}.}
\]

For a baseline architecture with `chi < 1`, the deterministic first-exhaustion boundary during the shock window is

\[
\boxed{\gamma_c=\chi.}
\]

This gives E6 a preregistered mechanistic prediction: a transient shock should become qualitatively more damaging when the retained capacity pushes `chi_shock` through one.

Integer rounding is not absorbed into the theory; the exact realized capacities and `gamma_real` are stored and treated as the finite-system implementation.

## 5. Why Omega = 0.6 is the primary E6 scarcity level

E6 fixes

\[
\boxed{\Omega=0.6}
\]

for the primary shock experiment.

At matched capacity and in the diffuse benchmark,

\[
\Lambda=1,\qquad \chi=0.6.
\]

Thus the analytical shock boundary occurs at

\[
\boxed{\gamma_c=0.6.}
\]

The preregistered shock grid will therefore contain points above, at, and below the predicted boundary.

Using a single scarcity level prevents E6 from becoming a second broad parameter sweep. Robustness across `Omega` belongs to E7.

## 6. Frozen architecture grid

Use the same one-heavy family and E5 competence semantics.

Concentration points:

\[
\boxed{k\in\{4,7,9,15\},\qquad h=k/15.}
\]

These four points have distinct roles in the post-E5 theory:

- `k=4`: relatively low concentration;
- `k=7`: an E5 boundary-sensitive architecture;
- `k=9`: a competence-switching architecture;
- `k=15`: complete concentration endpoint.

Capacity policies:

\[
\boxed{\text{matched},\ \text{uniform}.}
\]

Ordinary competence remains

\[
\ell_o=0.70.
\]

Specialist competence grid:

\[
\boxed{\ell_s\in\{0.70,0.90,1.00\}.}
\]

All other learning parameters remain frozen:

\[
w_0=0.4,\quad \alpha=0.08,\quad \Theta=0.8,\quad C=60.
\]

## 7. Shock grid

Use retained-capacity fractions

\[
\boxed{\gamma\in\{1.0,0.8,0.6,0.5,0.4\}.}
\]

Interpretation:

- `gamma=1.0`: no-shock reference;
- `gamma=0.8`: mild shock, above matched/diffuse first-exhaustion boundary;
- `gamma=0.6`: theoretical matched/diffuse boundary;
- `gamma=0.5`: moderate shock, below the boundary;
- `gamma=0.4`: stronger shock.

The no-shock trajectory and all shock levels for the same architecture/replication use the same complete demand and latent learning streams.

## 8. Replications and production size

Use

\[
\boxed{R=1000}
\]

per concentrated shock cell so that q95 and the upper-tail conditional mean are based on adequate tail counts.

The concentrated design contains

\[
4\times 2\times 3\times 5=120
\]

cells and

\[
\boxed{120{,}000}
\]

concentrated trajectories.

The diffuse ordinary benchmark is evaluated for the same five shock levels with `R=1000`, adding 5,000 trajectories.

Production should be parallelized by `k` only after slice equivalence is proven at `R=1`.

## 9. Common-random-number construction

For each fixed `(k, policy, ell_s, replication)`, all five `gamma` levels use the same demand and learning seeds.

Shock severity must not appear in either seed.

Recommended concentrated seed family:

\[
\text{demand seed}=760000000+k\times10^6+i_{\ell}\times10^4+r,
\]

\[
\text{learning seed}=860000000+k\times10^6+i_{\ell}\times10^4+r.
\]

Matched and uniform policies use the same latent streams.

Diffuse benchmark seeds use `k=0` and `i_ell=0`.

## 10. Exact computational invariants

### 10.1 No-shock identity

At `gamma=1`, E6 must reproduce the corresponding ordinary Model v0.7 trajectory exactly for identical seeds.

### 10.2 Nested shock capacity

For any actor and two retained fractions with

\[
\gamma_2<\gamma_1,
\]

shock-window integer capacity must satisfy

\[
\boxed{c_i^{shock}(\gamma_2)\le c_i^{shock}(\gamma_1).}
\]

### 10.3 Pathwise shock-delay monotonicity

Because a stronger shock only removes admission opportunities during the first window and all later capacity, demand, and latent learning marks are identical,

\[
\boxed{T(\gamma_2)\ge T(\gamma_1)}
\]

for

\[
\gamma_2<\gamma_1
\]

using censored first-passage time `T_tilde` if needed.

This is an exact E6 audit, not an empirical hypothesis.

### 10.4 Shock cannot improve readiness state pathwise

At every attempt after identical initial conditions, the stronger-shock trajectory must not contain a learning event that is absent solely because of greater capacity in the weaker-shock trajectory. The implementation should preserve a subset relation in admitted useful-learning opportunities during the shock window.

## 11. Primary estimands

For every shock cell define paired shock delay relative to its own no-shock trajectory:

\[
\boxed{\Delta T_\gamma=T_\gamma-T_{\gamma=1}.}
\]

Primary distributional summaries:

1. mean paired shock delay;
2. median paired shock delay;
3. q90 paired shock delay;
4. q95 paired shock delay;
5. **ES95**, defined as the mean paired shock delay among replications at or above the empirical q95 threshold;
6. probability that the shock costs at least one full normal window:

\[
\boxed{P(\Delta T_\gamma\ge D).}
\]

Secondary summaries:

- q99 paired shock delay;
- mean blocked fraction during the shock window;
- probability of any blocking during the shock window;
- first block attempt;
- number of productive learning events lost relative to no shock.

The primary architecture-resilience contrast is the difference between concentrated and diffuse q95/ES95 shock delay at the same `gamma`.

## 12. Frozen hypotheses

### H6.1 — shock boundary

For matched capacity and the diffuse benchmark at `Omega=0.6`, distributional shock delay will change sharply as retained capacity moves from above the analytical boundary (`gamma=0.8`) through `gamma=0.6` and below it (`gamma=0.5,0.4`).

### H6.2 — mismatch amplifies tail delay

Uniform-capacity concentrated architectures, which already carry larger `Lambda` and `chi`, will exhibit larger q95 and ES95 shock delays than the matched-capacity version of the same responsibility/competence architecture.

### H6.3 — competence accelerates recovery but does not change shock stress

Increasing specialist competence `ell_s` will reduce the post-shock first-passage delay but will not change `Lambda`, baseline `chi`, shock-window `chi_shock`, or the shock-window first-exhaustion condition.

### H6.4 — concentration can trade speed for resilience

At least some architectures that outperform the diffuse benchmark in no-shock mean first-passage time will have a larger upper-tail shock delay than the diffuse benchmark under sufficiently strong capacity loss.

This is the primary resilience trade-off hypothesis.

### H6.5 — tail risk contains information absent from mean delay

Architecture ordering by mean shock delay and by q95/ES95 shock delay need not be identical near the overload boundary. E6 will report both without selecting the more favorable metric post hoc.

## 13. Required execution order

1. implement a shock-capacity helper on integer baseline capacities;
2. unit-test nesting and exact `gamma=1` identity;
3. implement the transient-shock first-passage simulator without modifying the E5 generic kernel;
4. deterministic toy tests for complete blocking and recovery;
5. `R=1` full-grid smoke with pathwise monotonicity across all gamma ladders;
6. prove sliced execution equals the full-run subset;
7. freeze a `preE6` branch;
8. launch `R=1000` production;
9. preserve raw and processed production outputs permanently in Git with SHA-256 provenance;
10. close E6 before any `Omega`, size, topology, or localized-outage robustness study.

No E6 grid change after production data are inspected will be called part of E6.
