# Competence Operator — Model v0.5

**Status:** LOCKED AND TESTED.

Model v0.5 adopts endpoint-specific productive-learning effectiveness as the minimal competence mechanism.

## 1. Natural-language meaning

For actor `i`, define

`ell_i = P(productive transferable learning | admitted interaction, actor i)`.

An admitted encounter gives each endpoint its own opportunity to extract reusable interface knowledge. Two people can participate in the same encounter and learn differently from it. Competence therefore belongs to the actor, while admission belongs to the capacity system.

This notation is deliberately different from the legacy pair-level success probability `pi` because the semantics have changed.

## 2. Stochastic competence rule

For an admitted pair `(i,j)`:

`L_i ~ Bernoulli(ell_i)`

`L_j ~ Bernoulli(ell_j)`.

The endpoint draws are the minimal core mechanism. No pair-combination operator such as product, minimum, mean, or maximum is imposed.

If `L_i=1`, Model v0.4 applies one productive transferable-learning update to actor `i`. If `L_i=0`, the actor's accumulated state is unchanged.

Blocked interactions do not reach the competence layer and therefore cannot generate learning.

## 3. Exact no-capacity benchmark

Let `K_theta` be the number of productive learning events required to reach the actor readiness threshold. Under Model v0.4 with `w0=0.4`, `theta=0.8`, and `alpha=0.08`,

`K_theta = 14`.

Without capacity restriction, the admitted-interaction count required for actor `i` to obtain those `K_theta` productive events follows a negative-binomial stopping-time law:

`N_i ~ NegBin(K_theta, ell_i)`.

Therefore

`E[N_i] = K_theta/ell_i`,

`Var[N_i] = K_theta(1-ell_i)/ell_i^2`.

For two actor types, ordinary `o` and specialist `s`, the expected learning-efficiency gain is

`G_learning = E[N_o]/E[N_s] = ell_s/ell_o`.

The legacy numerical values `0.55` and `0.65` would imply a gain of only about `1.18` under this new interpretation. They are therefore not inherited as calibrated parameters.

## 4. Implemented functions

- `src/capacity/draw_productive_learning_events.m`
- `src/capacity/negative_binomial_learning_metrics.m`
- `src/capacity/simulate_no_capacity_learning_requirement.m`

The existing Model v0.4 learning functions remain responsible only for memory updates and readiness.

## 5. Test status

GitHub Actions run `33440105509` executed GNU Octave on the isolated branch `work/scarce-capacity-competence-v0.5` and completed successfully.

The v0.5 tests verify:

- deterministic limits at `ell=0` and `ell=1`;
- fixed-seed reproducibility;
- caller RNG-state preservation;
- endpoint-specific Bernoulli frequencies;
- exact negative-binomial mean and variance formulas;
- deterministic `K_theta` service requirement when `ell=1`;
- Monte Carlo convergence to the negative-binomial moments;
- exact connection between the v0.4 threshold (`K_theta=14`) and v0.5 competence;
- monotonic decline in expected admitted-interaction requirement as `ell` increases.

All previous capacity, fluid-limit, actor-learning, and E1 smoke tests also passed in the same CI run.

## 6. Frozen causal decomposition

The reduced model now separates four mechanisms:

`attempted demand`

`-> capacity admission`

`-> endpoint-specific productive-learning draw ell_i`

`-> transferable actor memory w_i`

`-> demand-weighted readiness`.

This separation is central: responsibility determines exposure, capacity determines whether exposure is served, competence determines whether a served encounter becomes useful learning, and memory determines accumulated readiness.

## 7. Important guardrail before coupling

Model v0.5 does **not** yet define the final first-passage endpoint for the coupled model.

With actor-level transferable learning, a strict system threshold `q=1` can make very low-responsibility actors control first passage simply because they receive few learning opportunities. That may be appropriate for universal readiness, but it conflicts with a demand-coverage interpretation if tiny responsibility shares are operationally negligible.

Therefore the next modeling gate must decide what system readiness means before capacity and competence are combined in one production simulator.

Candidate endpoint interpretations include:

1. strict full demand coverage;
2. a target demand-coverage level `q<1`;
3. module-wise coverage requirements versus a joint pair-ready probability;
4. a continuous demand-weighted readiness state.

No coupled first-passage experiment should be run until this endpoint is fixed.
