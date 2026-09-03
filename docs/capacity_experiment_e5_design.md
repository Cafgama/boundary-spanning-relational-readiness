# E5 — Competence switching under scarce interface capacity

## Status

**Pre-data design.** No E5 stochastic result has been generated or inspected.

E5 starts from the frozen post-E4 checkpoint

`lock/scarce-capacity-learning-timescale-postE4`

at commit

`34bdfa6eb9eaa298634abf1429be6a2e3513d1f4`.

E1–E4 established admission, learning focus, capacity mismatch, and the ordering of learning and exhaustion timescales. E5 introduces the remaining microscopic mechanism: **heterogeneous learning effectiveness across actors**.

No new capacity or learning-state dynamics are introduced. The generic Model v0.7 stochastic kernel and Model v0.8 active-set theory already support vector-valued competence.

## 1. Scientific question

When does concentrating interface responsibility on a more competent specialist outperform a diffuse architecture of ordinary actors, and when is capacity mismatch too severe for competence to compensate?

Competence is

\[
\ell_i=P(\text{useful transferable learning}\mid\text{interaction admitted for actor }i).
\]

E5 deliberately holds the global learning increment fixed at

\[
\alpha=0.08
\]

and changes only actor-level learning effectiveness. Thus E5 is not a repetition of E4: E4 changed the learning timescale of everyone; E5 changes **who is better at converting admitted encounters into reusable interface learning**.

## 2. Ordinary benchmark

The benchmark is a diffuse interface with

\[
p_i=x_i=1/4,
\qquad
\ell_i=\ell_o=0.70
\]

for all four actors on both sides.

The benchmark is subject to the same finite capacity

\[
C=60
\]

and the same global demand levels as the concentrated architecture. It is therefore a fair architecture comparison under scarcity, not a comparison against an unconstrained ideal.

Denote its deterministic Model v0.8 first-passage time by

\[
T_D(\Omega).
\]

## 3. Concentrated specialist architecture

Use the same one-heavy family as E2–E4:

\[
p_H=\frac{1+3h}{4},
\qquad
p_O=\frac{1-h}{4}.
\]

The heavy carrier is the specialist:

\[
\ell_H=\ell_s,
\]

while the three ordinary carriers retain

\[
\ell_O=\ell_o=0.70.
\]

Two capacity policies are compared:

\[
\text{matched}:x=p,
\]

and

\[
\text{uniform}:x_i=1/4.
\]

This separates competence from capacity alignment.

All other parameters remain fixed:

\[
w_0=0.4,
\quad
\alpha=0.08,
\quad
\Theta=0.8,
\quad
C=60.
\]

Capacity resets every window; actor learning persists across windows; demand pairing remains maximum-entropy/product pairing.

## 4. The competence threshold

For fixed \((h,\Omega,\text{policy})\), let

\[
T_C(h,\Omega,\ell_s,\text{policy})
\]

be the deterministic Model v0.8 first-passage time of the concentrated architecture.

Define the specialist competence threshold

\[
\boxed{
\ell_s^*=\inf\{\ell_s\in[\ell_o,1]:T_C(h,\Omega,\ell_s)\le T_D(\Omega)\}.
}
\]

This produces three regimes without an arbitrary classification threshold.

### Regime I — structural win

\[
T_C(h,\Omega,\ell_o)\le T_D(\Omega).
\]

Concentration already beats the diffuse benchmark without any specialist competence premium. Operationally report

\[
\ell_s^*=\ell_o.
\]

### Regime II — competence-rescuable

\[
T_C(h,\Omega,\ell_o)>T_D(\Omega)
\]

but

\[
T_C(h,\Omega,1)\le T_D(\Omega).
\]

A unique switching threshold exists in

\[
\ell_s^*\in(\ell_o,1].
\]

### Regime III — unrescuable mismatch

\[
T_C(h,\Omega,1)>T_D(\Omega).
\]

Even perfect useful-learning conversion at the specialist cannot offset the structural/capacity disadvantage. Report `ell_star = NaN` and regime `unrescuable`.

The regime classification and \(\ell_s^*\) are determined **before stochastic E5 data** using Model v0.8 only.

## 5. Deterministic full-grid map

Before stochastic simulation, evaluate the complete integer-compatible concentration grid

\[
\boxed{h=k/15,\qquad k=1,\ldots,15}
\]

for

\[
\boxed{\Omega\in\{0.6,1.0,1.5\}}
\]

and both capacity policies.

For every cell store:

- \(H=h^2\);
- \(\Lambda\) and \(\chi=\Omega\Lambda\);
- diffuse benchmark time \(T_D\);
- concentrated times at \(\ell_s=\ell_o\) and \(\ell_s=1\);
- regime classification;
- \(\ell_s^*\) where estimable;
- Model v0.8 time at the stochastic competence grid below.

The competence threshold is solved by monotone bisection only in the rescuable regime. No stochastic result is used to select or fit the root.

## 6. Targeted stochastic validation grid

The deterministic map is full-resolution. The stochastic experiment is deliberately smaller and targeted to distinct theoretical regimes.

Use

\[
\boxed{k\in\{4,7,8,9,10,11,13,15\}}
\]

or

\[
h\in\left\{\frac4{15},\frac7{15},\frac8{15},\frac9{15},\frac{10}{15},\frac{11}{15},\frac{13}{15},1\right\}.
\]

These points span low concentration, predicted unrescuable regions, competence-switching neighborhoods, structural-win regions, the high-concentration E3/E4 region, and the complete-concentration endpoint.

Specialist competence grid:

\[
\boxed{\ell_s\in\{0.70,0.80,0.90,1.00\}.}
\]

