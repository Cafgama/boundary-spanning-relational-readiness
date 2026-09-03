# E4 — Out-of-sample learning-timescale validation

## Status

**Pre-data design.** No E4 stochastic screening results have been inspected or generated for scientific interpretation.

E4 starts from the frozen post-E3 theory checkpoint

`lock/scarce-capacity-fluid-learning-v0.8-postE3`

at commit

`1111437147a71775f59a6767d3a97d6181b5314a`.

The purpose of E4 is to test Model v0.8 **out of sample**. E3 varied concentration and scarcity at fixed learning rate \(\alpha=0.08\). E4 instead changes the learning timescale while leaving the responsibility/capacity structure unchanged. This allows the same architecture to cross the theoretical interference boundary \(\Psi=1\) without changing \(p\), \(x\), or \(\Omega\).

No parameter is fit to E4.

## 1. Scientific question

Does the post-E3 active-set theory predict how capacity-induced readiness delay changes when learning becomes slower or faster, including regime reversals in which the **same structural allocation** changes from bottlenecked to safe?

The central timescale ratio remains

\[
\Psi=\frac{\Lambda t_0(\alpha)}{C},
\]

while the within-window exhaustion coordinate remains

\[
\chi=\Omega\Lambda.
\]

Because E4 changes only \(\alpha\), \(\Lambda\) and \(\chi\) remain fixed within a given \((h,\Omega,\text{policy})\) architecture, whereas \(t_0\) and therefore \(\Psi\) move.

This is the cleanest next test of the claim that bottlenecks are governed by an **ordering of timescales**, not by concentration alone.

## 2. Fixed model

The system remains the symmetric one-heavy family with

\[
n=4,
\qquad
p_H=\frac{1+3h}{4},
\qquad
p_O=\frac{1-h}{4}.
\]

Other learning/readiness parameters are unchanged from E3:

\[
w_0=0.4,
\qquad
\ell=1,
\qquad
\Theta=0.8.
\]

Capacity is

\[
C=60,
\]

with a maximum horizon of 10 capacity windows.

Two capacity policies are retained:

\[
\text{matched}: x=p,
\]

and

\[
\text{uniform}: x_i=1/4.
\]

The joint-demand law remains maximum-entropy/product pairing. Capacity resets every window and actor learning persists across windows. No success/failure draw is introduced because \(\ell=1\); therefore the only stochasticity remains endpoint demand sampling.

## 3. E4 control grid

### Learning rate

\[
\boxed{\alpha\in\{0.06,0.08,0.10,0.12\}.}
\]

The primary out-of-sample values are

\[
\boxed{\alpha\in\{0.06,0.10,0.12\}.}
\]

The \(\alpha=0.08\) cells are included only as a **bridge/reproduction layer** because this learning rate was already used in E3. They are excluded from the primary out-of-sample predictive score.

### Responsibility concentration

Use the fixed subset

\[
\boxed{k\in\{0,4,7,10,13,14,15\},\qquad h=k/15.}
\]

This set was chosen before E4 data for mechanistic coverage:

- \(k=0\): diffuse identity/control, where matched and uniform capacity coincide;
- \(k=4\): low-intermediate concentration;
- \(k=7\): neighborhood of the E3 pre-data \(\Psi\) maximum;
- \(k=10\): high-intermediate concentration;
- \(k=13\): E3 stochastic-delay maximum;
- \(k=14\): E3 finite-window knife-edge layer;
- \(k=15\): complete-concentration endpoint with an exact discrete prediction.

### Global scarcity

\[
\boxed{\Omega\in\{0.6,1.0,1.5\}.}
\]

With \(C=60\), these correspond exactly to

\[
D\in\{36,60,90\}.
\]

They span subcritical/moderate, heavy-traffic, and severe within-window demand while remaining directly linked to E3.

### Replications

\[
\boxed{R=200\text{ per cell}.}
\]

The full design contains

\[
7\times4\times3\times2=168
\]

cells and

\[
\boxed{33{,}600}
\]

capacity-constrained trajectories. Each has a paired no-capacity counterfactual using the exact same demand sequence.

The primary out-of-sample subset contains 126 cells and 25,200 constrained trajectories after excluding the \(\alpha=0.08\) bridge layer.

## 4. Common-random-number seed schedule

E4 deliberately reuses the E3 demand-seed schedule for the selected \((h,\Omega,\text{replication})\) cells, and uses the **same demand sequence for all four values of \(\alpha\)**.

