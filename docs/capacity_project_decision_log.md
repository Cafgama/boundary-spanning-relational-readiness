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

## Current candidate theoretical reduction

Primitive system quantities:

- cross-boundary demand per capacity window `D`;
- total module capacity `C`;
- responsibility/demand shares `p_i`;
- capacity shares `x_i`;
- interaction success probability `pi`.

Candidate dimensionless quantities:

- global scarcity: `Omega = D/C`;
- allocation mismatch: `Lambda = max_i p_i/x_i`;
- competence gain: `G = s_theta(pi_o)/s_theta(pi_s)`;
- coordination-stress number: `Xi = Omega Lambda/G`.

Current analytical hypothesis:

`Xi < 1` -> competence can compensate for congestion.

`Xi > 1` -> congestion dominates competence and concentrated interface responsibility becomes bottleneck-prone.

## Open decision gate — Model v0.1

The following recommendations are not yet marked as final locks:

1. Measure concentration primarily in interface responsibility/demand (`p_i`), not directly in capacity shares.
2. Keep capacity allocation uniform in the core mechanism test; use proportional matching `x_i=p_i` as the first allocation benchmark.
3. Use `Lambda` as the causal load-amplification variable and retain normalized Herfindahl `H` as a descriptive concentration measure.
4. Retain the legacy reinforcement/failure relational dynamics for the first reduced model.
5. Use full interface readiness (`q=1`) as the clean theoretical endpoint and restore `q<1` only in robustness analyses.
6. Treat `Xi` as a candidate data-collapse variable to be tested, not assumed.

## Next step after lock

Build only the deterministic analytical/test skeleton needed to verify:

- `Omega`, `p`, `x`, `Lambda`, `H`, and `Xi` calculations;
- capacity conservation;
- exact `x=p -> Lambda=1` identity;
- one-heavy-carrier family and its analytical formulas;
- legacy-off equivalence scaffolding.

Finite-capacity stochastic dynamics should still remain disabled at that point.