# E3 — Coupled learning × capacity: official findings and provenance

## Status

E3 is complete. The official stochastic screening was executed **after** the v0.7 model, hypotheses, diagnostics, grid, exact endpoint prediction, and smoke tests had been frozen in branch

`lock/scarce-capacity-coupled-v0.7-preE3`

at commit

`696f2960fb1cf9d2fb9ab37e4bb5871ee5e88c71`.

The production workflow was added only afterward, at commit

`783a5b1b8cb62059e8f79a1c217bfc6010723ac7`.

Official GitHub Actions run:

`33786430111`

Artifact:

`e3-learning-congestion-screening`

Artifact ID:

`9906369758`

SHA-256 digest reported by GitHub Actions:

`a0072618605a32f7e5dc2b362dee9f880934f12ce3fef4f12c518da4d15195be`

The artifact contains the immutable raw stochastic output and its processed summary. The processed summary is preserved in the repository as

`results/processed/e3_learning_congestion_summary.csv`.

A separate execution-engineering check, run `33787038754`, verified that slicing E3 by `h` reproduces the monolithic output row-for-row under the same seed schedule. This changes execution only, not the experiment.

## 1. Frozen pre-data design

The E3 system is the symmetric one-heavy family with

\[
n=4,\qquad
p_H=\frac{1+3h}{4},\qquad
p_O=\frac{1-h}{4},
\]

and

\[
h=\frac{k}{15},\qquad k=0,1,\ldots,15.
\]

The learning parameters are

\[
w_0=0.4,\qquad \alpha=0.08,\qquad \ell=1,\qquad \Theta=0.8.
\]

Capacity scale is

\[
C=60,
\]

with two allocation policies:

- matched allocation: \(x=p\);
- uniform allocation: \(x_i=1/4\).

The demand grid is

\[
\Omega\in\{0.4,0.6,0.8,1.0,1.2,1.5,2.0\},
\qquad D=\Omega C.
\]

There are 200 replications per cell. The design therefore contains 224 cells and 44,800 constrained stochastic trajectories, with a paired no-capacity counterfactual generated from the same demand sequence.

All first passages were observed in both the capacity-constrained and free trajectories; E3 contains no censoring.

## 2. Predictions fixed before E3

The admission theory supplied the deterministic first-exhaustion coordinate

\[
\chi=\Omega\Lambda,
\qquad
\Lambda=\max_i\frac{p_i}{x_i}.
\]

The learning-interference diagnostic was

\[
\Psi=\frac{\Lambda t_0}{C},
\]

where \(t_0\) is the real-valued no-capacity mean readiness crossing.

The preregistered interpretation was deliberately limited:

\[
\chi>1
\]

means deterministic local capacity exhaustion occurs within a capacity window, whereas

\[
\Psi>1
\]

means first deterministic exhaustion occurs before the nominal no-capacity learning timescale. Neither quantity was claimed to determine the entire post-onset delay curve.

For uniform capacity, \(\Psi(h)\) was predicted to be reentrant: approximately 0.906 at \(h=0\), peaking near 1.665 at \(h=7/15\), then falling below one near the concentrated endpoint. At \(h=1\), the heavy carrier has 15 slots per window while readiness requires only 14 productive exposures, implying the exact preregistered endpoint result

\[
T_{\rm cap}=T_{\rm free}=14,
\qquad
\Delta T=0
\]

for every E3 value of \(\Omega\).

A second exact preregistered invariant was the common-random-number monotonicity relation

\[
W^{\rm cap}(t)\le W^{\rm free}(t),
\]

and therefore

\[
\Delta T=T_{\rm cap}-T_{\rm free}\ge0
\]

for every realization. No violation occurred in E3.

## 3. Main E3 result: mismatch delay is strongly reentrant

Under uniform capacity, mean delay is not monotone in concentration. For **every** value of \(\Omega\) in the E3 grid, the largest observed mean delay occurs at

