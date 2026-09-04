# E8 scientific handover to manuscript construction

## Purpose of this handover

This document transfers the closed computational program into the theoretical/writing track. It is intentionally organized from first principles rather than in experiment chronology.

The manuscript should not read as a sequence of simulations. It should read as a theory of how scarce interface capacity interacts with concentrated responsibility, transferable learning, and competence in modular systems, with simulations used to validate and delimit that theory.

The computational evidence is now frozen. The writing task is to explain the mechanism cleanly and decide how much mathematics belongs in the main text versus Methods/Supplementary Information.

---

# 1. Core scientific question

A modular system must coordinate across an interface. Responsibility for that interface can be distributed across many actors or concentrated in a few. Concentration has two opposing consequences.

First, an actor with more responsibility receives more repeated exposure and can learn the interface faster. This is the **learning-focus effect**.

Second, if the actor's available interaction capacity does not grow with its responsibility, the same concentration creates local overload and blocks opportunities. This is the **capacity-congestion effect**.

The paper therefore asks:

> **When does concentrating interface responsibility accelerate coordination, and when does it turn the same interface into a bottleneck under scarce interaction capacity?**

The deeper answer is a competition of timescales:

> concentration helps when the relevant learning process completes before local interface capacity is exhausted; it hurts when exhaustion interrupts the learning path.

Competence changes the answer because it changes how efficiently admitted interaction becomes transferable learning.

---

# 2. Why this is a complex-systems problem rather than an organizational special case

The model applies to any structured system with:

- modules or communities;
- a restricted interface between them;
- heterogeneous allocation of interface responsibility;
- finite interaction/service capacity;
- repeated interaction that changes future performance through learning or adaptation.

Examples include organizational boundary spanning, interdisciplinary research, distributed engineering, interdependent infrastructure, service systems, multi-agent coordination, ecological mutualistic interfaces, and communication between modular subsystems.

The paper should use boundary spanning as an intuitive example or motivating domain, not as the ontological definition of the model.

The general object is an **adaptive modular interface under finite interaction capacity**.

---

# 3. Minimal microscopic world in natural language

There are two modules, A and B.

Each module has n actors able to carry cross-boundary responsibility.

Each actor i carries a share `p_i` of its module's interface responsibility. A larger `p_i` means the interface asks that actor to participate more often.

Each actor also receives a share `x_i` of a finite capacity budget C per window. Capacity is consumed only when a cross-boundary interaction is actually admitted.

There are D attempted cross-boundary interactions per capacity window. Each attempted interaction requests one actor from A and one actor from B according to the responsibility architecture.

If both requested actors still have capacity, the interaction is admitted. Otherwise the interaction is blocked and neither endpoint consumes capacity.

An admitted encounter can generate productive transferable learning at each endpoint. Actor i converts an admitted encounter into useful learning with probability `ell_i`.

Useful learning raises actor i's persistent readiness state `w_i`. Learning transfers across that actor's future counterparties but does not automatically transfer to other actors.

Capacity resets at the next window. Learning does not.

The system is ready when enough interface responsibility on **each module** is carried by actors whose learning state has crossed the readiness threshold.

This natural-language world should precede the formal model in the paper.

---

# 4. Responsibility architecture

Let

`p_i^(g) >= 0`, `sum_i p_i^(g)=1`,

for modules `g in {A,B}`.

The canonical symmetric one-heavy family is

`p_H = [1+(n-1)h]/n`,

`p_O = (1-h)/n`,

where `h=0` is diffuse responsibility and `h=1` puts all responsibility on one carrier.

A descriptive concentration statistic is

`H = [sum_i p_i^2 - 1/n]/[1-1/n]`.

In the one-heavy family,

`H=h^2`.

### Manuscript guardrail

H is not the causal overload variable. It only describes the responsibility architecture.

---

# 5. Capacity architecture and the first central derivation

Let

`x_i = c_i/C`, `sum_i x_i=1`.

The local offered-load amplification is

`lambda_i = p_i/x_i`.

The worst local mismatch is

`Lambda = max_i lambda_i = max_i p_i/x_i`.

Global demand relative to capacity is

`Omega = D/C`.

Hence actor i has local offered load

`omega_i = Omega p_i/x_i = Omega lambda_i`.

The peak local load is therefore

`chi = Omega Lambda`.

The deterministic fluid admission process gives the exact first-exhaustion condition

