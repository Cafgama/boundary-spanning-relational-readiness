# Mathematical Background — Scarce Interface Capacity v0.3

## 1. Minimal stochastic system

Consider two symmetric modules, `A` and `B`, each with `n` interface-capable agents. Agent `i` carries a share `p_i` of interface responsibility, with

`p_i >= 0`,

`sum_i p_i = 1`.

The module has total interface-processing capacity `C` per capacity window. Agent `i` receives capacity share `x_i`, with

`x_i >= 0`,

`sum_i x_i = 1`.

In the discrete implementation, actor capacities are integer counts `c_i` satisfying

`sum_i c_i = C`

and `c_i/C -> x_i` as the window scale increases.

A capacity window contains `D` attempted interface interactions. Define global scarcity

`Omega = D/C`.

For each attempted interaction, the endpoint in module A and the endpoint in module B are sampled independently from the same responsibility distribution `p`. Therefore

`P(i,j) = p_i p_j`.

An attempted interaction `(i,j)` is admitted iff both endpoints have at least one capacity unit remaining. Admission consumes one unit at each endpoint. A blocked attempt consumes no capacity but counts toward the `D` attempted interactions.

## 2. Local load mismatch

Ignoring stochastic fluctuations, actor `i` receives expected window demand

`D p_i`.

Its available capacity is approximately

`C x_i`.

The corresponding local offered load is

`omega_i = D p_i/(C x_i) = Omega p_i/x_i`.

Define

`Lambda = max_i p_i/x_i`

for positive-demand actors, with `Lambda=Inf` if an actor has positive demand and zero capacity.

The peak offered load is

`chi = Omega Lambda`.

`Omega` measures system-wide scarcity, while `Lambda` measures the amplification created by misalignment between responsibility and capacity.

## 3. Fluid-limit dynamics

Let

`s=t/C`

be attempted-interaction time scaled by module capacity. A window ends at

`s=Omega`.

Let `z_i(s)` be actor `i`'s remaining capacity divided by `C`, so

`z_i(0)=x_i`.

Define the active responsibility mass

`A(s)=sum_{i:z_i(s)>0}p_i`.

Because endpoint draws are independent, an attempted interaction is admitted with instantaneous probability

`A(s)^2`

in the symmetric fluid system.

For an active actor `i`, an attempt selects `i` on its module side and an active opposite endpoint with probability

`p_i A(s)`.

Therefore normalized actor capacity obeys

`dz_i/ds = -p_i A(s)`

while `z_i(s)>0`.

Define cumulative service exposure

`u(s)=integral_0^s A(v)dv`.

Then

`z_i(s)=max[x_i-p_i u(s),0]`.

Each positive-demand actor has an exposure threshold

`r_i=x_i/p_i`.

Consequently

`A(u)=sum_{i:r_i>u}p_i`

and

`du/ds=A(u)`,

so

`s(u)=integral_0^u dv/A(v)`.

Because `A(u)` changes only when an actor threshold `r_i` is crossed, the deterministic admission dynamics are piecewise analytic.

## 4. Proposition 1 — exact first-exhaustion boundary

Before any actor exhausts,

`A=1`.

Hence

`u=s`

and

`z_i(s)=x_i-p_i s`.

The first exhaustion time is

`s_c=min_i x_i/p_i`.

Since

`Lambda=max_i p_i/x_i`,

we obtain

`s_c=1/Lambda`.

The capacity window ends at `s=Omega`. Therefore:

**Proposition 1.** In the symmetric maximum-entropy fluid model, deterministic capacity blocking begins within the window iff

`Omega Lambda > 1`.

Equivalently, the exact first-exhaustion boundary is

`chi=Omega Lambda=1`.

This is a dynamical admission boundary, not an equilibrium phase transition.

## 5. Corollary 1 — proportional capacity eliminates the deterministic concentration penalty

If

`x_i=p_i`

for every positive-demand actor, then

`p_i/x_i=1`

and therefore

`Lambda=1`.

All actors have the same exhaustion threshold