\[
\boxed{h=13/15\approx0.8667.}
\]

The mean paired delays at this concentration are:

| \(\Omega\) | mean \(\Delta T\) |
|---:|---:|
| 0.4 | 7.455 |
| 0.6 | 18.885 |
| 0.8 | 30.850 |
| 1.0 | 42.585 |
| 1.2 | 54.610 |
| 1.5 | 72.645 |
| 2.0 | 102.525 |

This is a stronger result than a direct collapse on \(\Psi\). The scalar \(\Psi\) peaks earlier, around \(h=7/15\), whereas the actual stochastic delay continues increasing until \(h=13/15\). Therefore \(\Psi\) correctly identifies a **timescale gate**, but it does not encode the complete post-exhaustion active-set dynamics.

At \(h=13/15\), first blocking occurs around attempt 17 while the paired no-capacity trajectory crosses readiness around attempt 19. The capacity event therefore intercepts the system immediately before readiness and forces learning to spill into the next window. This explains why the delay can be much larger than the small distance between the two nominal timescales.

## 4. Knife-edge finite-window regime at \(h=14/15\)

At

\[
h=14/15\approx0.9333,
\]

the preregistered fluid diagnostic is

\[
\Psi\approx0.9665<1.
\]

A purely deterministic symmetric fluid model therefore predicts that the nominal mean crossing occurs just before the first exhaustion. The finite-window stochastic model nevertheless shows a substantial delay:

| \(\Omega\) | mean \(\Delta T\) | \(P(\text{any block})\) |
|---:|---:|---:|
| 0.4 | 4.830 | 0.650 |
| 0.6 | 8.895 | 0.570 |
| 0.8 | 12.175 | 0.615 |
| 1.0 | 13.980 | 0.630 |
| 1.2 | 15.350 | 0.615 |
| 1.5 | 17.505 | 0.675 |
| 2.0 | 19.475 | 0.605 |

The mean first-block time is about 16.2–16.3 attempts, essentially the same scale as the mean free first passage, which is also about 16.2–16.3. This is a finite-window synchronization effect: stochastic endpoint counts can make one module exhaust the heavy-carrier capacity just before the bilateral process reaches readiness even though the symmetric fluid trajectory lies slightly on the safe side of the gate.

The endpoint-capacity slack makes the mechanism transparent. With uniform allocation, the heavy carrier has

\[
c_H=15.
\]

At \(h=14/15\), approximately 15 heavy-carrier productive exposures are required if the small ordinary responsibility mass remains near its baseline state. The system is therefore at zero integer slack, making it a natural boundary layer for stochastic asynchronous depletion.

## 5. Exact endpoint recovery at \(h=1\)

At complete concentration,

\[
p_H=1,
\]

all demanded pairs are heavy-heavy. The two modules therefore consume heavy-carrier capacity synchronously. The readiness crossing occurs after 14 productive interactions, before the 15th slot is exhausted. E3 reproduces the exact preregistered result in all seven \(\Omega\) cells:

\[
\boxed{T_{\rm cap}=T_{\rm free}=14,\qquad \Delta T=0,\qquad n_{\rm blocked}=0.}
\]

Hence maximum concentration is **not** intrinsically the most bottleneck-prone configuration. Whether concentration is damaging depends on the ordering of the capacity-exhaustion and learning timescales.

## 6. Matched allocation isolates finite-window stochastic blocking

For matched allocation,

\[
x=p,\qquad \Lambda=1.
\]

The deterministic mismatch mechanism disappears, and all E3 values satisfy \(\Psi<1\). Nevertheless the finite stochastic windows can still block because realized endpoint counts fluctuate around their expected capacities.

The largest matched mean delay occurs in the diffuse, high-load cell:

\[
h=0,\qquad \Omega=2,
\]

where

\[
E[\Delta T]=11.385.
\]

The matched delay then falls sharply as responsibility concentrates and vanishes exactly at \(h=1\). This is consistent with the finite-window correction already identified in E1 and should not be interpreted as deterministic allocation mismatch.

