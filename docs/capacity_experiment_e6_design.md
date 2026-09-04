# E6 — transient capacity shock and tail risk

## Status

**Pre-data design.** No E6 stochastic production result has been generated or inspected.

E6 starts from the frozen post-E5 checkpoint

`lock/scarce-capacity-competence-switching-postE5`.

E5 established that deterministic first-moment theory predicts architecture rankings very well globally, while finite-window stochastic corrections can shift rankings near switching boundaries. E6 therefore asks a different question: **how much delay risk is hidden in the distribution when interface capacity is temporarily reduced?**

E6 does not refit E5 thresholds and does not change demand generation, learning effectiveness, or learning-state semantics.

## 1. Natural-language world

Two modules build cross-boundary coordination readiness through repeated interaction. Actor `i` has a responsibility share `p_i`, baseline integer interaction capacity `c_i`, learning effectiveness `ell_i`, and persistent transferable learning state `w_i`.

Normally each capacity window begins with the baseline capacities. E6 introduces one temporary system-wide disruption: during the **first capacity window only**, each module retains exactly a fraction `gamma` of its total baseline interaction capacity. That reduced total is redistributed across actors according to the same baseline capacity shares, using the existing deterministic largest-remainder allocation rule. Demand responsibility, pairing, competence, and learning rules remain unchanged. From the second window onward baseline capacity is fully restored.

This is a minimal transient capacity-loss shock. A carrier-specific outage is deliberately postponed because it would immediately add a second mechanism — localization and substitutability of the disruption.

## 2. Shock-mechanism decision

Three alternatives were considered.

**Demand surge:** analytically similar to increasing `Omega`, but nearly redundant with the scarcity experiments already performed.

**Carrier-specific outage:** directly tests specialist fragility, but requires a new rule for responsibility/capacity reassignment.

**Proportional global capacity loss — selected:** one new mechanism only; architecture and demand shares remain unchanged; the existing local-load theory yields an immediate shock coordinate.

## 3. Integer shock semantics

Let baseline integer capacities satisfy

\[
c_i\ge0,\qquad \sum_i c_i=C,
\]

with realized baseline capacity shares

\[
x_i=c_i/C.
\]

For retained-capacity fraction

\[
\gamma\in[0,1],
\]

E6 uses shock levels for which

\[
\boxed{C^{shock}=\gamma C}
\]

is an integer. The first-window actor capacities are then

\[
\boxed{\mathbf c^{shock}=LR(C^{shock},\mathbf x)},
\]

where `LR` is the same deterministic largest-remainder allocation rule used elsewhere in the model.

Thus

\[
\boxed{\sum_i c_i^{shock}=\gamma C}
\]

exactly for every architecture and shock level. This prevents finite integer rounding from making the same nominal `gamma` represent different total shock severity across architectures.

Actor-level shares can differ slightly from baseline `x_i` because the smaller total must be apportioned in integer units. The exact realized shock vector is therefore stored for every trajectory.

For every later window,

\[
\boxed{c_i^{normal}=c_i}.
\]

The shock lasts exactly one window of `D` attempted interactions. During that window, demand pairs are generated exactly as in E5; a pair is served iff both endpoints have remaining shock capacity; served interactions consume one unit at both endpoints; blocked attempts consume no capacity and produce no learning; useful learning on a served endpoint occurs independently with probability `ell_i`; and every attempted pair advances the clock. Learning states persist through recovery.

At the second window boundary, baseline actor capacities are restored.

## 4. Analytical shock coordinate

Ignoring finite integer apportionment, proportional capacity retention changes local offered load from

\[
\omega_i=\Omega\frac{p_i}{x_i}
\]

to

\[
\boxed{\omega_i^{shock}=\frac{\omega_i}{\gamma}}.
\]

Hence peak stress becomes

\[
\boxed{\chi_{shock}=\frac{\chi}{\gamma}}.
\]