`chi > 1`.

Equivalently,

`Omega_c = 1/Lambda`.

This is one of the cleanest theoretical results and should appear early.

## Key conceptual consequence

If capacity follows responsibility exactly,

`x_i=p_i`,

then

`lambda_i=1` for every actor and therefore

`Lambda=1`,

regardless of how concentrated p is.

Thus responsibility concentration does **not** by itself create deterministic admission overload.

This distinction is empirically validated by E1: diffuse matched and concentrated matched converge to the same fluid blocking curve, whereas keeping concentration fixed and changing capacity alignment shifts the congestion threshold exactly through Lambda.

---

# 6. Fluid admission after first exhaustion

Define scaled attempt time `s=t/C` and remaining normalized capacity `z_i(s)`.

For product pairing, let A(s) be the total responsibility mass still carried by active actors on the opposite module.

Before exhaustion, `A=1`.

For an active actor,

`dz_i/ds = -p_i A(s)`.

Introduce cumulative active exposure

`u(s)=integral_0^s A(v)dv`.

Then

`z_i(s)=max[x_i-p_i u(s),0]`.

Each actor has an exhaustion threshold

`r_i = x_i/p_i`.

The first threshold is

`min_i r_i = 1/Lambda`.

The complete post-onset admission curve depends on the entire ordered threshold set `{x_i/p_i}`, not on Lambda alone.

This result becomes important later because the same ordered active sets determine the learning trajectory after blocking begins.

---

# 7. Transferable actor learning

Actor i has persistent readiness state `w_i in [0,1]`.

For a productive admitted event,

`w_i' = w_i + alpha(1-w_i)`.

For a nonproductive admitted event,

`w_i'=w_i`.

For a blocked event,

`w_i'=w_i`.

There is no automatic negative learning update in the core actor-learning model. Failure to learn from one encounter is not assumed to erase accumulated interface experience.

After k productive events,

`w_k = 1-(1-w_0)(1-alpha)^k`.

The smallest integer number of productive events required to reach threshold Theta is

`K_Theta = ceil[ ln((1-Theta)/(1-w_0)) / ln(1-alpha) ]`.

For the canonical values,

`w_0=0.4`, `alpha=0.08`, `Theta=0.8`,

so

`K_Theta=14`.

This exact integer fact drives several exact endpoint predictions later in the paper.

---

# 8. Competence as productive-learning probability

Use `ell_i`, not the legacy symbol pi.

Define

`ell_i = P(productive transferable learning | admitted interaction, actor i)`.

For an admitted pair `(i,j)`, productive-learning events are endpoint-specific:

`L_i ~ Bernoulli(ell_i)`,

`L_j ~ Bernoulli(ell_j)`.

The two endpoints need not both learn from the same admitted encounter.

Without capacity constraints, the number of admitted opportunities required for actor i to accumulate `K_Theta` productive events follows

`N_i ~ NegBin(K_Theta, ell_i)`.

Therefore

`E[N_i]=K_Theta/ell_i`,

`Var[N_i]=K_Theta(1-ell_i)/ell_i^2`.

Competence is therefore a learning-timescale operator, not merely a static performance multiplier.

---

# 9. Readiness endpoint

Actor i is ready when

`w_i >= Theta`.

Module demand-coverage readiness is

`R_g = sum_i p_i I(w_i>=Theta)`.

The primary first-passage endpoint is

`T_q = inf{t : min(R_A(t),R_B(t)) >= q}`.

Natural-language interpretation:

> each module must have ready actors covering at least fraction q of its own interface responsibility.

The product

`R_pair=R_A R_B`

is an exact random-pair readiness probability under product pairing and is useful as a secondary diagnostic, but it should not be the core endpoint because it multiplicatively tightens the nominal q.

The main text should explain why strict q=1 was rejected: arbitrarily tiny positive responsibility shares would become mandatory and could dominate first passage despite carrying negligible interface demand.

---

# 10. Second central mechanism: learning focus

Even with unlimited capacity, concentration changes exposure.

Under homogeneous competence, actor i is selected for interface demand with frequency proportional to `p_i`, and productive learning arrives at rate proportional to

`p_i ell_i`.

A simple individual readiness estimate is therefore

`t_i* approximately K_Theta/(p_i ell_i)`.

This yields the first half of the reentrance mechanism:

- increasing p for an important carrier makes that carrier learn faster;
- decreasing p for ordinary carriers makes them learn more slowly.

