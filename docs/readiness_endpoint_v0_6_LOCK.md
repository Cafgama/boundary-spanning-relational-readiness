# Continuous Demand-Weighted Readiness — Model v0.6 LOCK

**Status:** LOCKED for the reduced core model.

## 1. Decision

The primary reduced-model readiness state is continuous and demand weighted.

For module `g`,

`W_g(t) = sum_i p_i^(g) w_i^(g)(t)`.

The system readiness coordinate is

`W_min(t) = min(W_A(t), W_B(t))`.

First passage is

`T_Theta = inf{t : W_min(t) >= Theta}`.

Core baseline: `Theta = 0.8`.

Threshold robustness will examine nearby values; `Theta` is a service/readiness threshold, not a primitive mechanism.

## 2. Natural-language meaning

`w_i` is accumulated transferable interface-coordination readiness of actor `i`.

`W_g` is the readiness level experienced by interface demand on side `g`, averaged over the responsibility distribution. High-responsibility actors therefore matter proportionally more, while actors with vanishing responsibility have vanishing influence.

The conservative system coordinate `min(W_A,W_B)` requires both sides of the interface to reach the target readiness level.

## 3. Why the earlier binary coverage candidate was not locked

The pre-lock stress test of

`R_g = sum_i p_i I[w_i >= theta]`

with `R_g >= q` revealed large combinatorial jumps in first passage when a small change in `p` changed the number of discrete actors required to exceed `q`.

For the canonical `n=4`, `q=0.8` one-heavy family, the required carrier count changes at responsibility-geometry boundaries. Those jumps are legitimate for a hard service-level rule, but they risk making the fundamental theory depend on an arbitrary thresholded actor count.

The continuous state `W_g` avoids this extra coarse graining and removes the need for two nested thresholds (`theta` at actor level and `q` at system level).

The binary coverage endpoint is retained as a robustness/managerial interpretation, not the reduced core.

## 4. Parameter reduction

The core first-passage model now needs only one readiness threshold `Theta`.

The previous actor-level productive-event threshold `K_theta` remains a useful local competence benchmark and unit test, but it is not the primary system endpoint.

## 5. Exact no-capacity first-moment law

When every demand is admitted, endpoint `i` is selected with probability `p_i` per global attempt and converts an admitted interaction into productive learning with probability `ell_i`.

With update

`w_i' = w_i + alpha(1-w_i)`

on a productive event, the exact expectation satisfies

`E[w_i(t+1)] = (1-alpha p_i ell_i) E[w_i(t)] + alpha p_i ell_i`.

Hence

`E[w_i(t)] = 1 - (1-w_i(0))(1-alpha p_i ell_i)^t`.

Therefore

`E[W_g(t)] = 1 - sum_i p_i (1-w_i(0))(1-alpha p_i ell_i)^t`.

For common initial state `w0` and homogeneous learning effectiveness `ell`,

`E[W_g(t)] = 1 - (1-w0) sum_i p_i (1-alpha ell p_i)^t`.

This identity is exact for the first moment under the no-capacity process.

## 6. Learning-focus result

At the first attempted interaction,

`E[W_g(1)] - w0 = alpha ell (1-w0) sum_i p_i^2`.

Thus responsibility concentration directly increases the initial rate of demand-weighted learning through the second moment of the responsibility distribution.

For the one-heavy family,

`sum_i p_i^2 = [1 + (n-1)h^2]/n`.

Because the normalized responsibility Herfindahl satisfies `H=h^2`, concentration has a direct causal role in the learning layer even though it is not the primitive cause of capacity congestion.

This yields an important separation:

- capacity congestion onset is controlled by mismatch `Lambda=max p_i/x_i` together with scarcity `Omega`;
- learning focus is controlled by the responsibility distribution itself, with `sum p_i^2` determining the initial learning gain under homogeneous competence.

## 7. E2 prediction

With no capacity blocking and homogeneous competence, increasing concentration should accelerate crossing of a moderate continuous readiness threshold because learning opportunities are focused on actors carrying the largest demand weights.

At very high readiness thresholds, low-responsibility actors can dominate the residual tail, so concentration need not accelerate all possible thresholds. This belongs to threshold robustness rather than the core E2 claim.

## 8. Next experiment

E2 tests only the no-capacity learning-focus mechanism:

`responsibility concentration -> exposure concentration -> transferable learning -> continuous readiness`.

No finite capacity, mismatch, specialist competence advantage, shocks, or topology robustness is introduced in E2.