For a baseline architecture with `chi<1`, deterministic first exhaustion during the shock window begins at

\[
\boxed{\gamma_c=\chi}.
\]

This is a fluid/onset prediction only. The exact finite process remains bilateral, stochastic, and subject to small actor-level integer-apportionment corrections.

## 5. Critical bilateral-coupling correction

A tempting claim would be that a stronger capacity shock must produce a pathwise superset of blocking and therefore a later first-passage time. **That claim is false for this bilateral admission process.**

If one trajectory blocks an early pair because one endpoint is exhausted, the other endpoint does not consume capacity. That preserved capacity can make a later pair feasible even when a less-shocked trajectory has already spent the same endpoint's capacity. Therefore admitted-pair sets need not be nested across `gamma`.

Consequences fixed before data:

1. every shock level must preserve the exact module-level retained total `gamma*C`;
2. `gamma=1` must reproduce the no-shock generic model exactly;
3. **no pathwise monotonicity of `T` across shock severity is imposed or tested as an invariant**;
4. paired common random numbers are still used to reduce Monte Carlo noise;
5. individual realizations with negative paired shock delay are mathematically possible and must be retained, not treated as errors.

This bilateral reordering effect is part of the complex-system mechanism, not an implementation defect.

## 6. Primary scarcity level

E6 fixes

\[
\boxed{\Omega=0.6}.
\]

For matched capacity and for the diffuse benchmark,

\[
\Lambda=1,\qquad \chi=0.6,
\]

so the fluid shock boundary is

\[
\boxed{\gamma_c=0.6}.
\]

The shock grid therefore contains points above, at, and below the predicted first-exhaustion boundary. Robustness across `Omega` belongs to E7.

## 7. Frozen architecture and competence grid

Use the one-heavy family with

\[
\boxed{k\in\{4,7,9,15\},\qquad h=k/15}.
\]

The points represent low concentration, an E5 boundary-sensitive case, a competence-switching case, and the complete-concentration endpoint.

Capacity policies:

\[
\boxed{\text{matched},\ \text{uniform}}.
\]

Ordinary competence remains

\[
\ell_o=0.70,
\]

with specialist competence

\[
\boxed{\ell_s\in\{0.70,0.90,1.00\}}.
\]

Other frozen parameters:

\[
w_0=0.4,\quad \alpha=0.08,\quad \Theta=0.8,\quad C=60.
\]

## 8. Shock grid

Use

\[
\boxed{\gamma\in\{1.0,0.8,0.6,0.5,0.4\}}.
\]

Since `C=60`, every `gamma*C` is integer:

\[
60,48,36,30,24.
\]

`gamma=1` is the no-shock reference; `0.8` lies above the matched/diffuse fluid boundary; `0.6` is the boundary; `0.5` and `0.4` lie below it.

All shock levels for the same architecture and replication use the same complete demand and latent learning streams.

## 9. Replications and production size

Use

\[
\boxed{R=1000}
\]

per concentrated shock cell so q95 and ES95 have adequate tail counts.

The concentrated design contains

\[
4\times2\times3\times5=120
\]

cells, or

\[
\boxed{120{,}000}
\]

trajectories. The diffuse ordinary benchmark adds five shock cells with `R=1000`, or 5,000 trajectories.

Production may be parallelized by `k` only after an `R=1` slice-equivalence test.

## 10. Common-random-number construction

For a fixed `(k, ell_s, replication)`, all five `gamma` values and both capacity policies use the same demand and learning seeds. Shock severity and policy do not enter the seeds.

Concentrated seed family:

\[
\text{demand seed}=760000000+k\times10^6+i_{\ell}\times10^4+r,
\]

\[
\text{learning seed}=860000000+k\times10^6+i_{\ell}\times10^4+r.
\]

Diffuse benchmark seeds use `k=0` and `i_ell=0`.

## 11. Exact computational invariants

### 11.1 No-shock identity

