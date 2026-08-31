# Transferable Actor Learning — Model v0.4

**Status:** actor-memory/readiness layer defined; competence operator intentionally not yet connected.

## 1. Natural-language purpose

The admission model answers whether a cross-boundary interaction can occur given scarce interface capacity. Model v0.4 adds the smallest memory needed for repeated admitted interactions to make the system progressively more capable of coordinating across the boundary.

The central modeling choice is that this memory is **partly transferable across relationships**. If actor `i` gains experience coordinating across the interface while interacting with one counterpart, that experience remains useful when `i` later interacts with another counterpart in the same module boundary.

This is deliberately different from pair-specific trust. Relation-specific memory belongs to a richer `w_ij` extension and to the legacy network model.

## 2. Actor state

Each interface actor `i` in module `g` carries a dynamic state

`w_i^(g)(t) in [0,1]`.

Interpretation:

> `w_i` is accumulated transferable interface-coordination readiness: learned language, routines, expectations, translation patterns, procedural knowledge, and other experience that helps the actor coordinate with multiple counterparts across the same boundary.

`w_i` is **not**:

- the actor's static competence;
- a probability of receiving demand;
- capacity;
- pair-specific trust;
- a relationship-specific confidence score.

These distinctions are essential because responsibility `p_i`, capacity `x_i`, competence, and accumulated learning play different causal roles.

## 3. What changes when an interaction occurs?

An admitted interaction creates a learning opportunity for each of its two endpoint actors.

Model v0.4 intentionally does not yet decide how competence converts that opportunity into useful learning. Instead, the learning kernel receives an externally supplied indicator

`L_i in {0,1}`

for each endpoint:

- `L_i=1`: the admitted interaction produced useful transferable learning for actor `i`;
- `L_i=0`: no transferable learning was added for actor `i` in that interaction.

This separation prevents the memory model from silently imposing an arbitrary bilateral competence rule.

## 4. Minimal learning rule

If `L_i=1`, actor `i` updates by diminishing-return reinforcement:

`w_i' = w_i + alpha (1-w_i)`.

If `L_i=0`,

`w_i' = w_i`.

Actors not participating in the interaction remain unchanged.

This rule has three intended properties:

1. learning is monotone in the minimal model;
2. additional experience has diminishing marginal effect as readiness approaches one;
3. the same actor state is carried into future interactions with different counterparts.

## 5. Why the legacy failure-decay rule is not inherited here

In the legacy tie-level model, a failed interaction reduced `w_ij`. That was substantively plausible because `w_ij` represented a relationship-specific relational state: unsuccessful interaction can damage confidence/trust in a specific tie.

The semantics have now changed. If `w_i` represents transferable experience or capability accumulated by an actor, an unsuccessful encounter should not automatically erase previously acquired experience.

Therefore Model v0.4 uses **no negative update on a non-learning event**.

This is not a claim that forgetting or skill erosion never exists. Passive forgetting, obsolescence, or negative transfer may be introduced later as distinct mechanisms if required. They should not be conflated with a single unsuccessful interaction.

## 6. Memory across capacity windows

Capacity resets after every `D` attempted demands.

Actor learning does **not** reset.

Thus the model separates:

- operational resource: capacity is replenished each window;
- accumulated state: interface learning persists across windows.

This is the mechanism by which repeated cross-boundary work can eventually create coordination readiness even though interaction capacity remains scarce in every period.

## 7. Actor readiness

Actor `i` is ready when

`w_i >= theta`.

Let

`r_i = I[w_i >= theta]`.

The actor threshold is a coarse-grained statement that the actor has accumulated enough transferable interface knowledge to handle its assigned role reliably.

## 8. Module-level readiness as demand coverage

Counting ready actors equally would ignore the fact that actors carry different fractions of interface responsibility. Therefore readiness is weighted by responsibility shares.

For module `g`, define

`R_g = sum_i p_i^(g) r_i^(g)`.

Natural-language interpretation:

> `R_g` is the fraction of interface demand on side `g` that would be assigned to actors who are currently ready.

Actors with `p_i=0` do not affect readiness because they carry no interface demand.

## 9. Joint interface readiness

Under the maximum-entropy pairing already locked in Model v0.2,

`P_ij = p_i^A p_j^B`.

A randomly arriving demand has both endpoints ready with probability

`R = sum_ij P_ij r_i^A r_j^B`.

Because the pairing factorizes,

`R = R_A R_B`.

This is an exact identity under the core pairing closure, not an additional approximation.

Natural-language interpretation:

> `R` is the fraction/probability of cross-boundary demand that would encounter a ready actor on both sides of the interface.

## 10. First-passage endpoint

Define system readiness time

`T = inf{t : R(t) >= q}`.

For the minimal theoretical model, retain the existing core choice `q=1` unless subsequent actor-level analysis demonstrates that full demand coverage creates a qualitatively misleading endpoint.

With `q=1`, every actor carrying positive responsibility must eventually be ready on both sides. Values `q<1` remain robustness/managerial coverage thresholds.

## 11. What Model v0.4 deliberately leaves open

Model v0.4 does not yet specify the competence mechanism.

The next model step must answer:

> Given an admitted interaction between actors `i` and `j`, what determines `L_i` and `L_j`?

Possible mechanisms include:

1. endpoint-specific learning effectiveness: `L_i ~ Bernoulli(pi_i)` and `L_j ~ Bernoulli(pi_j)`;
2. a common interaction-success event determined by a symmetric pair operator `pi_ij`;
3. a deterministic learning-efficiency increment rather than a Bernoulli event;
4. a richer mechanism in which one endpoint's translation competence creates a positive learning externality for the counterpart.

No option is frozen yet. The competence operator must be chosen from the intended real-world mechanism rather than mathematical convenience.

## 12. Core thought experiment

Suppose actor Carlos has interacted repeatedly with Ana and actor Pedro has never interacted across the boundary. Both then meet Bruno for the first time.

Under transferable actor learning,

`w_Carlos > w_Pedro`

before either has a Bruno-specific relationship history.

That difference is precisely what Model v0.4 is designed to preserve.

If the phenomenon later requires the fact that Carlos trusts Ana but not Bruno, that information belongs to an additional relation-specific state `w_ij`, not to the minimal transferable state.

## 13. Causal chain after Model v0.4

The reduced theory now has the following layers:

`responsibility architecture p`

`-> demand pairing`

`-> finite capacity x,C`

`-> admitted / blocked interaction`

`-> productive learning event L_i`

`-> transferable actor memory w_i`

`-> demand-weighted readiness R_g`

`-> joint interface readiness R`

`-> first-passage time T`.

The competence mechanism is the only intentionally open link between admission and learning.
