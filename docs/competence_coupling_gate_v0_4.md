# Decision Gate v0.4 — How Competence Should Couple to Scarce Capacity

**Status:** OPEN. No relational-learning code should be written until this gate is reviewed.

## 1. Why the earlier Xi hypothesis must be weakened

Model v0.1 proposed the candidate stress number

`Xi = Omega Lambda / G = chi/G`

as a possible competence-congestion switching coordinate.

The exact admission theory now shows that

`chi = Omega Lambda`

is sufficient for the **first-exhaustion boundary**, but not for the complete post-onset admission dynamics. After the first carrier exhausts, throughput depends on the ordered actor thresholds

`{x_i/p_i}`.

Therefore `Xi=1` remains a useful local/onset heuristic, but it should not be assumed to be the exact global competence-switching law.

This is a theory correction made before competence simulations.

## 2. Admission throughput function

Let

`phi(Omega,p,x) = 1 - f_blocked`

be the fluid fraction of attempted interactions that are admitted.

For a coordination process requiring `s_theta(pi)` admitted interactions in mean field, a scalar-work approximation gives external-attempt time proportional to

`T(pi;Omega,p,x) ~ s_theta(pi) / phi(Omega,p,x)`.

Consider an ordinary benchmark `0` and a specialized allocation `s`. Define competence gain

`G = s_theta(pi_o)/s_theta(pi_s)`.

Then

`T_s/T_0 ~ [phi_0/phi_s]/G`.

The corresponding fluid competence threshold is

`G_c(Omega) = phi_0(Omega)/phi_s(Omega)`.

Specialization is predicted to be faster in this scalar-work approximation when

`G > G_c(Omega)`.

This is more exact than `Xi=1` for total admitted-work throughput because it uses the full fluid admission law.

## 3. Canonical case gives a nonmonotonic switching threshold

Use E1's canonical contrast:

Ordinary benchmark: diffuse matched capacity.

Specialized architecture: concentrated responsibility

`p=(1/2,1/6,1/6,1/6)`

with uniform capacity

`x=(1/4,1/4,1/4,1/4)`.

### Ordinary benchmark admission fraction

`phi_0=1`, for `Omega<=1`,

`phi_0=1/Omega`, for `Omega>1`.

### Concentrated-mismatch admission fraction

`phi_s=1`, for `Omega<=1/2`,

`phi_s=1/4 + 3/(8 Omega) = (2 Omega+3)/(8 Omega)`, for `1/2<Omega<=5/2`,

`phi_s=1/Omega`, for `Omega>5/2`.

Therefore the scalar-work competence threshold is

`G_c=1`, for `Omega<=1/2`,

`G_c=8 Omega/(2 Omega+3)`, for `1/2<Omega<=1`,

`G_c=8/(2 Omega+3)`, for `1<Omega<=5/2`,

`G_c=1`, for `Omega>5/2`.

The threshold rises from 1 at `Omega=1/2` to

`G_c(1)=8/5=1.6`

and then falls back to 1 by `Omega=5/2`.

Thus the simplest throughput theory predicts that the relative penalty from concentrated mismatch is strongest around the global heavy-traffic point `Omega≈1`, not monotonically increasing with scarcity.

This is a potentially important theoretical result.

## 4. Interpretation of the nonmonotonicity

Three regimes appear.

### Regime I — spare capacity

Below the local mismatch threshold, both architectures admit essentially all demand. Any competence advantage directly benefits specialization.

### Regime II — selective congestion

The concentrated architecture begins losing opportunities while the matched benchmark still serves almost all attempts. The competence required to compensate rises.

### Regime III — global saturation

Once the ordinary benchmark itself becomes capacity-limited, its admission rate also falls. At sufficiently high scarcity, both architectures eventually consume all available total capacity per window, so their total-work throughput converges and the relative mismatch penalty declines.

This produces a heavy-traffic competence barrier rather than a monotonic scarcity penalty.

## 5. Why this result is not yet the final coordination theory

The scalar-work approximation treats all admitted interactions as interchangeable contributions to one coordination stock. That may be too reductive if readiness requires multiple distinct relations, tasks, or actors to become ready.

Under distributed readiness, two architectures with the same total admitted throughput can differ because service is distributed differently across interface components.

Therefore the choice of relational state is now the key model-design decision.

## 6. Alternatives for the relational state

### Option A — one scalar coordination-work state

A single state `w(t)` is updated by every admitted interaction.

**Advantages**

- analytically minimal;
- yields a closed-form throughput-competence switching law;
- makes the heavy-traffic barrier transparent;
- smallest possible connection between admission and learning.

**Limitations**

- erases heterogeneity across interface relations;
- extreme scarcity makes different allocations converge in total throughput, which may understate distributed-readiness bottlenecks;
- farther from the legacy first-passage definition.

### Option B — actor-level interface states

Each interface-capable actor carries one state `w_i` summarizing its readiness to perform cross-boundary coordination.

**Advantages**

- keeps only `O(n)` states;
- directly aligns local demand, local capacity, competence, and readiness;
- can represent uneven readiness under equal total throughput;
- still much simpler than a full network.

**Limitations**

- requires a principled macroscopic readiness definition and weighting;
- relational coordination becomes actor-interface readiness rather than pair-specific trust.

### Option C — pair/channel-level states

Each active cross-boundary relation or interface channel carries its own `w_e` or `w_ij`.

**Advantages**

- closest to the validated legacy model;
- retains first-passage readiness across multiple interface relations;
- naturally represents a boundary spanner serving many distinct relations.

**Limitations**

- reintroduces a larger state space and a channel/pair construction;
- risks bringing topology back before the capacity theory is fully understood;
- requires deciding whether joint demand is fixed-edge, product-weighted, or another structure.

## 7. Recommendation

Do not jump directly from admission theory to the legacy pair-level model.

Recommended sequence:

1. finish and interpret E1 admission convergence;
2. use Option A **analytically only** as the zeroth-order competence benchmark and derive `G_c(Omega)`;
3. implement Option B as the first stochastic relational extension if we need distributed readiness to reproduce the target phenomenon;
4. reserve Option C / the validated legacy model as the richer robustness and microfoundation layer.

This sequence preserves mathematical clarity while allowing the richer model to falsify or qualify the scalar-work approximation.

## 8. Current interpretation of Xi

Keep

`Xi=chi/G`

only as a compact **local stress-versus-competence indicator near first exhaustion**.

Do not present `Xi=1` as the universal switching surface unless later analysis demonstrates an actual collapse across allocation profiles.

The more general switching object is provisionally

`G_c = phi_0/phi_s`

for scalar work, with distributed-state corrections to be determined later.