At `gamma=1`, E6 must reproduce the corresponding Model v0.7 finite-capacity trajectory exactly for identical seeds: first passage, event indicator, blocking counts, productive-learning counts, and final readiness.

### 11.2 Exact module-level shock severity

For every E6 shock level and module,

\[
\boxed{\sum_i c_i^{shock}=\gamma C}.
\]

The same `gamma` therefore means the same total retained interaction capacity across all architectures and policies.

### 11.3 Recovery identity

From the second capacity window onward, the capacity reset vector must equal the baseline integer capacity vector exactly for every `gamma`.

No stronger pathwise ordering is assumed because bilateral admission can reorder which attempts consume endpoint capacity.

## 12. Primary estimands

For each replication define signed paired shock delay relative to its own no-shock trajectory:

\[
\boxed{\Delta T_\gamma=T_\gamma-T_{\gamma=1}}.
\]

Because bilateral reordering can produce rare pathwise improvements, `Delta T` is not truncated at zero.

Primary summaries:

1. mean paired shock delay;
2. median paired shock delay;
3. q90 paired shock delay;
4. q95 paired shock delay;
5. **ES95**, the mean paired shock delay among observations at or above the empirical q95 threshold;
6. probability of a delay of at least one normal window,
\[
\boxed{P(\Delta T_\gamma\ge D)}.
\]

Secondary summaries:

- q99 paired shock delay;
- probability of a negative paired shock delay `P(Delta T < 0)`;
- shock-window blocked fraction;
- probability of any shock-window blocking;
- first block attempt;
- productive learning events during the shock window.

The primary architecture-resilience contrast is the difference between concentrated and diffuse q95/ES95 shock delay at the same `gamma`.

## 13. Frozen hypotheses

### H6.1 — fluid shock boundary

For matched capacity and the diffuse benchmark at `Omega=0.6`, distributional shock delay will increase materially as retained capacity moves from above the fluid boundary (`gamma=0.8`) through `gamma=0.6` and below it (`0.5,0.4`). The hypothesis is distributional, not pathwise.

### H6.2 — mismatch amplifies tail delay

Uniform-capacity concentrated architectures will exhibit larger q95 and ES95 shock delays than matched versions of the same responsibility/competence architecture because their baseline `Lambda` and `chi` are larger.

### H6.3 — competence accelerates recovery but does not change stress

Increasing `ell_s` will reduce expected and upper-tail recovery delay while leaving `Lambda`, baseline `chi`, and the target fluid `chi_shock` unchanged.

### H6.4 — speed-resilience trade-off

At least some architectures that outperform the diffuse benchmark in no-shock mean first-passage time will exhibit a larger upper-tail shock delay than the diffuse benchmark under sufficiently strong capacity loss.

### H6.5 — tail risk contains information absent from the mean

Architecture ordering by mean paired shock delay and by q95/ES95 need not be identical near the overload boundary. Both are reported regardless of which favors a given architecture.

### H6.6 — bilateral reordering is finite-system, not theory failure

The fraction of realizations with `Delta T < 0`, if nonzero, is reported as a finite bilateral-admission effect. It does not alter the fluid stress coordinate and is not used to redefine shock severity.

## 14. Required execution order

1. implement an exact-total integer shock-capacity helper;
2. unit-test shock severity and boundary cases;
3. implement a transient-shock simulator without modifying the E5 generic kernel;
4. prove exact `gamma=1` identity against Model v0.7;
5. deterministic toy tests for complete first-window capacity loss and second-window recovery;
6. run an `R=1` full-grid smoke;
7. prove sliced execution equals the full-run subset;
8. freeze a `preE6` branch;
9. launch `R=1000` production;
10. preserve raw and processed E6 outputs permanently in Git with SHA-256 provenance;
11. close E6 before any `Omega`, size, topology, or localized-outage robustness study.

No E6 grid change after production data are inspected will be called part of E6.
