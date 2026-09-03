# Experiment E3 — Learning Focus × Capacity Congestion

**Status:** PRE-DATA DESIGN. Frozen before the first E3 screening result is inspected.

## 1. Scientific question

E2 established that responsibility concentration accelerates transferable interface learning even when competence is homogeneous and no capacity blocking exists.

E3 asks the next single-mechanism question:

> When does finite interface capacity interrupt that learning-focus benefit?

Competence remains homogeneous and maximal (`ell=1`). The only new mechanism relative to E2 is finite per-window capacity.

## 2. Fixed learning model

Use the locked continuous readiness endpoint

`W_g(t) = sum_i p_i w_i(t)`

and

`T = inf{t : min(W_A(t),W_B(t)) >= Theta}`.

Core parameters:

- `n = 4` actors per module;
- common initial state `w0 = 0.4`;
- learning increment `alpha = 0.08`;
- homogeneous learning effectiveness `ell = 1`;
- readiness threshold `Theta = 0.8`.

Capacity resets at the start of each window. Actor learning states persist across windows.

## 3. Responsibility family

Use the locked one-heavy family

`p_1 = [1+3h]/4`,

`p_i>1 = [1-h]/4`.

Set

`h = k/15`, for `k = 0,1,...,15`.

This gives 16 concentration levels from diffuse (`h=0`) to complete concentration (`h=1`). For this family `H=h^2`.

## 4. Capacity scale and integer-compatible h grid

Fix `C=60` capacity units per module per window.

The chosen `h=k/15` grid makes the matched allocation exactly integer-compatible:

- heavy-carrier capacity under `x=p` is `c_1=15+3k`;
- each ordinary-carrier capacity is `c_o=15-k`.

These sum exactly to 60 for every `k`. Therefore the matched arm has exactly `x_realized=p` and `Lambda=1` with no largest-remainder artifact.

The uniform-capacity arm is also exact: `x_i=1/4`, hence `c_i=15` for all four actors. For the uniform arm, `Lambda=1+3h`.

This integer-compatible design is intentional: E3 should test learning versus mismatch, not integer discretization.

## 5. Capacity policies

For every responsibility architecture compare two policies using the same demand realization.

### M — matched capacity

`x=p`.

Purpose: preserve responsibility concentration and its learning-focus benefit while removing deterministic allocation mismatch.

### U — uniform capacity

`x_i=1/4`.

Purpose: hold total capacity fixed while creating responsibility-capacity mismatch as concentration rises.

The causal contrast `U-M` isolates the cost of failing to move capacity with responsibility.

## 6. Scarcity grid

Use

`Omega in {0.4,0.6,0.8,1.0,1.2,1.5,2.0}`.

Since `C=60`, all demand counts are integer:

`D in {24,36,48,60,72,90,120}`.

Capacity resets every `D` attempted interactions. Use `max_windows=10` for screening, so `T_max=10D`.

## 7. Pre-data analytical diagnostics

For each `h`, compute both:

- `t0_real(h)`: the real-valued root of the exact first-moment law;
- `t0_integer(h)`: the first integer attempt at which the exact first moment reaches `Theta`.

The exact no-capacity first moment is

`E[W(t)] = 1-(1-w0) sum_i p_i (1-alpha p_i)^t`.

Use `t0_real` in the timescale diagnostic

`Psi = Lambda t0_real / C`.

Also compute

`Lambda = max_i p_i/x_i`,

`chi = Omega Lambda`.

Interpretations:

- `chi>1`: deterministic first exhaustion occurs before the capacity window ends;
- `Psi>1`: deterministic first exhaustion occurs before the no-capacity mean-readiness timescale;
- the candidate deterministic congestion-relevance region is `chi>1 AND Psi>1`.

These are onset diagnostics, not assumed universal delay laws.

## 8. Paired no-capacity counterfactual and monotonicity invariant

For every stochastic replication and responsibility vector, compute a no-capacity trajectory using the **same demand seed** as the capacity-constrained trajectory.

Because E3 fixes `ell=1`, there is no competence noise. The paired comparison therefore uses identical attempted endpoint pairs.

Define

`DeltaT = T_capacity - T_free`

when both first passages are observed.

This common-random-number comparison isolates delay caused by capacity blocking.

A stronger pathwise invariant follows. The capacity-constrained trajectory can only suppress learning events that are present in the no-capacity trajectory. Therefore for every actor and every attempted time,