Scarcity grid:

\[
\boxed{\Omega\in\{0.6,1.0,1.5\}.}
\]

Capacity policies:

\[
\boxed{\text{matched},\text{ uniform}.}
\]

Replications:

\[
\boxed{R=200\text{ per concentrated cell}.}
\]

The concentrated design therefore contains

\[
8\times4\times3\times2=192
\]

cells and

\[
\boxed{38{,}400}
\]

capacity-constrained concentrated trajectories.

The diffuse ordinary benchmark adds three cells (one per \(\Omega\)) with the same \(R=200\), for 600 benchmark trajectories.

## 7. Common-random-number construction

Use explicit and independent demand and learning seeds. Neither seed contains the specialist-competence index. Therefore all four competence levels for a fixed \((h,\Omega,r)\) use the same latent demand and learning uniforms.

For the concentrated architecture use

\[
\text{demand seed}=530000000+i_h10^6+i_\Omega10^4+r,
\]

and

\[
\text{learning seed}=630000000+i_h10^6+i_\Omega10^4+r.
\]

The same two seeds are used for matched and uniform capacity policies and for the paired no-capacity counterfactual.

For the diffuse benchmark use a separate fixed concentration index `i_h=0`:

\[
\text{demand seed}=530000000+i_\Omega10^4+r,
\]

\[
\text{learning seed}=630000000+i_\Omega10^4+r.
\]

The generic kernels pre-generate the complete demand sequence and a latent uniform learning mark for every endpoint at every attempted interaction. Blocked attempts ignore their latent learning marks. This gives exact monotone coupling across \(\ell_s\).

## 8. Exact computational invariants

### 8.1 Competence monotonicity

For fixed demand/learning seeds, architecture and capacity policy,

\[
\ell_s^{(2)}\ge\ell_s^{(1)}
\quad\Rightarrow\quad
W^{(2)}_g(t)\ge W^{(1)}_g(t)
\]

for all attempts, because the productive-learning marks at the higher competence are a superset of those at lower competence.

Therefore, for observed first passages,

\[
\boxed{T(\ell_s^{(2)})\le T(\ell_s^{(1)}).}
\]

The E5 runner must test this pathwise for every competence ladder.

### 8.2 Capacity cannot accelerate its own counterfactual

For identical demand and latent learning marks, the capacity-constrained trajectory only removes useful-learning opportunities from the no-capacity trajectory. Hence

\[
\boxed{T_{cap}\ge T_{free}}
\]

whenever both events are observed.

This invariant must also be asserted pathwise.

### 8.3 No-premium identity

At \(\ell_s=\ell_o=0.70\), the competence vector is homogeneous. E5 must reproduce the generic homogeneous-competence model exactly for the same seeds; there is no hidden specialist effect.

## 9. Primary estimands

Two effects must not be conflated.

### Architecture advantage

For each stochastic concentrated cell compare its first-passage distribution with the finite-capacity diffuse ordinary benchmark at the same \(\Omega\):

\[
\boxed{A=T_C-T_D.}
\]

Negative values favor concentration; positive values favor diffusion.

Primary summaries are mean/RMST first-passage time, median, q90 and q95, with censoring-aware treatment if required.

### Capacity penalty within the concentrated architecture

Using the paired no-capacity counterfactual,

\[
\boxed{B=T_{C,cap}-T_{C,free}\ge0.}
\]

This measures how much of the architecture result is caused by capacity rather than by the concentration/competence learning process itself.

### Switching validation

For each rescuable deterministic cell, use the four preregistered competence levels to test whether the sign of the stochastic mean architecture advantage changes in the neighborhood predicted by \(\ell_s^*\). The continuous theoretical \(\ell_s^*\) is not refit to stochastic data.

## 10. Frozen hypotheses

### H5.1 — three-regime competence map

The deterministic map will contain structural-win, competence-rescuable, and unrescuable regions. Capacity mismatch changes not only the magnitude of delay but whether a feasible specialist competence can reverse the architecture ranking.

### H5.2 — competence rescue

In cells classified as competence-rescuable, increasing \(\ell_s\) will move the concentrated architecture from slower than the diffuse ordinary benchmark to faster than it, with the stochastic switch occurring near the preregistered \(\ell_s^*\).

### H5.3 — unrescuable mismatch

In cells classified as unrescuable, even \(\ell_s=1\) will not make the concentrated uniform-capacity architecture outperform the diffuse benchmark in deterministic theory; stochastic results will be reported without redefining the regime post hoc.

### H5.4 — capacity matching expands the viable-specialization region

Relative to uniform capacity, matched capacity will weakly lower the required specialist threshold or convert cells from unrescuable/rescuable to structural-win/rescuable because it removes first-order responsibility-capacity mismatch.

### H5.5 — competence does not eliminate the distinction between focus and congestion

Higher \(\ell_s\) accelerates learning on the high-responsibility actor but does not change \(\Lambda\), \(\chi\), or actor capacities. Therefore competence can compensate for some mismatch through timescale ordering but cannot alter the structural first-exhaustion boundary itself.

## 11. Required order

1. implement deterministic full-grid threshold generator;
2. unit-test regime classification and bisection;
3. inspect the deterministic map only;
4. freeze the stochastic grid and seed schedule above;
5. implement the E5 generic stochastic runner;
6. smoke-test with `R=1` including both exact pathwise invariants;
7. freeze a `preE5` branch;
8. launch `R=200`;
9. preserve immutable raw output and processed summaries;
10. close E5 before starting tail-risk/shock experiments.

No E5 grid refinement after production data is inspected will be called part of E5. Any such exploration becomes a separately labelled extension.
