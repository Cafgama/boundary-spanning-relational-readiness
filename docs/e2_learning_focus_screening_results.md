# E2 Learning-Focus Screening — Results

## Status

Screening experiment validating the learning-focus mechanism before capacity is introduced.

- GitHub Actions run: `33780670305`
- Artifact: `e2-learning-focus-screening`
- Artifact digest: `sha256:bb01ed67f2a3b5db1e3de9c2c2761db23773ea5fe75e711c70a9bb9595b3b941`
- Replications per concentration value: `R=1000`
- Total raw rows: `10,000`
- `n=4`, `w0=0.4`, `alpha=0.08`, `ell=1`, `Theta=0.8`
- No capacity blocking.

## Pre-data predictions

E2 was pre-registered to test only

`responsibility concentration -> exposure concentration -> transferable learning -> continuous readiness`.

The exact no-capacity first moment is

`E[W_g(t)] = 1-(1-w0) sum_i p_i (1-alpha ell p_i)^t`.

The exact initial expected increment is

`Delta W_0 = alpha ell (1-w0) sum_i p_i^2`.

For the one-heavy family with `n=4`,

`sum_i p_i^2 = (1+3h^2)/4`.

Thus concentration was predicted to increase initial learning focus and reduce the baseline `Theta=0.8` crossing time on the screened `h` grid.

## Official screening summary

| h | H | S2 | initial increment | mean T | q50 T | q90 T | q95 T | mean module T | exact-mean crossing |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.0 | 0.00 | 0.2500 | 0.01200 | 55.606 | 55 | 58 | 58 | 54.881 | 55 |
| 0.1 | 0.01 | 0.2575 | 0.01236 | 54.990 | 55 | 57 | 58 | 54.271 | 54 |
| 0.2 | 0.04 | 0.2800 | 0.01344 | 53.310 | 53 | 55 | 57 | 52.521 | 52 |
| 0.3 | 0.09 | 0.3175 | 0.01524 | 50.486 | 50 | 53 | 54 | 49.722 | 50 |
| 0.4 | 0.16 | 0.3700 | 0.01776 | 46.367 | 46 | 48 | 49 | 45.722 | 46 |
| 0.5 | 0.25 | 0.4375 | 0.02100 | 40.629 | 40 | 42 | 42 | 40.201 | 40 |
| 0.6 | 0.36 | 0.5200 | 0.02496 | 34.056 | 34 | 36 | 36 | 33.631 | 34 |
| 0.7 | 0.49 | 0.6175 | 0.02964 | 27.684 | 27 | 30 | 30.05 | 26.903 | 27 |
| 0.8 | 0.64 | 0.7300 | 0.03504 | 21.984 | 22 | 24 | 24 | 21.195 | 21 |
| 0.9 | 0.81 | 0.8575 | 0.04116 | 17.831 | 18 | 19 | 19 | 17.241 | 17 |

All cells had event fraction `1.0`; the administrative `T_max=300` never bound the screening.

## Main result

The stochastic system first-passage time decreases monotonically over the entire baseline concentration grid.

From `h=0` to `h=0.9`, mean system readiness time falls from `55.606` to `17.831`, a reduction of approximately `67.9%`.

Over the same interval, the exact initial expected learning increment rises from `0.01200` to `0.04116`, a factor of `3.43`.

Thus responsibility concentration creates a strong learning-focus benefit even when:

- all actors have identical learning effectiveness;
- every attempted interaction is admitted;
- no capacity bottleneck exists.

The effect therefore cannot be attributed to competence or congestion.

## Analytical agreement

The exact first-moment crossing closely tracks the average module-level stochastic crossing.

Across the ten screened concentration values, the largest absolute difference between the mean of `T_A,T_B` and the exact-mean crossing benchmark is about `0.52` attempt.

The two-module system time is slightly larger because

`T = max(T_A,T_B)`.

The observed system-minus-mean-crossing difference ranges from about `0.06` to `1.31` attempts across the grid.

This agreement supports the interpretation that the exact first-moment law captures the central exposure-concentration mechanism, while the residual difference is a first-passage/order-statistic effect from requiring both modules to cross.

## Theoretical implication

Responsibility concentration has two distinct potential roles in the full theory:

1. **Learning focus:** it concentrates exposure on high-responsibility actors. At early time the effect is controlled exactly by `sum p_i^2`; in the one-heavy family this is a direct function of `H`.
2. **Congestion risk:** when capacity does not follow responsibility, concentration can increase `Lambda=max p_i/x_i` and move the system toward capacity exhaustion.

Therefore `H` and `Lambda` should not be treated as interchangeable concentration measures:

- `H` has a direct role in the learning-focus layer;
- `Lambda` controls deterministic first-exhaustion onset together with `Omega`.

## Sufficiency guardrail

`sum p_i^2` determines the exact initial learning gain under homogeneous competence, but it does not necessarily determine the complete readiness trajectory for arbitrary responsibility distributions. Later-time learning depends on the full set of `p_i`, just as `Lambda` determines capacity onset but not the whole post-onset blocking curve.

## Interpretation guardrail

E2 provides no evidence about capacity bottlenecks, specialist competence, shocks, or topology robustness.

Its contribution is narrower and stronger:

> before capacity is constrained, responsibility concentration alone can accelerate demand-weighted coordination readiness by focusing repeated learning opportunities on the actors who carry the largest share of interface demand.

The next experiment must introduce finite capacity while keeping competence homogeneous, so that learning focus and congestion can be separated causally.