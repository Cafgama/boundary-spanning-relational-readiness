# Scarce Interaction Capacity — Minimal Mathematical Model v0.1

**Status:** DRAFT — analytical skeleton only. No finite-capacity simulation code has been implemented.

**Parent legacy state:** `rerun/balanced-survival-bootstrap` at commit `0e3ad434bb694cba225f4470153d15b53bacaf41`.

## 1. Scientific objective

Construct the smallest model that can distinguish when concentration of cross-boundary coordination responsibility is beneficial because of superior interface competence and when the same concentration becomes a bottleneck because finite interaction capacity is locally overloaded.

The model is intentionally stripped of internal-module network dynamics. The validated legacy model will later be used as a richer robustness/microfoundation benchmark.

## 2. Structured system

Consider two modules, `A` and `B`, each containing `n` interface-capable actors. The modules are connected by `m` distinct cross-boundary coordination channels (tasks, interfaces, or relational ties), indexed by `e = 1,...,m`.

Each channel has exactly one endpoint in each module. Multiple channels may be assigned to the same actor; this is the minimal representation of concentrated interface responsibility.

For actor `i` in module `g`, let

`k_i^(g)` = number of interface channels assigned to actor `i`.

Under uniform demand over channels, its demand share is

`p_i^(g) = k_i^(g) / m`,

with

`sum_i p_i^(g) = 1`.

## 3. Scarce interaction capacity

During one capacity window, exactly `D` cross-boundary demand attempts occur.

Module `g` has total capacity

`C = sum_i c_i^(g)`,

where `c_i^(g)` is the number of cross-boundary interactions actor `i` can serve during the window.

Define capacity shares

`x_i^(g) = c_i^(g) / C`,

with

`sum_i x_i^(g) = 1`.

The global scarcity ratio is

`Omega = D / C`.

Each admitted cross-boundary interaction consumes one capacity unit at each endpoint. If either endpoint has exhausted its capacity, the demand is blocked. A blocked demand advances the external clock but does not produce a relational success/failure outcome and does not update the relational state.

Capacity resets at the end of the `D` attempted cross-boundary demands.

## 4. Local load and the allocation-mismatch factor

The expected demand received by actor `i` in a window is `D p_i^(g)`. Its local offered load relative to available capacity is therefore

`omega_i^(g) = D p_i^(g) / c_i^(g)`

or equivalently

`omega_i^(g) = Omega * p_i^(g) / x_i^(g)`.

This identity is the first analytical reduction of the model.

Define the allocation-mismatch amplification

`Lambda = max_(g,i) [ p_i^(g) / x_i^(g) ]`.

Then the most stressed local load is

`chi = Omega * Lambda`.

Interpretation:

- `Omega` measures system-wide scarcity;
- `Lambda` measures how strongly responsibility/demand is misaligned with capacity allocation;
- `chi` is the effective peak interface load.

A first large-window congestion boundary is therefore expected near

`chi = 1`.

For finite `D`, stochastic demand fluctuations smooth this boundary.

## 5. Why concentration alone is not the primitive mechanism

If capacity is allocated exactly in proportion to interface demand,

`x_i^(g) = p_i^(g)` for every actor,

then

`Lambda = 1`

and consequently

`omega_i^(g) = Omega` for all actors.

Therefore, concentration of interface responsibility does not by itself create local overload when capacity perfectly follows responsibility. Bottlenecks arise from scarcity combined with concentration/misalignment.

This is why the primary theoretical quantity should be `Lambda` rather than a concentration index alone.

A normalized Herfindahl concentration measure remains useful descriptively:

`H_g = [sum_i (p_i^(g))^2 - 1/n] / [1 - 1/n]`,

but `H_g` is not sufficient to determine local overload for arbitrary capacity allocations.

## 6. Minimal one-parameter concentration family

For analytical work, use a symmetric one-heavy-carrier family in each module. Let `h in [0,1]` and define

`p_1 = [1 + (n-1) h] / n`,

`p_i = (1-h) / n`, for `i = 2,...,n`.

Then

- `h = 0` gives perfectly diffuse responsibility;
- `h = 1` gives complete concentration on one carrier.

For this family, the normalized Herfindahl index satisfies exactly

`H = h^2`.

Under uniform capacity allocation, `x_i = 1/n`, the mismatch factor is

`Lambda = n p_1 = 1 + (n-1) h`

or

`Lambda = 1 + (n-1) sqrt(H)`.

Hence

`chi = Omega [1 + (n-1) sqrt(H)]`,

with a large-window congestion boundary

`Omega_c(H) = 1 / [1 + (n-1) sqrt(H)]`.

This relation is a testable analytical prediction, not yet a simulation result.

## 7. Relational coordination state

Each interface channel `e` carries a relational state

`w_e(t) in [0,1]`.

For an admitted interaction, retain the validated legacy reinforcement/decay law:

Success with probability `pi`:

`w' = w + alpha (1-w)`.

Failure with probability `1-pi`:

`w' = (1-beta) w`.

A blocked demand leaves `w` unchanged.

The competence parameter `pi` is treated independently from concentration in the minimal theory. This allows us to separate the causal effects of role concentration and interface effectiveness.

## 8. Mean relational dynamics per admitted interaction

Let

`kappa(pi) = alpha pi + beta (1-pi)`.

The exact conditional mean recursion per admitted interaction is

`E[w_(s+1)] = [1-kappa(pi)] E[w_s] + alpha pi`.

Its fixed point is

