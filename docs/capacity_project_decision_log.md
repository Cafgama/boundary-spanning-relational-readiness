# Scarce Interaction Capacity — Decision Log

## Project status

New computational/theoretical extension for a prospective `npj Complexity` paper.

The validated boundary-spanning computational track remains frozen and is used as a benchmark, not modified in place.

## Provenance lock

- Parent repository: `Cafgama/boundary-spanning-relational-readiness`
- Legacy source branch: `rerun/balanced-survival-bootstrap`
- Frozen parent commit: `0e3ad434bb694cba225f4470153d15b53bacaf41`
- New paper branch: `paper/scarce-interaction-capacity`
- Frozen Model v0.1 branch: `lock/scarce-capacity-model-v0.1`
- Frozen Model v0.1 commit: `622154d713e47d4364f2e82b364c5b501a46ceb3`

## Methodological principles

1. Mathematical mechanism before implementation.
2. Minimum number of primitive parameters needed to reproduce the phenomenon.
3. Dimensionless reductions before parameter sweeps.
4. One scientific question per experiment family.
5. Equation -> function -> unit test -> deterministic toy case -> stochastic test -> pilot -> production.
6. No interpretation based only on visually attractive simulations.
7. Separate topology/responsibility, capacity allocation, and interaction competence causally.
8. Preserve exact provenance, seeds, censoring status, and analysis manifests.
9. Treat the legacy model as a richer validation layer for the reduced theory.
10. Do not call a dynamical crossover a phase transition unless the mathematical/statistical evidence supports that language.

## Model v0.1 — LOCKED

The following decisions are frozen for the first analytical and computational implementation.

1. **Responsibility concentration:** concentration is represented by interface demand/responsibility shares `p_i`. `H` is a descriptive normalized Herfindahl index of `p`, not a primitive causal variable.
2. **Capacity allocation:** capacity shares are represented independently by `x_i`. Uniform `x_i=1/n` is the core mismatch experiment; proportional matching `x_i=p_i` is the first analytical benchmark.
3. **Global scarcity:** `Omega = D/C`.
4. **Local allocation mismatch:** `Lambda = max_i p_i/x_i` over all modules/actors with positive demand.
5. **Peak offered load:** `chi = Omega Lambda`.
6. **Relational dynamics:** retain the validated reinforcement/failure law. Do not introduce passive decay during blocked attempts in Model v0.1.
7. **Competence reduction:** use the mean-field admitted-interaction requirement `s_theta(pi)` and competence gain `G = s_theta(pi_o)/s_theta(pi_s)`. Keep `Delta pi` as a microscopic parameter, not the primary macroscopic coordinate.
8. **Candidate reduced stress number:** `Xi = Omega Lambda/G`. This is a hypothesis to be tested, not assumed to provide exact data collapse.
9. **Core endpoint:** full interface readiness (`q=1`) for the minimal theory. `q<1`, including legacy `q=0.8`, belongs to robustness/legacy validation.
10. **Language:** `Xi≈1` is initially a dynamical switching/crossover boundary, not an equilibrium phase transition.

## Model v0.2 admission-layer decisions — LOCKED

These decisions govern the first finite-capacity mechanism and add no relational-learning mechanism.

1. **Joint demand closure:** given module-level responsibility marginals `pA` and `pB`, the core joint endpoint distribution is the maximum-entropy product distribution

   `P_ij = pA_i * pB_j`.

   Equivalently, the two endpoints are sampled independently from their prescribed marginals. Assortative or fixed-edge pairings are robustness extensions, not core parameters.

2. **Integer capacity:** capacity is an integer count of interactions per window. Target shares `x` are converted to integer capacities with the largest-remainder rule, preserving total capacity exactly.

3. **Realized quantities:** analyses record target shares and realized integer shares separately. `Omega_realized = D/C_integer`; load/mismatch metrics used for inference are computed from realized capacity shares.

4. **Admission logic:** an attempted pair `(i,j)` is served iff both endpoint actors have at least one capacity unit remaining. A served attempt consumes exactly one unit from each endpoint; a blocked attempt consumes none.

5. **Clock:** every attempt counts toward the `D`-attempt window, whether served or blocked.

6. **Separation of concerns:** deterministic admission is implemented as a pure kernel acting on an explicit demand sequence. Random demand generation is a separate wrapper. No `pi`, `alpha`, `beta`, `w`, or readiness variable appears in the admission kernel.

7. **RNG discipline:** the stochastic wrapper uses an explicit seed and preserves the caller RNG state. Network/relational RNG streams remain untouched.

## Frozen analytical hypotheses

- If `x=p`, then `Lambda=1` exactly in the continuous-share analytical model and the first-order concentration penalty disappears.
- Integer allocation may introduce a finite-capacity discretization mismatch; therefore `Lambda_realized` must be reported.
- For the one-heavy-carrier responsibility family, `H=h^2` exactly.
- Under uniform capacity for that family, `Lambda = 1 + (n-1)h = 1 + (n-1)sqrt(H)`.
- Large-window local congestion onset is expected near `chi = Omega Lambda = 1`.
- Competence-congestion switching is provisionally expected near `Xi = Omega Lambda/G = 1`.
- Finite demand windows should smooth these large-window boundaries.

## Current candidate theoretical reduction

Primitive system quantities:

- cross-boundary demand per capacity window `D`;
- total module capacity `C`;
- responsibility/demand shares `p_i`;
- capacity shares `x_i`;
- interaction success probability `pi`.

Dimensionless quantities:

- global scarcity: `Omega = D/C`;
- allocation mismatch: `Lambda = max_i p_i/x_i`;
- competence gain: `G = s_theta(pi_o)/s_theta(pi_s)`;
- coordination-stress number: `Xi = Omega Lambda/G`.

## Current baby step — admission layer only

Implement and test:

- maximum-entropy joint pairing `P = pA pB^T`;
- largest-remainder integer capacity allocation;
- deterministic admission for a prescribed sequence of endpoint pairs;
- stochastic maximum-entropy demand-sequence generation with explicit seed;
- a one-window wrapper returning served/blocked counts, endpoint use, and remaining capacity.

No relational-learning dynamics are permitted in this step.