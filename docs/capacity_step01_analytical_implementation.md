# Step 01 — Deterministic Analytical Layer

## Status

**Mathematical identities:** independently checked.

**Octave implementation:** written and statically audited, but not yet marked runtime-validated because no GitHub Actions run was registered after the connector commits and the current execution environment does not provide GNU Octave.

**Finite-capacity stochastic dynamics:** not implemented.

## Frozen model provenance

- Development branch: `paper/scarce-interaction-capacity`
- Frozen Model v0.1 commit: `622154d713e47d4364f2e82b364c5b501a46ceb3`
- Frozen Model v0.1 branch: `lock/scarce-capacity-model-v0.1`
- Legacy parent: `0e3ad434bb694cba225f4470153d15b53bacaf41`

The frozen branch precedes all analytical implementation commits.

## Analytical implementation added

Pure functions under `src/capacity/`:

1. `capacity_load_metrics.m`
   - `Omega=D/C`
   - normalized responsibility concentration `H`
   - actor-level mismatch `p_i/x_i`
   - actor-level offered load `Omega p_i/x_i`
   - `Lambda=max_i p_i/x_i`
   - `chi=Omega Lambda`

2. `one_heavy_responsibility.m`
   - implements the one-parameter concentration family `p(h)`.

3. `relational_service_metrics.m`
   - `kappa(pi)`
   - `w_star(pi)`
   - `pi_c`
   - mean-field admitted-interaction requirement `s_theta(pi)`.

4. `coordination_stress_metrics.m`
   - competence gain `G`
   - candidate stress number `Xi=chi/G`.

## Deterministic test layer

Standalone tests under `tests/capacity_v0_1/` verify:

- uniform responsibility/capacity;
- `x=p -> Lambda=1`;
- `H=h^2` for the one-heavy family;
- `Lambda=1+(n-1)h` under uniform capacity;
- infinite mismatch when positive demand receives zero capacity;
- legacy mean-field service requirements;
- `G` and `Xi` calculations;
- marginal condition `pi=pi_c`;
- normalization errors;
- `h=0` and `h=1` endpoints.

Independent numerical check using the locked legacy values gives:

- `s_theta(0.55)=48.787054544443265`;
- `s_theta(0.65)=29.233854373294870`;
- `G=1.668854675181328`.

## CI

A minimal GitHub Actions workflow was added at `.github/workflows/capacity-v0_1-tests.yml` to install GNU Octave and execute the standalone analytical tests. No workflow run was registered immediately after the connector commit, so runtime validation remains explicitly open.

## New implementation decision gate: joint demand over endpoints

The marginal responsibility vectors `p^(A)` and `p^(B)` determine expected actor loads, but they do not fully specify which pairs of actors jointly receive each cross-boundary demand. Because an admitted interaction requires available capacity at **both** endpoints, exact stochastic blocking also depends on the joint demand matrix `P_ij`.

Three possible core conventions are:

### A. Maximum-entropy / independent mixing

`P_ij = p_i^(A) p_j^(B)`.

Pros:
- introduces no additional control parameter;
- preserves the desired marginals exactly;
- is the neutral mean-field closure;
- cleanly separates responsibility concentration from pair assortativity/topology.

Cons:
- abstracts away persistent pair-specific channels;
- two-sided capacity fluctuations remain genuinely stochastic.

### B. Perfectly assortative pairing

For symmetric modules, pair high-responsibility carriers directly with their counterparts.

Pros:
- simplest two-sided bookkeeping;
- strongest analytical tractability.

Cons:
- imposes strong endpoint correlation;
- can artificially synchronize capacity exhaustion and suppress part of the two-sided problem.

### C. Explicit fixed channel topology

Use a persistent list of cross-boundary channels and obtain `p` from channel incidence.

Pros:
- closest to the legacy network microfoundation.

Cons:
- reintroduces topology before the minimal capacity mechanism is understood;
- adds structural degrees of freedom to the core model.

## Recommendation

Use **A: maximum-entropy independent mixing** in the minimal stochastic model:

`P_ij = p_i^(A) p_j^(B)`.

Treat endpoint assortativity and persistent channel topology as later robustness dimensions. This is the smallest closure compatible with two-sided capacity constraints.

## Next gate after runtime analytical tests

Before implementing a stochastic capacity window, lock the discrete-capacity convention. Each admitted interaction consumes one indivisible unit, so actor capacities `c_i` must ultimately be integers. Target capacity shares `x_i` and target scarcity `Omega` should not be silently represented by fractional service units. The implementation should record **realized** `x_i` and **realized** `Omega` after integer allocation.