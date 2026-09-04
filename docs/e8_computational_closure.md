# E8 computational closure — scarce interface capacity, learning, competence, and robustness

## Status

**Computational program closed for the present paper.**

Authoritative post-E7 result lock:

`lock/scarce-capacity-robustness-postE7`

Authoritative E7 production archive commit:

`a6eba2d15d2c9e426813855b5f6be8156d73be98`

E7 production run:

`33869904709`

E7 production integrity:

- 132,000 stochastic trajectories;
- 264 preregistered summary cells;
- R = 500 per cell;
- all 11 production slices completed successfully;
- frozen pre-data theory SHA-256: `4967c98ca093745ee36eefde1ad1e683694c43984c48e576d24415d4bd39e97d`;
- the final combine/evaluate job verified the frozen theory before reading production results;
- all preregistered exact identities were enforced after production.

No additional mechanism, grid expansion, refit, or post-data parameter adjustment is required for the core manuscript. Any new simulation after this checkpoint is an extension and must be treated as a new study or explicitly labeled post-hoc robustness work.

---

## 1. Scientific problem solved by the computational program

The program began from the observation that modular systems often depend on a small interface through which coordination, translation, learning, or exchange must occur. The central question was not simply whether concentration is good or bad, but whether concentrating responsibility in a few interface actors changes system performance when three processes operate simultaneously:

1. interface demand is unevenly distributed across actors;
2. interaction capacity is finite and may or may not track that responsibility;
3. productive interaction creates transferable actor-level learning, potentially at different competence levels.

The resulting theory separates **responsibility architecture** from **capacity architecture** and then asks whether learning completes before locally scarce capacity is exhausted.

The computational program therefore evaluates a causal chain:

`responsibility p -> demand pairing -> finite capacity x,C -> admitted/blocked interactions -> productive learning ell -> transferable actor memory w -> readiness first passage T`.

The central result is that responsibility concentration is not intrinsically beneficial or harmful. It creates a competition between **learning focus** and **capacity congestion**. Concentration can accelerate readiness because high-responsibility actors receive more practice, but the same concentration can produce a bottleneck if capacity does not follow responsibility. Competence can move this balance again by increasing the fraction of admitted encounters that become productive learning.

---

## 2. Final model ingredients and notation

Each module contains interface-capable actors indexed by i.

### Responsibility / demand shares

`p_i >= 0`, with `sum_i p_i = 1`.

For the symmetric one-heavy family used throughout the canonical experiments,

`p_H = [1 + (n-1) h]/n`,

`p_O = (1-h)/n`,

with `h in [0,1]`.

Responsibility concentration is described by

`H = [sum_i p_i^2 - 1/n]/[1 - 1/n]`.

For the one-heavy family, `H = h^2`.

### Capacity shares

`x_i = c_i/C`, with `sum_i x_i = 1`.

The local responsibility-capacity mismatch is

`lambda_i = p_i/x_i`.

The worst local amplification is

`Lambda = max_i p_i/x_i`.

### Global scarcity

With D attempted cross-boundary interactions per capacity window and total module capacity C,

`Omega = D/C`.

The deterministic first-exhaustion coordinate is

`chi = Omega Lambda`.

Fluid first blocking begins iff

`chi > 1`.

For the one-heavy family under uniform capacity,

`Lambda = 1 + (n-1) h`,

and therefore

`Omega_c(h) = 1/[1 + (n-1)h]`.

### Transferable actor learning

Each actor has a persistent learning/readiness state `w_i in [0,1]`.

A productive admitted encounter updates

`w_i' = w_i + alpha (1-w_i)`.

A nonproductive admitted encounter leaves `w_i` unchanged in the minimal actor-learning model. A blocked encounter also leaves `w_i` unchanged.

If `w_0` is the initial state and readiness threshold is `Theta`, the exact number of productive learning events required is

`K_Theta = ceil{ ln[(1-Theta)/(1-w_0)] / ln(1-alpha) }`.

For the canonical values `w_0=0.4`, `alpha=0.08`, `Theta=0.8`,

`K_Theta = 14`.

### Endpoint-specific learning competence

For actor i,

`ell_i = P(productive transferable learning | admitted interaction, actor i)`.

For a homogeneous no-capacity actor, the number of admitted opportunities required to obtain `K_Theta` productive events is negative-binomial:

`N_i ~ NegBin(K_Theta, ell_i)`,

with

`E[N_i] = K_Theta/ell_i`.

Thus competence changes the learning timescale directly.

### Readiness endpoint

Actor i is ready when `w_i >= Theta`.

Module demand-coverage readiness is

`R_g = sum_i p_i I(w_i >= Theta)`.

The core first-passage endpoint is module-wise demand coverage:

`T_q = inf{ t : min(R_A(t), R_B(t)) >= q }`.

The product `R_A R_B` remains a secondary pair-readiness diagnostic, not the primary endpoint.

---

## 3. The two key theoretical regime coordinates

### Admission coordinate

`chi = Omega Lambda`

answers whether deterministic local exhaustion occurs within a window.

It is an onset coordinate. It does not determine the complete post-onset delay amplitude.

### Learning-interference coordinate

The no-capacity learning timescale for the relevant actor configuration is denoted `t_0`. The structural gate

`Psi = Lambda t_0 / C`

compares first local capacity exhaustion with the nominal learning timescale.

The interpretation is deliberately limited:

- `Psi < 1`: nominal learning tends to complete before first deterministic exhaustion;
- `Psi > 1`: deterministic exhaustion precedes nominal readiness and can interfere with learning.

`Psi` is a regime gate, not a complete delay law.

After exhaustion, the full trajectory depends on the ordered set of local exhaustion thresholds `x_i/p_i` and the resulting active-set masses.

---

## 4. Active-set fluid-learning reduction

The E3 discrepancy showed that onset coordinates alone cannot predict post-exhaustion delay amplitude. The resulting active-set model introduces no fitted parameter.

Within a segment in which the opposite module has active responsibility mass A, actor i receives productive admitted exposure at rate proportional to

`p_i A ell_i`.

For residual learning distance `r_i^(w)=1-w_i`, the first-moment recursion is

`E[r_i^(w)(t+1)] = [1 - alpha p_i A ell_i] E[r_i^(w)(t)]`.

The active set changes when fluid capacity is exhausted. Capacity resets at window boundaries, while actor learning persists.

Before any exhaustion, `A=1`, so the model reduces exactly to the no-capacity learning law. After exhaustion, the ordered capacity thresholds determine the segment sequence and therefore the full delay curve.

For rank-assortative pairing, actor i is paired only with its corresponding rank. Its learning recursion while active is

`E[r_i^(w)(t+1)] = [1 - alpha p_i ell_i] E[r_i^(w)(t)]`.

This removes the product-pairing collateral effect in which exhaustion of one rank reduces admission exposure of other ranks through the opposite-side active mass A.

---

## 5. Experiment sequence and what each experiment established

### E1 — admission convergence

Purpose: validate finite-window admission before coupling learning.

Main findings:

1. finite stochastic blocking converges toward the pre-derived fluid theory as C increases;
2. at the deterministic boundary `chi=1`, blocked fraction scales as `O(C^-1/2)`;
3. responsibility concentration alone does not shift deterministic congestion when capacity is matched to responsibility (`x=p`, `Lambda=1`);
4. changing capacity alignment while holding concentration fixed shifts congestion onset exactly through Lambda.

Across the E1 cells, mean absolute deviation from the fluid blocked fraction fell from 0.026461 at C=60 to 0.003353 at C=1500.

This established the first guardrail of the paper:

**concentration is descriptive; responsibility-capacity mismatch is the primitive determinant of deterministic admission overload.**

### E2 — isolated learning focus

Purpose: introduce transferable actor learning without congestion and isolate the effect of responsibility concentration on exposure/practice.

Core mechanism:

an actor carrying share `p_i` receives learning opportunities at a rate proportional to `p_i ell_i`, so its nominal readiness time scales approximately as

`t_i* ~ K_Theta/(p_i ell_i)`.

This establishes the learning-focus channel: concentrating responsibility gives high-responsibility actors more practice and can accelerate readiness if the readiness endpoint can be satisfied primarily by those actors. Conversely, if the coverage target requires low-responsibility actors, concentration can slow them through coverage dilution.

This mechanism is conceptually distinct from capacity congestion and remains present even when capacity is unlimited.

### E3 — learning x capacity coupling

Purpose: combine learning focus with finite capacity under matched versus uniform allocation.

Main result: under uniform capacity, readiness delay is strongly reentrant in concentration.

For every Omega in the E3 grid, the largest observed mean delay occurred at `h=13/15`, not at maximum concentration.

At that point, mean delays increased strongly with load, from 7.455 attempts at `Omega=0.4` to 102.525 attempts at `Omega=2.0`.

At `h=14/15`, a stochastic finite-window boundary layer remains even though the fluid gate lies slightly on the safe side. At the complete-concentration endpoint `h=1`, the exact preregistered result is recovered:

`T_cap = T_free = 14`, `Delta T = 0`.

Thus maximum concentration can be perfectly safe because learning finishes before the single carrier exhausts its capacity.

The E3 discrepancy motivated the active-set fluid model. Post-hoc, without fitting, that reduction achieved correlations near 0.99 with E3 first-passage and delay trajectories, and above 0.995 outside the explicitly identified finite-window knife-edge layer.

