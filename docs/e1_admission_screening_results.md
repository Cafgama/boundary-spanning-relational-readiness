# E1 Admission-Convergence Screening — Results

## Status

Screening experiment only. These results validate the admission/capacity mechanism before relational learning is introduced.

- GitHub Actions run: `33258458237`
- Artifact: `e1-admission-convergence-screening`
- Artifact digest: `sha256:49963a2ae11143263ede02ec785a2f61b43e3db330173c2403d964ba2f1a3800`
- Replications per cell: `R=200`
- Conditions: diffuse matched, concentrated matched, concentrated uniform
- Capacity scales: `C in {60,300,1500}`
- Omega grid: `{0.4,0.5,0.6,0.8,1.0,1.2,1.5,2.0,2.5}`

## Main validation result

The finite-window stochastic model converges toward the pre-derived fluid blocking curves as `C` increases.

The strongest pre-registered finite-size prediction concerned the deterministic first-exhaustion boundary `chi=1`. At that boundary, mean blocked fraction was predicted to scale as order `C^(-1/2)`.

### Diffuse matched (`Lambda=1`, boundary at `Omega=1`)

| C | mean blocked fraction | mean * sqrt(C) |
|---:|---:|---:|
| 60 | 0.129167 | 1.000521 |
| 300 | 0.058550 | 1.014116 |
| 1500 | 0.025760 | 0.997681 |

### Concentrated matched (`Lambda=1`, boundary at `Omega=1`)

| C | mean blocked fraction | mean * sqrt(C) |
|---:|---:|---:|
| 60 | 0.125833 | 0.974701 |
| 300 | 0.053617 | 0.928668 |
| 1500 | 0.025560 | 0.989935 |

### Concentrated uniform (`Lambda=2`, boundary at `Omega=0.5`)

| C | mean blocked fraction | mean * sqrt(C) |
|---:|---:|---:|
| 60 | 0.060000 | 0.464758 |
| 300 | 0.029067 | 0.503449 |
| 1500 | 0.013240 | 0.512783 |

The near-constant scaled values strongly support the predicted `C^(-1/2)` critical-window correction.

## Concentration versus mismatch

Diffuse matched and concentrated matched have different responsibility concentration but the same `Lambda=1`. Their blocking curves become nearly indistinguishable as the window scale increases. At `C=1500`, the absolute difference in mean blocked fraction is at most about `7e-4` across the screened Omega grid and is effectively zero away from the critical region.

By contrast, concentrated uniform has the same responsibility concentration as concentrated matched but `Lambda=2`, shifting deterministic congestion onset from `Omega=1` to `Omega=0.5` exactly as derived.

This supports the core causal distinction:

> concentration changes the responsibility architecture, whereas deterministic bottleneck onset is controlled by responsibility-capacity mismatch.

## Convergence to fluid theory

Across all conditions/Omega values, the mean absolute deviation from the fluid blocked fraction decreases with scale:

| C | mean absolute deviation |
|---:|---:|
| 60 | 0.026461 |
| 300 | 0.008294 |
| 1500 | 0.003353 |

The largest deviations occur in the finite-window critical region, as expected.

## Interpretation guardrail

E1 validates only the admission layer. No conclusion about competence, learning, relational readiness, first-passage time, or the candidate stress number `Xi` should be drawn from E1.

The next model layer can therefore treat the capacity/admission mechanism as a validated upstream process rather than modifying it to fit relational outcomes.