The cleanest causal E3 contrast is therefore `uniform − matched`: it holds the responsibility profile fixed and changes only whether capacity tracks responsibility. Around \(h=13/15\), matched delay is essentially zero while uniform delay is maximal.

## 7. Post-E3 Model v0.8: active-set fluid learning

E3 showed that the onset coordinates are necessary but insufficient to determine the amplitude of the delay. Model v0.8 was therefore derived **after E3** as a mechanistic reduction, without introducing a new fitted parameter.

Within a fluid segment whose active responsibility mass on the opposite module is \(A\), actor \(i\) receives a productive admitted learning opportunity with probability

\[
p_i A\ell_i.
\]

For residual learning distance

\[
r_i^{(w)}=1-w_i,
\]

the exact segment first-moment recursion is

\[
\boxed{
E[r_i^{(w)}(t+1)]
=
\left(1-\alpha p_iA\ell_i\right)
E[r_i^{(w)}(t)].
}
\]

The active set changes only when fluid capacity is exhausted, and capacity resets at each window while learning state persists. Before any exhaustion \(A=1\), so v0.8 reduces exactly to the previously validated no-capacity first-moment law. Post-exhaustion, the full ordered threshold set \(x_i/p_i\), rather than \(\Lambda\) alone, determines the learning trajectory.

All v0.1–v0.8 tests and E1–E3 smoke tests passed in GitHub Actions run `33791239790`.

## 8. Post-hoc mechanistic validation of v0.8 on E3

The comparison with E3 is explicitly **post-hoc mechanistic validation**, not out-of-sample evidence. The purpose is to ask whether the active-set mechanism derived from the E3 discrepancy explains the observed curve without parameter fitting.

Across all 224 E3 cells:

\[
\rho(T_{\rm observed},T_{\rm fluid})=0.9899,
\]

and

\[
\rho(\Delta T_{\rm observed},\Delta T_{\rm fluid})=0.9880.
\]

For the 112 uniform-capacity cells:

\[
\rho_T=0.9901,
\qquad
\rho_{\Delta T}=0.9892.
\]

If the specifically identified finite-window knife-edge layer \(h=14/15\) is excluded, without changing or refitting the model:

\[
\boxed{
\rho_T=0.9948,
\qquad
\rho_{\Delta T}=0.9956.
}
\]

The corresponding mean absolute errors are about 1.79 attempted interactions for \(T\) and 1.48 for \(\Delta T\).

For matched cells, v0.8 predicts zero deterministic delay, so a delay correlation is undefined; the residual matched delay is the finite-window fluctuation layer described above.

These results support the decomposition

\[
\boxed{
\text{observed delay}
=
\text{deterministic active-set mismatch component}
+
\text{finite-window stochastic correction}.
}
\]

This decomposition is now the hypothesis to be tested out of sample rather than a conclusion to be inferred solely from E3.

## 9. Scientific status after E3

The following claims are now well supported by the sequence E1–E3:

1. global scarcity alone is insufficient; local demand/capacity mismatch controls deterministic exhaustion;
2. \(\chi=\Omega\Lambda\) is the exact first-exhaustion coordinate in the fluid limit;
3. \(\Psi=\Lambda t_0/C\) is a learning-interference gate, not a complete delay law;
4. the full post-onset trajectory depends on the ordered capacity thresholds and resulting active-set masses;
5. responsibility concentration can both create and remove a bottleneck because it simultaneously changes local load and learning speed;
6. finite windows create a separate stochastic synchronization layer near deterministic boundaries;
7. maximum concentration can be safe when learning completes before its carrier exhausts capacity.

The next experiment must therefore be predictive and out of sample. It should move the learning timescale while leaving the admission structure unchanged, allowing the same structural configuration to cross the \(\Psi=1\) boundary without changing \(p\), \(x\), or \(\Omega\). This is the purpose of E4.