### E4 — out-of-sample learning-timescale validation

Purpose: move the learning timescale through alpha while holding the structural architecture fixed.

No E4 parameter was fit.

Across 63 primary out-of-sample uniform-capacity cells, the active-set model achieved:

- Pearson correlation for mean first-passage time = 0.995118;
- MAE = 2.20587 attempts;
- RMSE = 3.29590 attempts.

The strongest causal reversal occurs because the same capacity/responsibility architecture changes regime when only the learning rate changes.

At complete concentration and `alpha=0.06`, the exact delays are 21, 45, and 75 attempts for `Omega=0.6,1.0,1.5`. For `alpha in {0.08,0.10,0.12}`, the same endpoint has zero delay.

This is direct evidence for the central timescale claim:

**mismatch does not determine readiness delay by itself; delay depends on whether capacity exhaustion occurs before or after readiness learning.**

### E5 — competence switching

Purpose: test whether specialist learning effectiveness can reverse the architecture ranking.

Production contained 38,400 trajectories and 192 stochastic cells.

Across all cells, deterministic versus stochastic architecture advantage had:

- Pearson correlation = 0.966884;
- sign agreement = 183/192 = 95.31%.

Matched capacity preserved the predicted architecture-ranking sign in 100% of cells.

The preregistered coarse competence switch was recovered exactly in 6/9 competence-rescuable cells; all nine became favorable to concentration at some preregistered competence level by `ell_s=1`.

Important correction: the deterministic label `unrescuable` is not a universal stochastic impossibility statement. Two near-boundary cells reverse sign in finite C. Therefore manuscript language must use **mean-field unrescuable** or **deterministically unrescuable**.

E5 supports competence as a genuine switching mechanism while showing that finite-window fluctuations shift regime boundaries near knife edges.

### E6 — transient shocks and tail risk

Purpose: move beyond mean first passage and test robustness to transient capacity-allocation shocks.

Key frozen metrics:

- in 93.75% of 48 paired cells, uniform allocation had larger q95 delay than matched allocation;
- in the same 93.75%, uniform allocation had larger ES95 delay;
- stronger competence reduced mean delay in only 21.875% of paired comparisons, but reduced q95 in 50% and ES95 in 65.625%.

Thus capacity alignment is especially powerful as a tail-risk protection mechanism. Competence appears to protect the tail more consistently than it improves the mean under shocks.

No realization exhibited negative shock delay, preserving the monotonicity invariant that a capacity constraint cannot improve the paired constrained first passage relative to its no-shock counterpart under the frozen coupling.

### E7 — robustness and scaling

Purpose: ask whether the mechanism survives changes in system size, absolute capacity, readiness threshold, and pairing structure.

Production contained 132,000 trajectories and 264 preregistered cells, all generated from the frozen pre-E7 lock.

Across all 264 cells:

- Pearson correlation between deterministic theory and stochastic mean T = 0.995584;
- MAE = 3.45679 attempts;
- RMSE = 7.76469 attempts.

For the intermediate architecture penalty (`uniform - matched`):

- Pearson correlation = 0.996379;
- sign agreement = 89.74%;
- MAE = 3.58206 attempts.

Scaling panel:

- 9/9 system-size groups were reentrant.

Exact-identity panel:

- 54/54 exact preregistered identities were recovered;
- maximum absolute error in mean T = 0.

Pairing panel:

- 6/6 pairing groups were reentrant;
- in 9/9 intermediate paired states, product pairing produced a larger architecture penalty than assortative pairing;
- mean excess product-pairing penalty = 8.07067 attempts.

Panel-specific deterministic-to-stochastic correlations remain high:

- A, system-size scaling: 0.994894;
- B, absolute capacity: 0.990459;
- C, readiness threshold: 0.996326;
- D, pairing: 0.993272.

E7 therefore closes the principal robustness question: the reentrant learning-congestion mechanism is not an artifact of n=4, C=60, Theta=0.8, or product pairing.

---

## 6. Final causal picture

The final theory is best understood as a competition of timescales and architectures.

### Mechanism 1 — learning focus

Responsibility concentration increases practice for high-responsibility actors. When those actors dominate the readiness coverage endpoint, concentration shortens the learning path.

### Mechanism 2 — capacity congestion

If capacity shares do not track responsibility shares, concentration increases local offered load. Deterministic admission overload begins at

`chi = Omega Lambda > 1`.

### Mechanism 3 — learning-versus-exhaustion ordering

Congestion harms readiness only when exhaustion interferes with the relevant learning path. The structural timescale gate is

`Psi = Lambda t_0/C`.