Which effect matters depends on the readiness coverage q.

In the one-heavy family, a useful approximate coverage switch occurs when

`p_H=q`.

Hence

`h_q = (nq-1)/(n-1)`.

This is an explanatory boundary for the learning-focus mechanism, not an exact stochastic first-passage theorem.

---

# 11. Third central mechanism: learning versus exhaustion

Let `t_0` denote the relevant no-capacity learning timescale for the architecture.

First local capacity exhaustion occurs at approximately

`t_exh = C/Lambda`.

This motivates the dimensionless ordering coordinate

`Psi = Lambda t_0/C`.

Interpretation:

- `Psi < 1`: nominal readiness lies before first deterministic exhaustion;
- `Psi > 1`: capacity exhaustion lies before nominal readiness.

This is the conceptual core of the paper:

> mismatch matters for readiness only when its exhaustion timescale intersects the learning path.

### Guardrail

Psi is not the full delay law.

E3 demonstrates why: Psi peaks at a lower concentration than the observed stochastic delay peak. Once exhaustion occurs, the whole active-set sequence controls the delay amplitude.

---

# 12. Active-set learning law

When the opposite module has active responsibility mass A, actor i receives productive admitted exposure at rate proportional to

`p_i A ell_i`.

For residual learning distance

`r_i^(w)=1-w_i`,

`E[r_i^(w)(t+1)] = [1-alpha p_i A ell_i] E[r_i^(w)(t)]`.

This law introduces no fitted parameter.

Before exhaustion, A=1 and the equation reduces to the no-capacity learning law.

After an actor exhausts, A changes and the remaining learning process slows according to the surviving responsibility mass.

The full model therefore combines:

1. ordered exhaustion thresholds `x_i/p_i`;
2. persistence of w across windows;
3. capacity reset each window;
4. endpoint learning effectiveness ell.

This active-set reduction is the preferred analytical bridge between the microscopic model and simulation.

---

# 13. Main phenomenon: reentrant effect of concentration

A naive bottleneck story would predict that increasing concentration progressively worsens performance.

The model instead predicts and simulation confirms a **reentrant response**.

At low concentration, learning is diffuse and therefore relatively slow, but capacity mismatch is modest.

At intermediate-high concentration, responsibility becomes concentrated enough to create severe mismatch under uniform capacity, while learning has not yet become fast enough to finish before exhaustion. This is the bottleneck region.

At extreme concentration, the dominant actor learns so rapidly from repeated exposure that readiness can again occur before its finite capacity is exhausted.

The canonical E3 result is especially clear:

- under uniform capacity, maximum mean delay occurs at `h=13/15` for every tested Omega;
- at `h=1`, the heavy actor receives every interaction, has 15 capacity slots, and needs exactly 14 productive encounters;
- therefore `T_cap=T_free=14` and `DeltaT=0` exactly.

So the paper's strongest qualitative statement is:

> **The most concentrated interface is not necessarily the most bottlenecked interface. Bottlenecks arise in the region where concentration has increased local load faster than it has shortened the learning timescale.**

---

# 14. Out-of-sample validation of the timescale mechanism

E4 changes only alpha while keeping responsibility and capacity architecture fixed.

This is a powerful causal test because it moves the learning timescale without moving the admission structure.

Across 63 primary out-of-sample uniform-capacity cells:

- Pearson `r=0.995118` for mean first-passage time;
- MAE `=2.20587` attempts;
- RMSE `=3.29590` attempts.

At `h=1`, changing only alpha changes the exact regime:

- `alpha=0.06`: delays `(21,45,75)` for `Omega=(0.6,1.0,1.5)`;
- `alpha in {0.08,0.10,0.12}`: delay exactly zero.

This should be a central Results figure or panel because it cleanly demonstrates the theory rather than merely fitting a concentration curve.

---

# 15. Competence switching

E5 asks whether higher specialist learning effectiveness can rescue an architecture that is disadvantaged under homogeneous competence.

Across 192 cells:

- deterministic versus stochastic architecture advantage correlation `r=0.966884`;
- sign agreement `183/192 = 95.31%`;
- matched-capacity sign agreement `100%`.

All nine preregistered competence-rescuable uniform-capacity architecture cells became favorable to concentration somewhere on the tested competence grid by `ell_s=1`.

The coarse deterministic switch was recovered exactly in 6/9 cells; the other shifts were one competence-grid step.

