# Model v0.1 Lock Record

**Status:** LOCKED

**Scientific role:** minimal analytical model for scarce interaction capacity in modular systems.

**Parent legacy commit:** `0e3ad434bb694cba225f4470153d15b53bacaf41`

**Model definition:** `docs/capacity_model_v0_1.md`

**Decision record:** `docs/capacity_project_decision_log.md`

## Locked core

The first implementation must preserve the following structure without adding mechanisms:

- global scarcity `Omega = D/C`;
- interface responsibility shares `p_i`;
- capacity shares `x_i`;
- local load `omega_i = Omega p_i/x_i`;
- mismatch amplification `Lambda = max_i p_i/x_i`;
- peak load `chi = Omega Lambda`;
- responsibility concentration `H` as a descriptive normalized Herfindahl index;
- legacy reinforcement/failure relational dynamics for admitted interactions;
- mean-field service requirement `s_theta(pi)`;
- competence gain `G = s_theta(pi_o)/s_theta(pi_s)`;
- candidate coordination-stress number `Xi = Omega Lambda/G`;
- full interface readiness `q=1` as the minimal-theory endpoint.

No passive decay, shocks, alternative topology, finite-size scaling, or stochastic finite-capacity mechanism may be introduced before the deterministic analytical layer is independently verified.

## Falsifiable identities/predictions carried into implementation

1. `x=p => Lambda=1`.
2. One-heavy-carrier family: `H=h^2`.
3. One-heavy family with uniform capacity: `Lambda=1+(n-1)h`.
4. Large-window congestion onset: `chi≈1`.
5. Provisional competence-congestion switching: `Xi≈1`.

The last two are hypotheses, not coded truths.