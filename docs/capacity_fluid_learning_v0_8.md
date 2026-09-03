# Model v0.8 — Coupled fluid admission and mean learning

## Status

Post-E3 mechanistic refinement. This layer is introduced **after** the preregistered E3 screening because E3 showed that the onset diagnostics `chi` and `Psi` locate when congestion can interfere with learning, but they do not determine the full delay curve. The purpose of v0.8 is therefore explanatory and predictive for subsequent out-of-sample experiments, not a pre-data prediction for E3.

No new free parameter is introduced.

## 1. Admission state carried over from v0.3

For two symmetric modules, let responsibility shares and capacity shares be

\[
\sum_i p_i=1,\qquad \sum_i x_i=1.
\]

Within one capacity window, scaled attempted time is

\[
s=t/C,
\]

and the window ends at `s = Omega = D/C`.

Define normalized remaining capacity `z_i(s)` and the active set

\[
\mathcal A(s)=\{i:z_i(s)>0\}.
\]

The active responsibility mass is

\[
A(s)=\sum_{i\in\mathcal A(s)}p_i.
\]

As shown in v0.3, under maximum-entropy endpoint pairing the exposure variable `u(s)` satisfies

\[
\frac{du}{ds}=A(s),
\]

with

\[
z_i(s)=\max\{x_i-p_i u(s),0\}.
\]

The exhaustion thresholds are

\[
r_i=\frac{x_i}{p_i}
\]

for `p_i>0`. Because `A(s)` changes only when an actor exhausts capacity, the fluid trajectory is piecewise constant in active-set composition.

## 2. Learning rate conditional on the active set

Consider one module and actor `i`. During a segment in which actor `i` is active and the opposite module has active responsibility mass `A`, an attempted pair contains actor `i` and is admitted with probability

\[
q_i=p_i A.
\]

If a served exposure is productive with probability `ell_i`, the probability that one attempted interaction produces an actor-`i` learning update is

\[
q_i^{\rm learn}=p_i A\ell_i.
\]

The transferable learning update is

\[
w_i' = w_i+\alpha(1-w_i).
\]

Writing the residual distance to saturation as

\[
r_i^{(w)}=1-w_i,
\]

the exact first-moment recursion while the active set is fixed is

\[
\boxed{
E[r_i^{(w)}(t+1)]
=
\left(1-\alpha p_i A\ell_i\right)
E[r_i^{(w)}(t)]
}
\]

for active actor `i`. If `i` is exhausted, its learning probability is zero until the next capacity reset.

Over a segment of `Delta t` attempted interactions with constant active set,

\[
\boxed{
r_i^{(w)}(t+\Delta t)
=
r_i^{(w)}(t)
\left(1-\alpha p_i A\ell_i\right)^{\Delta t}}
\]

for active actors, while inactive actors retain their current state.

This formula permits real-valued `Delta t` as an analytical interpolation, exactly as in the v0.6 real crossing diagnostic.

## 3. Capacity-window reset with persistent memory

At the end of every window, capacity is reset but learning is not:

\[
z_i \leftarrow x_i,
\qquad
w_i \text{ unchanged}.
\]

Therefore each new window begins with the full active set implied by positive capacity, but with residual learning states inherited from all previous windows.

This produces a deterministic piecewise recurrence across windows without adding any state beyond the actor learning variables already introduced in v0.4/v0.6.

## 4. Readiness and first passage

For a symmetric module, mean readiness is

\[
\bar W(t)=\sum_i p_i\,\bar w_i(t).
\]

The coupled fluid-learning first-passage time is

\[
\boxed{
T_F=\inf\{t:\bar W(t)\ge\Theta\}.
}
\]

Because the two modules are symmetric in the deterministic reduction, the module-minimum criterion used by the stochastic v0.7 model reduces to this single-module crossing.

## 5. Exact no-capacity reduction

Before the first exhaustion, `A=1` and all positive-demand actors are active. Hence

\[
\bar w_i(t)
=1-(1-w_{0i})
\left(1-\alpha p_i\ell_i\right)^t,
\]

which is exactly the v0.6 no-capacity first-moment law.

Therefore the v0.8 reduction has the required limit

\[
\boxed{
\text{no exhaustion before crossing}
\Longrightarrow
T_F=t_0^{\rm real}.
}
\]

This is stronger than a deterministic-exposure approximation based on replacing random actor counts by `p_i t`, which would not reproduce the exact no-capacity first moment.

## 6. Relation to `chi` and `Psi`

The onset coordinate remains

\[
\chi=\Omega\Lambda,
\qquad
\Lambda=\max_i\frac{p_i}{x_i}.
\]

The learning-interference diagnostic remains

\[
\Psi=\frac{\Lambda t_0}{C}.
\]

Their roles are now sharpened:

- `chi > 1` identifies deterministic capacity exhaustion within a window;
- `Psi > 1` identifies whether the first deterministic exhaustion occurs before the no-capacity learning timescale;
- neither scalar contains the post-onset active-set sequence;
- the full post-onset delay depends on the ordered threshold set `x_i/p_i` and on the associated active masses `A(s)`.

Thus `chi` and `Psi` are **gate variables**, while v0.8 supplies the full deterministic trajectory once a gate is crossed.

## 7. Endpoint slack and bilateral finite-window correction

The deterministic reduction assumes symmetric fluid depletion. Finite windows can violate that symmetry because the two endpoints receive different stochastic sequences even under symmetric marginals.

Near a concentrated endpoint, define a simple heavy-carrier capacity slack diagnostic

\[
S_H=c_H-m_H,
\]

where `c_H` is the integer capacity of the heavy carrier and `m_H` is the number of heavy-carrier learning exposures required to reach readiness if the remaining responsibility mass stayed at its baseline state. Negative slack implies that the heavy carrier alone cannot complete readiness within one window; zero slack is a knife-edge; positive slack leaves room before exhaustion.

This quantity is **not** introduced as a new control parameter for the core theory. It is an endpoint diagnostic for finite-window corrections, particularly when stochastic asynchronous depletion of the two modules matters.

## 8. Validation strategy

The implementation must pass the following tests before being used for interpretation:

1. no exhaustion before crossing reproduces `no_capacity_mean_crossing_real`;
2. complete concentration with uniform `C=60` reproduces the analytical real crossing near 13.176 attempts;
3. a case with deterministic exhaustion before crossing produces a later multi-window first passage;
4. increasing `max_windows` cannot change an already observed crossing;
5. the solver is monotone in `Theta` and preserves `0 <= W <= 1`;
6. no stochastic seeds are accepted or used.

After unit validation, E3 will be used only as a **post-hoc mechanistic validation** of v0.8. A subsequent experiment must test the reduction out of sample by varying at least one of `C`, `alpha`, `Theta`, or `n` under a design fixed before those results are inspected.