This supports the paper's competence claim:

> **competence can move a concentrated interface across the learning-congestion boundary because it shortens the productive-learning timescale without changing the responsibility or capacity architecture.**

### Important correction

Do not write that deterministic `unrescuable` regions are stochastically impossible to rescue.

Two finite-C cells reverse the deterministic sign near the boundary. Use `mean-field unrescuable` or `deterministically unrescuable`.

---

# 16. Tail risk and transient shocks

E6 moves beyond the mean.

A temporary capacity-allocation shock can push the interface toward or across local exhaustion even when baseline mean performance appears acceptable.

In the paired E6 comparisons:

- uniform capacity had larger q95 shock delay than matched capacity in 93.75% of cells;
- uniform capacity had larger ES95 delay in 93.75% of cells.

Competence improved mean shock delay less consistently than tail delay:

- lower mean delay at `ell=1` versus `ell=0.7`: 21.875%;
- lower q95: 50%;
- lower ES95: 65.625%.

The manuscript implication is not that competence always improves the mean. It is that **capacity alignment is a structural tail-risk defense, while competence often acts as a tail-resilience buffer**.

This finding can support a resilience subsection without becoming the main paper thesis.

---

# 17. Final robustness closure from E7

E7 tests four alternative explanations:

A. the effect might be an artifact of n=4;
B. it might depend on the absolute capacity scale C=60;
C. it might depend on the readiness threshold Theta=0.8;
D. it might depend on product/maximum-entropy pairing.

The answer is no for the tested ranges.

Across all 264 cells:

- deterministic-to-stochastic mean-T correlation `r=0.995584`;
- MAE `=3.45679`;
- RMSE `=7.76469`.

System-size scaling:

- reentrance in 9/9 groups.

Exact identities:

- 54/54 recovered;
- maximum absolute mean-T error = 0.

Pairing:

- reentrance in 6/6 groups;
- product pairing had larger intermediate architecture penalty than assortative pairing in 9/9 paired states;
- mean excess penalty = 8.07067 attempts.

The pairing result is mechanistically interpretable. Under product pairing, exhaustion on one rank reduces the opposite module's active mass A and therefore suppresses exposure of still-active ranks. Under assortative pairing, each rank's exposure remains local to that rank until its own exhaustion. Product pairing therefore creates collateral cross-rank blocking.

Because reentrance survives the removal of that collateral mechanism, reentrance itself is not a product-pairing artifact.

---

# 18. Recommended manuscript spine

## Introduction

1. Modular systems depend on interfaces.
2. Interface responsibility is often concentrated because specialization and repeated experience are valuable.
3. The same concentration may create overload under finite interaction capacity.
4. Existing bottleneck intuition generally treats concentration as load concentration but does not jointly model repeated learning and finite capacity.
5. We ask when concentration is beneficial versus harmful.
6. Preview: the answer is a competition between learning focus and capacity exhaustion, producing reentrant concentration effects and competence-dependent regime switching.

## Model / Theory

1. Two-module interface and responsibility shares p.
2. Capacity shares x and scarcity Omega.
3. Derive local mismatch lambda and Lambda.
4. Derive first-exhaustion law `chi=Omega Lambda`.
5. Introduce actor learning w and exact `K_Theta`.
6. Introduce competence ell.
7. Define demand-coverage readiness and first passage.
8. Derive learning-focus timescale.
9. Define learning-exhaustion gate Psi.
10. Derive active-set fluid learning.

## Results

Suggested order:

### Result 1 — Concentration is not mismatch

Use E1 and the matched-versus-uniform contrast.

### Result 2 — Concentration focuses learning

Use no-capacity reasoning/E2.

### Result 3 — Coupling the two channels creates reentrance

Use E3; show intermediate-high delay maximum and exact safe endpoint.

### Result 4 — Moving the learning timescale reverses the regime

Use E4 as out-of-sample validation.

### Result 5 — Competence moves the switching boundary

Use E5.

### Result 6 — Allocation alignment protects the tail

Use E6.

### Result 7 — Mechanism survives robustness/scaling

Use E7 in a compact final panel/table and supplementary detail.

## Discussion