For \(h=k/15\), define the original E3 concentration index

\[
i_h=k+1.
\]

For the E4 scarcity values, retain their positions in the original E3 grid

\[
\Omega=0.6\to i_\Omega=2,
\qquad
\Omega=1.0\to i_\Omega=4,
\qquad
\Omega=1.5\to i_\Omega=6.
\]

Then

\[
\boxed{
\text{seed}
=430000000
+i_h\,10^6
+i_\Omega\,10^4
+r.
}
\]

The seed does **not** contain the learning-rate index. This creates paired trajectories across \(\alpha\), across capacity policy, and against the no-capacity counterfactual.

A key engineering invariant follows: the \(\alpha=0.08\) bridge cells must reproduce the corresponding E3 trajectories exactly, not merely statistically.

## 5. Predictions frozen before E4 stochastic data

### 5.1 Gate prediction

For uniform capacity, a deterministic capacity-induced learning delay requires both

\[
\boxed{\chi>1}
\]

and

\[
\boxed{\Psi>1.}
\]

The first condition says exhaustion is reached within the current window; the second says it arrives before the nominal learning crossing.

Model v0.8, not the two gates alone, supplies the post-onset amplitude because it propagates the full active-set sequence.

### 5.2 Learning-rate regime switch at \(h=13/15\)

For \(h=13/15\), uniform capacity gives

\[
\Lambda=3.6.
\]

The no-capacity learning timescale and interference diagnostic are predicted to move approximately as

| \(\alpha\) | \(t_0\) | \(\Psi\) |
|---:|---:|---:|
| 0.06 | 23.959 | 1.438 |
| 0.08 | 17.802 | 1.068 |
| 0.10 | 14.107 | 0.846 |
| 0.12 | 11.642 | 0.699 |

Hence the exact same architecture is predicted to move from a deterministic mismatch regime at \(\alpha=0.06,0.08\) to the safe side of the deterministic learning-interference gate at \(\alpha=0.10,0.12\).

For the uniform policy, v0.8 predicts positive deterministic delay for \(\alpha=0.06,0.08\) and zero deterministic delay for \(\alpha=0.10,0.12\) at all three E4 values of \(\Omega\), subject to finite-window stochastic corrections.

### 5.3 Knife-edge conversion at \(h=14/15\)

For \(h=14/15\),

\[
\Lambda=3.8.
\]

Predicted \(\Psi\) values are approximately

| \(\alpha\) | \(t_0\) | \(\Psi\) |
|---:|---:|---:|
| 0.06 | 20.553 | 1.302 |
| 0.08 | 15.261 | 0.967 |
| 0.10 | 12.085 | 0.765 |
| 0.12 | 9.967 | 0.631 |

Thus the E3 knife-edge point is predicted to become a **deterministic** congestion regime when learning slows to \(\alpha=0.06\), while faster learning moves it progressively farther from the deterministic boundary.

This provides a direct test that the finite-window boundary layer identified in E3 is anchored to the deterministic timescale gate rather than to a special concentration value.

### 5.4 Exact endpoint regime reversal at \(h=1\)

At complete concentration, every attempted interaction is heavy-heavy. Under uniform capacity the heavy actor has exactly

\[
c_H=15
\]

served slots per window.

The discrete number of productive exposures required for readiness is exactly

\[
m(\alpha)
=
\left\lceil
\frac{\ln[(1-\Theta)/(1-w_0)]}{\ln(1-\alpha)}
\right\rceil.
\]

Therefore

| \(\alpha\) | real crossing | \(m(\alpha)\) | endpoint prediction |
|---:|---:|---:|---|
| 0.06 | 17.755 | 18 | capacity exhausts first |
| 0.08 | 13.176 | 14 | readiness first |
| 0.10 | 10.427 | 11 | readiness first |
| 0.12 | 8.594 | 9 | readiness first |

For \(\alpha=0.06\), the first 15 attempts are served, all remaining attempts in the first window are blocked, and three additional served attempts are required after the next reset. Thus the E4 endpoint has the exact stochastic prediction

\[
\boxed{T_{\rm cap}=D+3,\qquad T_{\rm free}=18,\qquad \Delta T=D-15.}
\]

Therefore:

| \(\Omega\) | \(D\) | exact \(\Delta T\) at \(h=1,\alpha=0.06\) |
|---:|---:|---:|
| 0.6 | 36 | 21 |
| 1.0 | 60 | 45 |
| 1.5 | 90 | 75 |

For \(\alpha\in\{0.08,0.10,0.12\}\), readiness occurs before the 15-slot carrier exhausts, so

\[
\boxed{\Delta T=0}
\]

exactly at \(h=1\) for all three \(\Omega\) values.

This is the sharpest E4 prediction: **maximum concentration itself switches from perfectly safe to deterministically bottlenecked solely because the learning timescale changes.**

## 6. Frozen hypotheses

### H4.1 — Out-of-sample trajectory prediction

Without fitting to E4, Model v0.8 will predict the ordering and broad magnitude of mean first-passage time and mean capacity delay across the primary new learning rates \(\alpha\in\{0.06,0.10,0.12\}\).

Primary quantitative evaluation will report Pearson correlation, MAE, and RMSE between v0.8 predictions and stochastic cell means for the uniform-capacity primary OOS cells.

No threshold for "success" will be selected after seeing E4. The metrics will be reported as continuous predictive-performance quantities.

### H4.2 — Timescale-gate reversal

At fixed \(h=13/15\), uniform capacity will show a large capacity penalty for slow learning \(\alpha=0.06\), while the penalty will collapse sharply for \(\alpha=0.10,0.12\), consistent with crossing from \(\Psi>1\) to \(\Psi<1\).

Residual positive delay on the safe side is allowed and will be interpreted only as a finite-window correction, not as failure of the deterministic gate.

### H4.3 — Boundary-layer displacement

At \(h=14/15\), slowing learning to \(\alpha=0.06\) will convert the E3 stochastic knife-edge regime into a deterministic active-set delay, whereas faster learning will reduce both blocking probability and delay.

### H4.4 — Exact endpoint reversal

At \(h=1\), uniform capacity must obey the exact discrete endpoint predictions above. In particular, \(\alpha=0.06\) must yield \(\Delta T\in\{21,45,75\}\) for \(\Omega\in\{0.6,1.0,1.5\}\), while \(\alpha=0.08,0.10,0.12\) must yield \(\Delta T=0\).

Any violation is an implementation error, not a scientific result.

### H4.5 — Matched finite-window residual

For matched capacity, v0.8 supplies zero deterministic mismatch delay whenever readiness precedes the symmetric fluid exhaustion. The stochastic simulation may still show a positive finite-window residual, as in E1/E3. This residual should generally shrink as learning becomes faster because the crossing moves farther from the exhaustion boundary.

### H4.6 — Pathwise monotonicity

For every fixed \((h,\alpha,\Omega,\text{policy},r)\) under the common demand path,

\[
\boxed{\Delta T\ge0.}
\]

The experiment runner must assert this invariant trajectory by trajectory.

## 7. Primary estimands

For every cell, store and summarize:

\[
T_{\rm cap},\quad T_{\rm free},\quad \Delta T,
\]

plus blocking fraction, probability of any block, first-block attempt, number of capacity windows started, \(\chi\), \(\Psi\), and the preregistered v0.8 deterministic prediction \(T_F\).

The primary out-of-sample model-validation table uses only

\[
\alpha\in\{0.06,0.10,0.12\}
\]

and reports separately:

1. uniform-capacity predictive metrics for \(T\) and \(\Delta T\);
2. matched-capacity stochastic residuals relative to the deterministic prediction;
3. exact endpoint checks;
4. bridge equality at \(\alpha=0.08\).

The \(\alpha=0.08\) bridge cells will never be included in the primary out-of-sample correlation/MAE/RMSE.

## 8. Computational protocol

E4 must use the validated ell=1 fast kernel, which has already been shown to reproduce the generic v0.7 kernel exactly. No new dynamics are introduced.

The required order is:

1. implement deterministic E4 prediction generator;
2. implement stochastic E4 runner using the frozen grid and seed schedule;
3. unit/smoke test with \(R=1\);
4. verify exact \(h=1\) identities;
5. verify \(\alpha=0.08\) bridge rows against E3 under identical seeds;
6. freeze a `preE4` branch;
7. only then launch \(R=200\);
8. preserve immutable raw output and a processed summary;
9. evaluate the preregistered OOS metrics before considering any E5 extension.

No E4 grid refinement will be performed after the \(R=200\) result is inspected. Any additional exploration becomes a separately labeled experiment.
