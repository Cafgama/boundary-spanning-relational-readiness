# E5 stochastic execution lock

## Status

**Frozen before any E5 stochastic trajectory is generated.**

This supplement resolves execution details that do not change the scientific grid in `docs/capacity_experiment_e5_design.md`.

## Horizon

Use

\[
\boxed{\text{max\_windows}=20}
\]

for the diffuse benchmark, every concentrated capacity-constrained trajectory, and every paired no-capacity counterfactual. Thus

\[
T_{\max}=20D.
\]

If any cell is censored, the analysis will retain censoring and use finite-horizon RMST rather than increasing the horizon after inspecting the result.

## Seed indices

For the targeted concentration set

\[
k\in\{4,7,8,9,10,11,13,15\},
\]

set

\[
\boxed{i_h=k}.
\]

For the scarcity grid use

\[
\Omega=0.6\to i_\Omega=1,
\qquad
\Omega=1.0\to i_\Omega=2,
\qquad
\Omega=1.5\to i_\Omega=3.
\]

The seeds are therefore exactly

\[
\boxed{\text{demand seed}=530000000+k\,10^6+i_\Omega\,10^4+r}
\]

and

\[
\boxed{\text{learning seed}=630000000+k\,10^6+i_\Omega\,10^4+r.}
\]

The specialist-competence index and capacity-policy index do not enter either seed.

For the diffuse ordinary benchmark use `k=0` in these formulas.

## Deterministic-map inspection

The pre-data deterministic map was generated in CI run `33814861015`, before stochastic E5 implementation. It contains 90 cells and all three preregistered regimes.

Across both policies the map contains:

- 70 structural-win cells;
- 15 competence-rescuable cells;
- 5 unrescuable cells.

All 45 matched-capacity cells are structural wins at the deterministic level. The three-regime structure arises under uniform capacity, where there are 25 structural-win, 15 competence-rescuable, and 5 unrescuable cells.

This inspection does **not** change the previously frozen stochastic concentration grid.

## Analysis rule

The deterministic regime labels and continuous `ell_star` values generated before stochastic data are immutable E5 predictions. Stochastic results may support, blur, or contradict those boundaries, but the deterministic roots will not be refit or reclassified after production.
