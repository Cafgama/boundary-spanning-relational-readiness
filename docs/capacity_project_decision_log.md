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

## Model v0.2 admission layer — LOCKED AND TESTED

1. **Joint demand closure:** `P_ij = pA_i * pB_j`, the maximum-entropy product distribution compatible with the prescribed marginals.
2. **Integer capacity:** target shares `x` are converted to integer actor capacities by the largest-remainder method, preserving total module capacity exactly.
3. **Realized quantities:** target and realized capacity shares are stored separately. Load/mismatch metrics used for inference are computed from realized integer shares.
4. **Admission:** an attempted pair `(i,j)` is served iff both endpoints have remaining capacity. Served attempts consume one unit at each endpoint; blocked attempts consume none.
5. **Clock:** every attempted pair advances the window clock.
6. **Separation:** deterministic admission and stochastic pair generation are separate functions. No relational-learning state appears in the admission layer.
7. **RNG:** stochastic demand generation uses an explicit seed and restores the caller RNG state.

### Implemented functions

- `src/capacity/allocate_integer_capacity.m`
- `src/capacity/maximum_entropy_pairing.m`
- `src/capacity/generate_max_entropy_demands.m`
- `src/capacity/admit_capacity_sequence.m`
- `src/capacity/run_capacity_window.m`

### Test status

GitHub Actions run `33258151078` executed GNU Octave and completed successfully.

- Model v0.1 analytical tests: **PASS**
- Model v0.2 admission tests: **PASS**

The v0.2 tests verify product-distribution marginals, integer capacity conservation, deterministic tie-breaking, exact blocking semantics, no capacity consumption on blocked attempts, RNG isolation/reproducibility, one-window accounting invariants, and absence of relational-learning variables from the admission layer.

## Fluid-limit result — DERIVED

For symmetric modules under maximum-entropy pairing, let scaled attempt time be `s=t/C` and normalized remaining actor capacity be `z_i(s)`. Define active responsibility mass

`A(s) = sum_{i:z_i(s)>0} p_i`.

The fluid admission dynamics satisfy

`dz_i/ds = -p_i A(s)`

while actor `i` remains active. With cumulative service exposure

`u(s)=integral_0^s A(v)dv`,

we have

`z_i(s)=max[x_i-p_i u(s),0]`.

Before any actor exhausts, `A=1`, so the first exhaustion occurs at

`s_c = min_i x_i/p_i = 1/Lambda`.

Because the window ends at `s=Omega`, deterministic congestion begins exactly when

`Omega Lambda > 1`.

Thus `chi=Omega Lambda` has a direct fluid-limit interpretation:

- `chi<1`: no deterministic capacity blocking in the fluid window;
- `chi=1`: first capacity exhaustion at the window boundary;
- `chi>1`: positive deterministic blocking occurs before the window ends.

The full derivation is recorded in `docs/capacity_fluid_limit_v0_2.md`.

### Important sufficiency guardrail

`Lambda` determines the **first-exhaustion/onset boundary** but does not necessarily determine the entire post-onset blocking curve. After the first exhaustion, the full ordered set of local thresholds `{x_i/p_i}` can matter. Therefore `chi` is an exact onset variable in the fluid limit, while complete post-onset data collapse remains an empirical/theoretical question.

## Current candidate theoretical reduction

Primitive system quantities:

- `D`: cross-boundary demand attempts per capacity window;
- `C`: total module capacity;
- `p_i`: responsibility/demand shares;
- `x_i`: capacity shares;
- `pi`: interaction competence.

Dimensionless quantities:

- `Omega = D/C`;
- `Lambda = max_i p_i/x_i`;
- `chi = Omega Lambda`;
- `G = s_theta(pi_o)/s_theta(pi_s)`;
- candidate coordination-stress number `Xi = chi/G`.

## Next baby step

Do **not** connect relational learning yet.

First run an admission-only finite-window experiment against the analytical fluid benchmark. The minimum experiment should answer one question:

> Does stochastic finite-window blocking converge to the theoretically derived `chi=1` onset as the window scale increases?

Use fixed `(Omega,p,x)` structures and scale `C` and `D` together so that `Omega` and the continuous shares remain fixed. Compare matched allocation `x=p` with one controlled mismatch family. Only after this admission theory is empirically validated should competence and relational learning be connected.