1. Main conceptual contribution: interface concentration is governed by competing benefits and costs, not monotonic overload.
2. Capacity allocation should track responsibility when possible.
3. Specialist competence has value because it changes the learning timescale, not merely because specialists are 'better'.
4. Finite systems have stochastic boundary layers; deterministic regime coordinates should be interpreted as mean-field guides.
5. Pairing structure affects amplitude and propagation of congestion but not the existence of the core reentrant mechanism in the tested class.
6. Broader applicability beyond organizations.

---

# 19. Recommended main figures

The final number can be adjusted to journal constraints, but a strong main-text set is:

## Figure 1 — Model and causal architecture

A schematic showing

`p -> demand -> capacity x,C -> admission -> productive learning ell -> w -> readiness T`.

Include the two competing arrows from concentration:

- concentration -> learning focus;
- concentration + mismatch -> congestion.

## Figure 2 — Admission law and mismatch

Show fluid blocking/convergence from E1 and the exact first-exhaustion boundary `chi=1`.

Key visual contrast:

- diffuse matched;
- concentrated matched;
- concentrated uniform.

## Figure 3 — Reentrant learning-congestion response

Core paper figure.

Plot readiness delay versus h for matched and uniform capacity across selected Omega values.

Mark:

- intermediate-high delay maximum;
- `h=14/15` stochastic boundary layer;
- `h=1` exact zero-delay endpoint.

Overlay active-set fluid prediction where appropriate.

## Figure 4 — Timescale reversal and competence switching

Panel A: E4, same architecture under different alpha values.

Panel B: E5 architecture advantage versus specialist competence ell_s.

This figure demonstrates that the regime is controlled by learning timescale rather than concentration alone.

## Figure 5 — Resilience and robustness

Panel A: E6 tail-risk comparison matched versus uniform.

Panel B: E7 scaling/threshold/pairing robustness summarized compactly.

If the journal strongly limits main figures, E6 or part of E7 can move to Supplementary Information.

---

# 20. Recommended tables

### Main Table 1 — Symbols and mechanisms

Include p, x, C, D, Omega, lambda, Lambda, chi, h, H, alpha, ell, w, Theta, q, K_Theta, Psi, T.

### Main/Supplementary Table 2 — Model predictions versus stochastic validation

Rows E1–E7, with:

- theoretical prediction;
- whether pre-data or post-hoc;
- production size;
- principal validation metric;
- interpretation.

This table is valuable because the scientific credibility of the paper depends on distinguishing derivations that preceded data from mechanisms derived after an observed discrepancy and then validated out of sample.

---

# 21. Evidence hierarchy for the manuscript

The manuscript should distinguish three levels of evidence.

## Level I — exact / analytical

Examples:

- `chi=Omega Lambda` first-exhaustion law;
- matched `x=p -> Lambda=1`;
- exact K_Theta;
- exact h=1 capacity endpoints when slot count is above/below K_Theta;
- negative-binomial no-capacity competence benchmark.

Use strong language such as `we derive`, `exactly`, or `for this model`.

## Level II — deterministic mean-field / fluid prediction validated stochastically

Examples:

- active-set first-passage approximation;
- Psi as timescale gate;
- competence switching boundary.

Use language such as `predicts`, `regime boundary`, `mean-field`, and report finite-C deviations.

## Level III — empirical stochastic regularity in the tested model class

Examples:

- product pairing has larger intermediate penalty than assortative in all nine E7 paired states;
- competence protects ES95 more often than mean delay in E6.

Use language such as `in the tested grid`, `we observe`, or `the simulations show`.

Do not upgrade Level III findings into universal theorems.

---

# 22. Claims we can write strongly

- Concentration and mismatch are distinct.
- Local mismatch controls deterministic first capacity exhaustion.
- Concentration focuses learning through repeated exposure.
- Learning focus and finite capacity jointly generate a reentrant concentration-delay relationship.
- Maximum concentration can be exactly safe.
- The ordering of exhaustion and learning timescales controls regime changes.
- Competence can reverse the ranking of interface architectures.
- Matching capacity to responsibility materially reduces congestion and shock-tail exposure.
- Reentrance survives the tested changes in n, C, Theta, and pairing structure.

---

# 23. Claims requiring careful wording

- Psi is a gate, not a phase-transition order parameter.
- Mean-field switching thresholds are not exact finite-C stochastic boundaries.
- `unrescuable` must be qualified as deterministic/mean-field.
- Tail-resilience conclusions are about the frozen E6 shock design.
- Product-versus-assortative penalty ordering is a tested robustness result, not a general theorem for arbitrary pairing correlations.

