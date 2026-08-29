# Scarce Interaction Capacity — Decision Log

## Project status

New computational/theoretical extension for a prospective `npj Complexity` paper.

The validated boundary-spanning computational track remains frozen and is used as a benchmark, not modified in place.

## Provenance lock

- Parent repository: `Cafgama/boundary-spanning-relational-readiness`
- Legacy source branch: `rerun/balanced-survival-bootstrap`
- Frozen parent commit: `0e3ad434bb694cba225f4470153d15b53bacaf41`
- New paper branch: `paper/scarce-interaction-capacity`

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

## Frozen analytical hypotheses

- If `x=p`, then `Lambda=1` exactly and the first-order concentration penalty disappears.
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

## Next baby step — deterministic analytical layer only

Implement pure analytical functions and tests for:

- `Omega`, local offered loads, `Lambda`, `chi`, and normalized `H`;
- capacity/responsibility normalization and domain validation;
- exact `x=p -> Lambda=1` identity;
- one-heavy-carrier family and `H=h^2`;
- uniform-capacity formula for `Lambda`;
- `kappa(pi)`, `w_star(pi)`, `pi_c`, `s_theta(pi)`, and `G`;
- `Xi = chi/G`;
- legacy numerical sanity check for `G`.

No stochastic finite-capacity dynamics are permitted in this step.