`r_i=1`.

Thus responsibility concentration does not alter the deterministic first-exhaustion point when capacity follows responsibility proportionally.

The fluid blocked fraction is

`f_B(Omega)=0`, for `Omega<=1`,

and

`f_B(Omega)=1-1/Omega`, for `Omega>1`.

This law holds for both diffuse and concentrated responsibility distributions as long as `x=p`.

## 6. One-heavy responsibility family

For `n` agents, define

`p_1=[1+(n-1)h]/n`,

`p_i=(1-h)/n`, for `i=2,...,n`,

with `0<=h<=1`.

The normalized Herfindahl concentration is exactly

`H=h^2`.

Under uniform capacity

`x_i=1/n`,

the heavy carrier has

`p_1/x_1=1+(n-1)h`,

so

`Lambda=1+(n-1)h`

and

`Omega_c=1/[1+(n-1)h]`.

Thus concentration shifts the deterministic scarcity threshold only because responsibility becomes misaligned with uniform capacity.

## 7. Canonical didactic case

Set

`n=4`, `h=1/3`.

Then

`p=(1/2,1/6,1/6,1/6)`,

`H=1/9`.

### Proportional capacity

For

`x=p`,

we have

`Lambda=1`, `Omega_c=1`.

### Uniform capacity

For

`x=(1/4,1/4,1/4,1/4)`,

we have

`Lambda=2`, `Omega_c=1/2`.

The heavy carrier exhaustion threshold is

`r_H=(1/4)/(1/2)=1/2`.

Each ordinary carrier has threshold

`r_O=(1/4)/(1/6)=3/2`.

After the heavy carrier exhausts, active responsibility mass is

`A=1/2`.

Therefore the ordinary carriers reach `u=3/2` at scaled attempted time

`s=1/2 + (3/2-1/2)/(1/2)=5/2`.

The complete fluid blocked fraction is consequently

`f_B(Omega)=0`, for `Omega<=1/2`,

`f_B(Omega)=3/4-3/(8 Omega)`, for `1/2<Omega<=5/2`,

`f_B(Omega)=1-1/Omega`, for `Omega>5/2`.

This case provides a closed-form benchmark with no fitted parameters.

## 8. Why Lambda is sufficient for onset but not for the full curve

`Lambda` depends only on the smallest exhaustion threshold,

`min_i x_i/p_i`.

It therefore determines which actor exhausts first and when first exhaustion occurs.

After that point, however, admission depends on the remaining active responsibility mass. The subsequent sequence of thresholds

`{x_i/p_i}`

matters.

Therefore `chi=Omega Lambda` is an exact fluid control variable for first-exhaustion onset but need not collapse the complete post-onset blocking dynamics of arbitrary allocation profiles.

This distinction should be preserved in the paper.

## 9. Finite-window stochastic rounding

For finite `C`, pre-exhaustion marginal demand of actor `i` satisfies

`N_i ~ Binomial(D,p_i)`.

With `D=Omega C`, the standardized local capacity distance is

`Z_i = sqrt(C)(Omega p_i-x_i)/sqrt[Omega p_i(1-p_i)]`.

For a unique critical carrier `i*` near `chi=1`,

`Z* ~= sqrt[C x*/(1-p*)] (chi-1)`.

Hence the stochastic width of the first-exhaustion boundary is expected to scale as

`Delta chi proportional to C^(-1/2)`.

At the boundary itself, positive excess demand is of order `sqrt(C)`, implying a blocked fraction of order

`C^(-1/2)`.

These are finite-window scaling predictions to be tested, not assumptions used to construct the simulations.

## 10. Separation from relational competence

No interaction-success probability, reinforcement rule, or readiness threshold is required to derive Sections 1–9.

The admission theory therefore stands on its own. Relational competence will enter only after the finite-capacity admission layer has been validated against these analytical results.

This separation is essential: scarcity and allocation determine **whether interaction opportunities are admitted**, whereas competence will determine **how effectively admitted opportunities change relational state**.
