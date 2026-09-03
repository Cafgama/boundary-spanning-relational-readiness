# Capacity–Learning Timescale Gate — Model v0.7 / E3

**Status:** THEORY GATE. Derived after E2, before the first coupled capacity-learning experiment.

## 1. Why `chi` is not sufficient once readiness has a timescale

The admission theory establishes that deterministic capacity blocking begins within a window when

`chi = Omega Lambda > 1`,

with

`Lambda = max_i p_i/x_i`.

This answers:

> Does some actor exhaust capacity before the window ends?

After E2, a second question becomes unavoidable:

> Does capacity exhaust before the interface would have become ready anyway?

A bottleneck that occurs only after readiness has already been reached cannot affect the readiness first passage.

## 2. No-capacity readiness timescale

Let `t0(p,ell,Theta)` denote the no-capacity first-moment crossing associated with

`E[W(t)] = 1 - sum_i p_i (1-w_i(0))(1-alpha p_i ell_i)^t`.

For homogeneous `ell` and common `w0`, this is the first `t` satisfying

`1-(1-w0) sum_i p_i (1-alpha ell p_i)^t >= Theta`.

For the diffuse reference `p_i=1/n`, the real-valued crossing is

`t_diff = ln[(1-Theta)/(1-w0)] / ln[1-alpha ell/n]`.

Define the global learning-window ratio

`rho = t_diff / C`.

Interpretation:

- `rho << 1`: the reference interface learns on a timescale much shorter than one module capacity budget;
- `rho >> 1`: readiness intrinsically requires multiple capacity-budget scales.

Unlike E1, `C` is therefore not purely a finite-size parameter once learning is present.

## 3. Architecture-specific first-exhaustion comparison

Before any capacity exhaustion, the capacity-constrained and no-capacity processes have identical admission dynamics.

The deterministic first local exhaustion time in attempted interactions is

`t_c = C/Lambda`.

Therefore define

`Psi = t0 / t_c = Lambda t0 / C`.

Interpretation:

- `Psi < 1`: the no-capacity readiness benchmark occurs before deterministic first exhaustion;
- `Psi > 1`: deterministic first exhaustion occurs before the no-capacity readiness benchmark.

`Psi` is a derived crossover diagnostic, not assumed to provide universal data collapse.

## 4. Two necessary gates for deterministic congestion to affect readiness

At the first-order deterministic level, capacity congestion can influence the readiness trajectory only if both conditions hold:

1. the window lasts long enough for exhaustion to occur:

   `chi = Omega Lambda > 1`;

2. readiness has not already been reached before first exhaustion:

   `Psi = Lambda t0/C > 1`.

Thus the candidate congestion-relevance region is

`chi>1 AND Psi>1`.

These are necessary onset conditions, not yet a sufficient formula for the magnitude of the readiness delay.

## 5. Canonical baseline implication

For E2 baseline parameters

- `n=4`
- `w0=0.4`
- `alpha=0.08`
- `ell=1`
- `Theta=0.8`

and proposed E3 core capacity scale `C=60`, the diffuse real-valued crossing is about `54.38`, giving

`rho ~= 0.906`.

For matched allocation `x=p`, `Lambda=1`. The E2 no-capacity crossing is below `C` across the one-heavy baseline family, so the first-moment prediction is that readiness generally outruns deterministic matched-capacity exhaustion.

For uniform capacity `x_i=1/4`,

`Lambda = 1+3h`.

Here concentration has opposing effects:

- increasing `h` raises `Lambda` and moves exhaustion earlier;
- increasing `h` also lowers `t0` through the E2 learning-focus mechanism.

Therefore `Psi(h)=(1+3h)t0(h)/C` need not be monotone.

Using the exact E2 first-moment law, `Psi` is below one near both the diffuse and nearly fully concentrated limits and exceeds one over an intermediate concentration range for the `C=60` baseline. This predicts a possible **re-entrant congestion-relevance regime**: moderate/intermediate concentration may be more exposed to capacity-induced readiness delay than either extreme.

This is a pre-E3 theoretical prediction and must not be reported as a simulation result.

## 6. Why complete concentration can outrun congestion

At `h=1`, all responsibility falls on one actor. Under uniform capacity with `n=4`, that actor has `C/4=15` interaction slots when `C=60`.

With `ell=1`, the actor needs 14 productive interactions to move from `w0=0.4` to `Theta=0.8` under the retained learning rule.

Thus in this particular baseline, complete concentration can reach readiness just before the carrier exhausts its 15-slot capacity budget.

This explains mechanistically why maximum mismatch need not imply maximum readiness delay: concentrated practice can become fast enough to outrun the bottleneck.

## 7. E3 design consequence

The first coupled experiment should keep competence homogeneous (`ell=1`) and compare, for the same responsibility architecture:

- matched capacity `x=p`;
- uniform capacity `x_i=1/n`.

Vary `h` and `Omega` while holding the learning/capacity scale fixed initially.

The experiment should test separately:

- the admission onset boundary `chi=1`;
- the readiness-before-exhaustion diagnostic `Psi=1`;
- the actual stochastic delay relative to the no-capacity E2 benchmark.

Only after this mechanism is understood should specialist competence (`ell_s>ell_o`) be introduced.

## 8. Guardrail on scaling C

In E1, changing `C` at fixed `Omega` was a legitimate finite-window convergence study because no learning state existed.

In the coupled model, changing `C` at fixed `alpha,ell,w0,Theta` changes `rho` and therefore changes the physical relation between learning and capacity-window length.

Accordingly, coupled-model `C` robustness must either:

- be interpreted as changing the learning-capacity timescale itself; or
- rescale learning parameters to hold a chosen macroscopic timescale ratio fixed.

It must not be described automatically as a pure finite-size check.