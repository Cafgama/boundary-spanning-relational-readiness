# E2 — Learning Focus Without Congestion

**Status:** pre-data design.

## Scientific question

Does concentrating interface responsibility accelerate continuous demand-weighted transferable readiness when every interaction is admitted and all actors have identical learning effectiveness?

E2 isolates one mechanism only:

`responsibility concentration -> exposure concentration -> transferable learning -> readiness`.

Capacity scarcity, capacity mismatch, specialist competence advantage, shocks, and topology variation are absent.

## Core model

Two symmetric modules, each with `n=4` interface actors.

One-heavy responsibility family:

`p_1 = [1+3h]/4`,

`p_2=p_3=p_4=[1-h]/4`.

Concentration grid:

`h in {0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9}`.

The normalized responsibility Herfindahl is exactly

`H=h^2`.

No capacity constraint is imposed: every attempted pair is admitted.

Homogeneous learning effectiveness is fixed at

`ell=1`.

Thus every admitted endpoint encounter produces one transferable learning update. This removes competence noise and isolates stochastic exposure allocation.

Learning parameters:

- `w0=0.4`
- `alpha=0.08`
- continuous system readiness threshold `Theta=0.8`.

Core endpoint:

`T = inf{t : min(W_A(t),W_B(t)) >= Theta}`,

where

`W_g(t)=sum_i p_i w_i(t)`.

`T_max=300` is an administrative censoring limit expected to be nonbinding in this screening.

## Exact pre-data theory

For homogeneous `ell` and common `w0`, the no-capacity first moment is exactly

`E[W_g(t)] = 1 - (1-w0) sum_i p_i (1-alpha ell p_i)^t`.

The initial expected increment is

`Delta W_0 = alpha ell (1-w0) sum_i p_i^2`.

For the one-heavy family,

`sum_i p_i^2 = [1+3h^2]/4 = [1+3H]/4`.

Therefore E2 has an exact pre-data learning-focus prediction:

> responsibility concentration increases the initial expected demand-weighted learning rate even though no actor is intrinsically more competent.

Define `T_mean_cross(h)` as the first integer `t` for which the exact first moment reaches `Theta`.

For the baseline parameterization, theory predicts a monotone decline over the core grid, approximately from 55 attempts at `h=0` to 17 attempts at `h=0.9`.

This is a first-moment crossing benchmark; it is not identical to `E[T]` of the stochastic two-module first-passage process.

## Pre-registered predictions

1. `Delta W_0` increases exactly with `H` according to `[1+3H]/4`.
2. `T_mean_cross(h)` decreases monotonically on the baseline `Theta=0.8` grid.
3. The stochastic module crossing times `T_A,T_B` follow the same concentration ordering.
4. The system time `T=max(T_A,T_B)` is expected to lie above the single-module first-moment crossing because both modules must cross.
5. No claim is made that concentration accelerates arbitrarily high readiness thresholds. High-Theta tail behavior is a later robustness question.

## Screening replication plan

`R=1000` stochastic replications per concentration value.

Total raw rows: `10,000`.

Each row stores:

- concentration `h`, `H`, and `sum p_i^2`;
- replication and explicit demand/learning seeds;
- model parameters;
- analytical `T_mean_cross` and initial increment;
- `T_A`, `T_B`, system `T`, censoring fields;
- final `W_A`, `W_B`, and `W_min`.

Demand and learning RNG streams remain separate. With `ell=1`, the learning stream is formally present but has no substantive randomness.

## Interpretation guardrail

E2 cannot support claims about bottlenecks, scarcity, mismatch, specialist competence, or robustness to network topology.

Its only purpose is to establish whether responsibility concentration itself creates a learning-focus benefit in the transferable actor-state model before capacity constraints are introduced.