---

# 24. Claims prohibited by the evidence

Do not state that:

- concentration is intrinsically bad;
- concentration alone causes overload;
- H is the overload variable;
- Lambda predicts the complete delay curve;
- specialists strategically choose partners in the core model;
- old legacy pair-level success parameters equal ell;
- failed encounters erase transferable learning;
- finite-C stochastic switching occurs exactly at Psi=1;
- mean-field unrescuable means stochastically impossible;
- the model proves a thermodynamic phase transition.

---

# 25. Relation to the legacy boundary-spanning model

The legacy model remains useful as a richer relational microfoundation but should not be mixed silently into the new paper.

Legacy model:

- pair-level tie confidence `w_ij`;
- reinforcement and failure decay;
- agent-first interaction selection;
- boundary-spanner topology and competence;
- relational readiness as a network first-passage problem.

New scarce-capacity model:

- actor-level transferable readiness `w_i`;
- explicit responsibility p;
- explicit capacity x,C;
- explicit admission blocking;
- endpoint-specific learning competence ell;
- module demand-coverage readiness.

The conceptual bridge is that the legacy agent-first rule implicitly gave each actor a bounded activation opportunity. The new model makes that scarcity explicit, separable, and analytically tractable.

For the new paper, the legacy model should appear as motivation or a richer limiting/extension case, not as part of the minimal canonical derivation.

---

# 26. Limitations to state proactively

1. Core topology is deliberately minimal and symmetric.
2. Capacity is window-based and resets discretely.
3. Learning is transferable within actor but not across actors.
4. Core learning is monotone; forgetting/obsolescence is omitted.
5. Endpoint competence is modeled as productive-learning probability.
6. Pair-specific trust and translation externalities are excluded from the minimal model.
7. The main fluid theory is first-moment/deterministic and finite systems exhibit stochastic boundary layers.
8. Product and rank-assortative pairing do not span every possible pair-correlation structure.
9. The model identifies mechanism and regime structure; it is not calibrated to a single empirical organization or biological system in the present paper.

These are strengths if framed as deliberate minimality rather than omissions discovered after the fact.

---

# 27. What the theoretical chat should do next

No new simulation should be started initially.

The theoretical chat should proceed in baby steps:

1. reconstruct the natural-language world;
2. derive local load and `chi` from first principles;
3. derive fluid active-set admission;
4. derive actor-learning and K_Theta;
5. derive no-capacity learning focus;
6. derive the readiness endpoint and role of q;
7. derive Psi as a timescale comparison;
8. derive the active-set learning recursion;
9. explain why reentrance follows from competing concentration effects;
10. derive exact endpoint cases;
11. formalize competence switching;
12. discuss finite-C corrections and what is/not analytically exact.

Only after these steps should the writing chat convert the theory into Introduction/Model/Results prose.

---

# 28. Final scientific message in one paragraph

A modular interface does not become a bottleneck merely because responsibility is concentrated. Concentration simultaneously increases the load placed on a small number of carriers and increases the rate at which those carriers learn from repeated exposure. When capacity follows responsibility, the deterministic mismatch penalty disappears even under strong concentration. When capacity is misaligned, local exhaustion begins according to `chi=Omega Lambda`, but whether this exhaustion delays system readiness depends on its timing relative to learning. This competition produces a reentrant response: intermediate-high concentration can be maximally harmful while complete concentration can again be safe because the dominant carrier learns before exhausting its capacity. Competence shifts the same boundary by accelerating productive learning, while capacity alignment strongly protects the delay tail under shocks. The mechanism survives changes in system size, absolute capacity, readiness threshold, and pairing structure in the preregistered robustness study.

---

# 29. Final transfer status

The computational track is complete and frozen.

The next chat can treat the following as inputs, not open modelling decisions:

- distinction between concentration and mismatch;
- p/x/Lambda/Omega/chi notation;
- transferable actor learning semantics;
- endpoint-specific competence ell;
- module-wise demand-coverage readiness;
- exact K_Theta logic;
- Psi as a mean-field timescale gate;
- active-set learning as the post-exhaustion reduction;
- reentrance as the core phenomenon;
- finite-window stochastic boundary layer as a qualification;
- E1–E7 validation record;
- post-E7 computational lock.

**Scientific handover status: READY FOR FIRST-PRINCIPLES THEORY RECONSTRUCTION AND MANUSCRIPT WRITING.**
