# E1 — Finite-Window Admission Convergence

## Scientific question

Does stochastic finite-window blocking converge to the analytically derived fluid admission law, including the exact first-exhaustion boundary `chi = Omega Lambda = 1`, as the capacity-window scale increases?

This experiment is admission-only. It contains no relational learning, competence, readiness, or first-passage dynamics.

## Why only three conditions

The experiment uses three deliberately chosen conditions so each pairwise contrast has a single causal interpretation.

### A. Diffuse matched

`n=4`

`p = [1/4, 1/4, 1/4, 1/4]`

`x = p`

Then

`H=0`, `Lambda=1`, `Omega_c=1`.

### B. Concentrated matched

Use the one-heavy family with `h=1/3`:

`p = [1/2, 1/6, 1/6, 1/6]`

and matched capacity

`x = p`.

Then

`H=1/9`, `Lambda=1`, `Omega_c=1`.

Contrast A -> B changes responsibility concentration while preserving exact proportional capacity matching. In the fluid limit both conditions have the same blocking law. Any finite-window difference therefore belongs to stochastic/discretization effects, not deterministic load mismatch.

### C. Concentrated mismatched

Keep exactly the same concentrated responsibility distribution as B,

`p = [1/2, 1/6, 1/6, 1/6]`,

but allocate capacity uniformly:

`x = [1/4, 1/4, 1/4, 1/4]`.

Then

`H=1/9`, `Lambda=2`, `Omega_c=1/2`.

Contrast B -> C holds responsibility concentration fixed and changes only capacity alignment. This is the clean causal test of mismatch.

## Why h=1/3

This value is intentionally didactic rather than empirically calibrated.

For `n=4`, it gives exact rational shares,

`p = [1/2, 1/6, 1/6, 1/6]`,

and the simple analytical identities

`H=h^2=1/9`,

`Lambda=1+3h=2`

under uniform capacity.

The resulting deterministic onset moves from `Omega=1` under matched capacity to `Omega=1/2` under uniform capacity.

## Fluid benchmarks

### Matched allocation: conditions A and B

For `x=p`, all positive-demand actors exhaust simultaneously at `s=1`.

Therefore

- `Omega <= 1`: `f_blocked = 0`;
- `Omega > 1`: `f_blocked = 1 - 1/Omega`.

### Canonical mismatch: condition C

The heavy carrier exhausts at `s=1/2`. The three ordinary carriers exhaust at `s=5/2`.

Therefore

- `Omega <= 1/2`: `f_blocked = 0`;
- `1/2 < Omega <= 5/2`: `f_blocked = 3/4 - 3/(8 Omega)`;
- `Omega > 5/2`: `f_blocked = 1 - 1/Omega`.

These are theoretical reference curves, not fitted simulation curves.

## Window scales

Use

`C in {60, 300, 1500}`

and scale `D` with `C` at fixed target `Omega`.

All three capacity scales are divisible by 12, so the target shares in all three conditions are represented exactly as integer capacities. This removes capacity-rounding mismatch from E1 and isolates stochastic demand fluctuations.

## Scarcity grid

Use

`Omega in {0.4, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5}`.

The grid resolves both predicted onsets (`1/2` and `1`) and includes the second exhaustion boundary (`5/2`) of the canonical mismatch case.

Because every `C` is a multiple of 10, all `D=Omega*C` values on this grid are integers.

## Screening replications

Start with

`R = 200`

independent demand-sequence seeds per `(condition,C,Omega)` cell.

This is a screening/convergence run, not the final paper production run. Replication requirements will be reassessed from Monte Carlo error near the two theoretical boundaries.

## Raw outputs per replication

Record at minimum:

- condition;
- replication;
- seed;
- `C`;
- `D`;
- realized `Omega`;
- `H`;
- realized `Lambda`;
- realized `chi`;
- `n_served`;
- `n_blocked`;
- blocked fraction;
- fluid predicted blocked fraction.

## Analysis outputs

Python must compute by cell:

- mean blocked fraction;
- standard deviation;
- Monte Carlo standard error;
- 5%, 50%, and 95% simulation quantiles;
- fluid benchmark;
- mean-minus-fluid deviation.

The first visual diagnostic should plot mean stochastic blocking against `Omega` with the analytical fluid curve overlaid separately for each condition and window scale.

A second diagnostic should plot the same results against `chi` to assess sharpening around `chi=1`.

## Success criterion for E1

E1 supports the admission theory if, as `C` increases:

1. simulated means approach the corresponding fluid curves;
2. subcritical blocking below the deterministic boundary decreases;
3. the crossover sharpens around `chi=1`;
4. A and B approach the same matched-allocation curve despite different `H`;
5. B and C remain separated because `Lambda` differs while `H` is held fixed.

No competence or relational-learning mechanism should be added until this experiment is understood.