`N_i^capacity(t) <= N_i^free(t)`, hence `w_i^capacity(t) <= w_i^free(t)` and `W_g^capacity(t) <= W_g^free(t)`.

Consequently, whenever both first passages are observed,

`DeltaT >= 0`.

The screening code must assert this pathwise. Any negative paired delay is an implementation error, not a scientific result.

## 9. Screening replication count

Use `R=200` replications per cell.

Total coupled cells:

`16 h values × 7 Omega values × 2 capacity policies = 224`.

Total coupled trajectories:

`224 × 200 = 44,800`.

No-capacity paired trajectories can be reused across the two capacity policies within each `(h,Omega,rep)` combination because responsibility and demand seed are identical.

## 10. Pre-data hypotheses

### E3-H1 — Matched-capacity protection

When `x=p`, concentration should retain the E2 learning-focus effect while deterministic local mismatch disappears (`Lambda=1`). Any residual delay relative to the no-capacity process is a finite-window stochastic or global-capacity effect, not responsibility-capacity mismatch.

### E3-H2 — Two-gate congestion relevance

The largest systematic positive delays in the uniform-capacity arm should occur where both `chi>1` and `Psi>1`.

Finite-window fluctuations may blur these boundaries, especially near one, so the prediction is qualitative/onset-based rather than a strict zero-delay theorem.

### E3-H3 — Re-entrant concentration effect

At fixed sufficiently large `Omega`, the uniform-capacity delay is predicted to be non-monotone in concentration:

- near `h=0`, mismatch is weak and `Psi<1`;
- at intermediate `h`, mismatch moves exhaustion earlier while readiness still requires substantial learning, producing `Psi>1`;
- near `h=1`, focused practice becomes fast enough to outrun the bottleneck and `Psi` falls below one again.

Thus maximum mismatch need not imply maximum readiness delay.

### E3-H4 — Exact complete-concentration endpoint

At `h=1`, all demand falls on actor 1. Under uniform capacity with `C=60`, actor 1 receives 15 slots per window. With `ell=1`, `w0=0.4`, `alpha=0.08`, and `Theta=0.8`, 14 productive encounters are sufficient for readiness.

For the E3 Omega grid, every window contains at least 24 attempts, so the capacity-constrained and no-capacity trajectories should both reach readiness at attempt 14 before the 15-slot carrier capacity is exhausted.

Therefore `DeltaT(h=1)=0` is an exact endpoint prediction for both capacity policies across the full E3 Omega grid.

### E3-H5 — Pathwise nonnegative delay

For every paired realization in which both first passages are observed,

`DeltaT >= 0`.

This is an exact monotonicity invariant implied by suppression-only capacity blocking.

## 11. Raw outputs

Store at minimum:

- `policy` (`matched`, `uniform`);
- `h`, `H`;
- `replication`, `demand_seed`;
- `C`, `D`, `Omega`;
- realized `Lambda`, `chi`;
- analytical `t0_real`, `t0_integer`, `Psi`;
- `T_capacity`, `T_capacity_tilde`, `delta_capacity`;
- `T_free`, `T_free_tilde`, `delta_free`;
- paired `DeltaT` when estimable;
- `n_attempted`, `n_served`, `n_blocked`, `blocked_fraction` up to stopping/horizon;
- `first_block_attempt`;
- `n_windows_started`;
- terminal `Wmin`.

## 12. Screening summaries

For each `(policy,h,Omega)` report:

- event fraction;
- mean and median observed first passage if uncensored;
- mean `T_capacity_tilde` as the finite-horizon RMST estimator if censoring occurs;
- mean paired `DeltaT` over estimable pairs;
- median and 90th/95th percentiles of `DeltaT`;
- mean blocked fraction;
- probability of any block before readiness;
- mean first-block attempt conditional on blocking;
- analytical `chi` and `Psi`.

Do not interpret raw observed-time means as survival estimands if censoring is non-negligible.

## 13. Decision rule after screening

E3 is considered mechanistically successful if:

1. the matched arm preserves the E2 concentration advantage with comparatively small capacity delay;
2. the uniform arm develops systematic delay in the predicted `chi/Psi` relevance region;
3. the concentration profile shows evidence consistent with the predicted intermediate-concentration penalty rather than a simple monotone increase;
4. the exact `h=1` zero-delay endpoint is reproduced;
5. the pathwise nonnegative-delay invariant holds for every estimable pair.

Only after these checks pass should specialist competence (`ell_s>ell_o`) be introduced in E4.