`w_star(pi) = alpha pi / [alpha pi + beta (1-pi)]`.

A necessary mean-field feasibility condition for tie readiness at threshold `theta` is

`w_star(pi) > theta`.

The corresponding critical interaction-success probability is

`pi_c = theta beta / [alpha(1-theta) + theta beta]`.

For `w_star(pi) > theta`, the mean-field number of admitted interactions required to move from `w0` to `theta` is

`s_theta(pi) = log[(w_star(pi)-theta)/(w_star(pi)-w0)] / log[1-kappa(pi)]`.

This is an analytical service-requirement proxy; it is not claimed to equal the exact stochastic first-passage expectation.

## 9. Competence as a service-efficiency gain

Instead of using the microscopic difference `Delta pi = pi_s - pi_o` as the main macroscopic control variable, define

`G = s_theta(pi_o) / s_theta(pi_s)`.

`G > 1` means the high-competence interface requires fewer admitted interactions to reach the relational threshold.

This places competence and capacity in commensurable units:

- capacity controls the supply of admitted interactions;
- competence controls the number of admitted interactions required.

With the legacy values `alpha=0.08`, `beta=0.02`, `w0=0.40`, `theta=0.80`, `pi_o=0.55`, and `pi_s=0.65`, the mean-field proxy gives approximately

`s_theta(pi_o) = 48.8`,

`s_theta(pi_s) = 29.2`,

and therefore

`G ~= 1.67`.

These numbers are only a sanity check linking the reduced theory to the legacy parameterization.

## 10. Provisional switching law

In the large-window approximation, local overload reduces the service rate of the most stressed interface channels by approximately a factor `1/chi` once `chi > 1`.

Relative to a diffuse ordinary-competence benchmark, the coordination-time ratio is therefore expected to scale approximately as

`T / T0 ~= max(1, chi) / G`.

The corresponding competence-congestion switching condition is

`chi ~= G`,

or

`Omega Lambda ~= G`.

Define the dimensionless coordination-stress number

`Xi = Omega Lambda / G`.

Then the central analytical hypothesis is

- `Xi < 1`: competence can compensate for concentration-induced congestion;
- `Xi > 1`: congestion dominates competence and the interface becomes bottleneck-prone.

A strong result would be a collapse of simulation outcomes obtained from different `(Omega, responsibility allocation, capacity allocation, pi)` combinations when plotted against `Xi`.

## 11. Macroscopic observables

Tie readiness indicator:

`r_e(t) = I[w_e(t) >= theta]`.

Boundary readiness:

`R(t) = (1/m) sum_e r_e(t)`.

For the minimal analytical model, use full interface readiness as the primary endpoint:

`T = inf{t : R(t) = 1}`.

Alternative readiness fractions `q < 1` are robustness analyses, not core control parameters.

Additional observables:

- blocked-demand fraction;
- actor-level utilization;
- maximum utilization;
- distribution/tail of `T`;
- right-censoring if a finite simulation horizon is imposed.

## 12. Mean-field versus stochastic claims

The following are analytical/mean-field hypotheses to be tested, not assumed truths:

1. congestion onset is controlled primarily by `chi = Omega Lambda`;
2. competence-congestion switching occurs near `Xi = 1`;
3. finite `D` smooths the sharp large-window boundary;
4. capacity matching `x=p` removes the first-order concentration penalty;
5. outcomes from different microscopic parameter combinations may collapse under `Xi`.

## 13. Important interpretation guardrail

With the inherited relational update law, blocked interactions do not passively decay relational state. Therefore finite capacity changes the rate at which relational learning occurs, but it does not directly change `w_star(pi)`.

Consequently, we should initially describe `Xi ~= 1` as a **dynamical switching/regime boundary**, not as an equilibrium phase transition. A genuine capacity-dependent stationary transition would require an additional passive-decay/forgetting mechanism, which should not be introduced unless the simpler model proves insufficient.

## 14. Core parameter hierarchy

### Primitive quantities

- `D`: demand attempts per capacity window;
- `C`: total capacity per module;
- `p_i`: interface-demand/responsibility shares;
- `x_i`: capacity shares;
- `pi`: interaction competence.

### Dimensionless/control quantities

- `Omega = D/C`;
- `Lambda = max p_i/x_i`;
- `G = s_theta(pi_o)/s_theta(pi_s)`;
- `Xi = Omega Lambda/G`.

### Descriptive/robustness quantities

- `H`: normalized concentration index;
- `n`, `m`: system size/interface size;
- `theta`, `q`, `w0`, `alpha`, `beta`: fixed core values, later sensitivity checks;
- modular internal topology: legacy-validation/robustness layer.

## 15. Decision gate before implementation

Recommended locks before writing finite-capacity code:

1. **Concentration meaning:** use `p_i`/`H` for concentration of interface responsibility/demand, not capacity concentration.
2. **Capacity allocation:** use uniform `x_i=1/n` in the core mechanism test; introduce `x_i=p_i` as the analytically optimal matching benchmark and intermediate allocations only afterward.
3. **Primary theoretical variables:** use `Omega`, `Lambda`, and `G`; treat `Xi=Omega Lambda/G` as the candidate reduced control number.
4. **Relational dynamics:** retain the legacy reinforcement/failure law initially; do not add passive decay merely to create a stationary phase transition.
5. **Core endpoint:** use full boundary readiness (`q=1`) in the minimal theory, with the legacy `q=0.8` and other values as robustness checks.

No simulation extension should be implemented until these decisions are reviewed and locked.