### Mechanism 4 — active-set propagation

Once a carrier exhausts, the remaining admission process changes. The full post-onset delay depends on the ordered exhaustion thresholds and active responsibility masses, not on Lambda or Psi alone.

### Mechanism 5 — competence

Higher `ell_i` shortens the productive-learning timescale. This can move a concentrated architecture from bottlenecked to advantageous without changing p, x, C, or Omega.

### Mechanism 6 — finite-window fluctuations

Near deterministic regime boundaries, stochastic endpoint counts and asynchronous bilateral depletion shift the observed switching point. This produces the finite-C boundary layer seen in E3 and the near-boundary sign reversals in E5.

### Mechanism 7 — pairing correlation

Pairing structure changes how local exhaustion propagates. Product pairing creates collateral cross-rank interference through the active responsibility mass; assortative pairing removes that channel. The reentrant regime nevertheless survives both.

---

## 7. Claims supported strongly enough for the manuscript

1. Responsibility concentration and capacity mismatch are distinct variables; deterministic admission overload is controlled by mismatch, not concentration alone.
2. `chi = Omega Lambda` is the exact fluid first-exhaustion coordinate for the model.
3. Concentration can accelerate learning by focusing practice on high-responsibility actors.
4. Combining learning focus with capacity mismatch produces a reentrant readiness-delay response to concentration.
5. Maximum concentration need not be the worst configuration; it can be exactly safe when learning completes within carrier capacity.
6. The ordering between learning and exhaustion is a causal regime determinant.
7. The active-set reduction explains post-onset delay without adding fitted parameters and predicts out-of-sample changes in learning timescale.
8. Competence can reverse architecture rankings by shortening the productive-learning timescale.
9. Matching capacity to responsibility strongly suppresses both mean mismatch effects and shock-induced tail risk.
10. The core reentrant mechanism survives changes in system size, capacity scale, readiness threshold, and pairing structure.

---

## 8. Claims that require qualification

1. `Psi=1` is a mean-field regime gate, not an exact finite-C phase boundary.
2. Deterministically `unrescuable` means unrescuable in the first-moment fluid model, not impossible to rescue stochastically.
3. Product pairing has larger intermediate penalties than assortative pairing in the E7 tested grid; this is strong model evidence, not a universal theorem for every correlated pairing matrix.
4. Competence protects the tail more consistently than the mean in E6; this is a robust observation in the frozen shock design, not yet a general asymptotic theorem.
5. Matched capacity removes first-order deterministic mismatch but cannot eliminate finite-window stochastic blocking near critical boundaries.

---

## 9. Claims that should not appear in the manuscript

1. Concentration is intrinsically a bottleneck.
2. Boundary spanners strategically choose their relationships in the core model.
3. `H` alone determines overload.
4. `Lambda` determines the full delay curve after exhaustion.
5. `Psi` is a thermodynamic phase-transition parameter.
6. The old provisional `Xi = Omega Lambda/G` is a universal switching law.
7. Legacy pair-level success probabilities can be reused numerically as actor-learning competence probabilities.
8. Nonproductive interaction destroys previously accumulated transferable learning in the actor-learning core.
9. A deterministic `unrescuable` label proves stochastic impossibility.
10. E1 alone says anything about readiness or competence.

---

## 10. Final reproducibility state

The repository preserves separate model-development and frozen-result branches. The original legacy dynamics remain untouched.

The scarce-capacity implementation is under `src/capacity/`; simulations are in Octave and analysis/figure data are produced in Python from immutable CSV outputs.

Key result provenance is preserved through workflow run IDs, raw-data hashes, processed-data hashes, pre-data locks, and post-data locks.

The E7 production manifest records:

- source lock: `lock/scarce-capacity-robustness-preE7`;
- source commit: `2b37f60936c2aa35cdcad15beb553aa72546c35b`;
- 132,000 raw rows;
- 264 summary cells;
- 500 replications per cell;
- frozen prediction SHA-256;
- raw, gzip, summary, evaluated-cell, and metrics SHA-256 hashes.

This is sufficient to treat the computational track as closed and reproducible for manuscript drafting.

---

## 11. Closure decision

The present paper has enough evidence to move from computational development to manuscript construction.

Further simulation is **not required** to establish the core result. New experiments should only be added if a reviewer or a new theoretical question requires them.

The manuscript should now be built around the following logical sequence:

1. separate concentration from mismatch;
2. derive first exhaustion;
3. derive learning focus;
4. compare learning and exhaustion timescales;
5. derive active-set propagation;
6. show reentrant concentration response;
7. show competence switching;
8. show tail-risk implications;
9. establish robustness to size, capacity, threshold, and pairing.

**E8 computational status: CLOSED.**
