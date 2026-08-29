# Scarce Interaction Capacity — Fluid-Limit Admission Theory v0.2

**Status:** analytical derivation for the admission layer only. No relational learning is included.

## 1. Scope

This note derives the deterministic large-window limit of the finite-capacity admission mechanism under the Model v0.2 locks:

- two statistically symmetric modules;
- the same responsibility shares `p_i` and capacity shares `x_i` in both modules;
- maximum-entropy endpoint pairing `P_ij = p_i p_j`;
- one capacity unit consumed at each endpoint of every served interaction;
- blocked interactions consume no capacity.

The result gives an analytical benchmark for the stochastic Octave implementation. It is not inferred from simulation.

## 2. Scaled time and remaining capacity

Let `t` denote attempted cross-boundary demands in one window and let `C` be total capacity per module. Define the capacity-scaled attempt time

`s = t/C`.

A window with `D` attempts therefore ends at

`s = D/C = Omega`.

Let

`z_i(s)`

be the remaining capacity of actor `i`, normalized by module capacity `C`. Initially

`z_i(0) = x_i`.

Define the active responsibility mass

`A(s) = sum_{i : z_i(s) > 0} p_i`.

Under independent endpoint pairing, an attempted interaction is served at scaled time `s` iff both sampled endpoints are active. In the symmetric case its instantaneous admission probability is therefore

`A(s)^2`.

## 3. Actor-level fluid dynamics

For an active actor `i`, the probability that a demand selects `i` on one side and an active actor on the opposite side is

`p_i A(s)`.

Because `C` attempts occur per unit of scaled time and each served interaction consumes `1/C` normalized capacity from actor `i`, the fluid equation is

`dz_i/ds = -p_i A(s)`

while `z_i > 0`.

Introduce cumulative opposite-side service exposure

`u(s) = integral_0^s A(v) dv`.

Then

`z_i(s) = max[x_i - p_i u(s), 0]`.

Thus each positive-demand actor has a deterministic exhaustion threshold

`r_i = x_i/p_i`.

The active responsibility mass can equivalently be written as a function of exposure:

`A(u) = sum_{i : r_i > u} p_i`.

Since

`du/ds = A(u)`,

scaled attempt time is obtained from

`s(u) = integral_0^u dv / A(v)`.

Because `A(u)` is piecewise constant between ordered exhaustion thresholds, the fluid solution is piecewise analytic.

## 4. Exact onset of deterministic congestion

Before any actor exhausts,

`A = 1`.

Therefore

`u=s`

and

`z_i(s) = x_i - p_i s`.

The first actor exhausts at

`s_c = min_i x_i/p_i`.

Using

`Lambda = max_i p_i/x_i`,

we obtain exactly

`s_c = 1/Lambda`.

The capacity window ends at `s=Omega`. Therefore the deterministic fluid model has no capacity blocking during the window iff

`Omega <= 1/Lambda`,

or equivalently

`Omega Lambda <= 1`.

Hence the congestion-onset variable

`chi = Omega Lambda`

has a direct fluid-limit derivation:

- `chi < 1`: no actor exhausts before the window ends;
- `chi = 1`: the first actor reaches capacity exactly at the end of the window;
- `chi > 1`: at least one actor exhausts before the window ends and positive deterministic blocking follows.

This result is exact under the stated fluid-limit assumptions; finite integer windows can exhibit stochastic blocking before the deterministic boundary because realized actor demand fluctuates around its mean.

## 5. Served and blocked fractions

For a given exposure `u`, normalized capacity used by actor `i` is

`min[x_i, p_i u]`.

Therefore normalized module capacity consumed by served interactions is

`U(u) = sum_i min[x_i, p_i u]`.

Let `u_Omega` solve

`Omega = integral_0^(u_Omega) dv / A(v)`

unless all capacity is exhausted earlier. Then the fluid number of served interactions, normalized by `C`, is

`S/C = U(u_Omega)`.

Since `D/C = Omega`, the served fraction of attempted demands is

`f_served = U(u_Omega)/Omega`,

and

`f_blocked = 1 - U(u_Omega)/Omega`.

This provides a deterministic benchmark for Monte Carlo estimates of blocking.

## 6. Matched allocation benchmark

If capacity follows responsibility exactly,

`x_i = p_i`,

then every positive-demand actor has

`r_i = 1`.

All actors therefore exhaust simultaneously at `s=1`.

The fluid result becomes

- for `Omega <= 1`: `f_blocked = 0`;
- for `Omega > 1`: `f_served = 1/Omega` and `f_blocked = 1 - 1/Omega`.

Thus responsibility concentration itself does not create a deterministic penalty when capacity is proportionally matched. The penalty appears through mismatch and finite-window fluctuations.

## 7. Analytical role of finite-window stochasticity

The stochastic model differs from the fluid model for two reasons:

1. integer actor capacities approximate target shares only discretely;
2. finite multinomial demand counts fluctuate around `D p_i`.

Consequently, finite windows can produce blocking even when `chi < 1`. This is not a contradiction of the fluid result; it is the finite-window rounding/fluctuation layer that the Monte Carlo experiments must quantify.

A central empirical question is therefore whether the stochastic blocking curves converge toward the fluid boundary `chi=1` as the window scale increases.

## 8. Immediate testable predictions

The admission-only simulations should test, before relational learning is added:

1. blocking probability/fraction approaches zero for `chi<1` as `C,D -> infinity` at fixed `Omega` and fixed shares;
2. the onset sharpens near `chi=1` as window scale grows;
3. matched allocation `x=p` converges to the exact piecewise benchmark above;
4. different `(Omega,p,x)` combinations with equal `chi` should share the same first-exhaustion boundary, though their post-onset blocking curves need not collapse exactly because the full ordered set `{x_i/p_i}` matters after the first exhaustion.

The fourth point is an important guardrail: `Lambda` is sufficient for congestion onset, but it is not automatically sufficient for the entire post-onset dynamics.
