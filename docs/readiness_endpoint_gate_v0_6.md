# Readiness Endpoint — Decision Gate for Model v0.6

**Status:** OPEN. Capacity and competence must not yet be coupled into a production first-passage simulator.

## 1. Natural-language question

The model now knows:

- who receives interface responsibility (`p_i`);
- who has interface capacity (`x_i`);
- whether an attempted encounter is admitted or blocked;
- how effectively an admitted encounter becomes useful learning (`ell_i`);
- how useful learning accumulates as transferable actor memory (`w_i`).

One conceptual question remains before defining the final first-passage time:

> What operational condition should count as "the interface is ready"?

This is not only a statistical reporting choice. With actor-level learning, it changes which part of the responsibility architecture matters for completion.

## 2. Existing actor-level coverage

Actor `i` is individually ready when

`w_i >= theta`.

For module `g`, the demand-weighted coverage is

`R_g = sum_i p_i r_i`,

where `r_i = I[w_i >= theta]`.

Natural-language interpretation:

> `R_g` is the fraction of interface demand on side `g` assigned to actors who have accumulated sufficient transferable coordination experience.

This quantity remains well defined for concentrated or diffuse responsibility allocations and automatically gives vanishing influence to actors with vanishing responsibility shares.

## 3. Why strict full coverage q=1 is problematic in the actor model

Suppose an actor carries only `p_i=0.001` of interface responsibility. Under a strict full-readiness endpoint, that actor remains mandatory even though it covers only 0.1% of demand. Because it also receives very few learning opportunities, it can dominate first passage.

As concentration varies continuously, the problem becomes sharper. An actor with an arbitrarily small positive `p_i` is mandatory at `q=1`, but at exactly `p_i=0` it suddenly becomes irrelevant. Thus full coverage can create a discontinuous first-passage artifact near zero responsibility.

This was less problematic in the legacy equal-edge readiness model, where the readiness units were discrete ties with comparable counting weight. It becomes substantive once readiness units have unequal responsibility weights.

## 4. Candidate A — joint pair-ready probability threshold

Under product pairing,

`R_pair = R_A R_B`.

One could define

`T_q = inf{t : R_pair(t) >= q}`.

### Advantage

`R_pair` is exactly the probability that a randomly arriving demand encounters a ready actor on both sides.

### Limitation

The product makes the service-level requirement more stringent than the same nominal threshold on each module. For a symmetric system, `R_pair>=0.8` requires each side to reach at least about `0.8944`. In coarse small-n examples this can make `q<1` behave effectively like full coverage.

## 5. Candidate B — module-wise demand coverage

Define system readiness by

`R_A >= q` and `R_B >= q`,

or equivalently

`min(R_A,R_B) >= q`.

Then

`T_q = inf{t : min(R_A(t),R_B(t)) >= q}`.

### Natural-language interpretation

> Each module must have enough ready interface carriers to cover at least a target fraction `q` of the responsibility assigned to that side.

### Advantages

- directly matches the meaning of `R_g` as responsibility coverage;
- avoids the multiplicative tightening of the joint product;
- becomes smoothly insensitive to vanishing responsibility shares;
- has a direct service-level interpretation;
- preserves `R_pair=R_A R_B` as a useful diagnostic rather than discarding it.

### Limitation

The guaranteed fraction of demands with both endpoints ready is at least `q^2`, not `q`. If the scientific endpoint must literally be pair-ready demand probability, Candidate A is more direct.

## 6. Candidate C — continuous demand-weighted actor state

Instead of thresholding actors first, define

`W_g = sum_i p_i w_i`.

A first passage could then be based directly on `W_g`.

### Advantage

Smooth and parsimonious; eliminates the actor-threshold order-statistic effect.

### Limitation

It changes the meaning of readiness from "fraction of responsibility covered by sufficiently experienced actors" to an average latent capability. This is less operationally transparent and departs further from the threshold-coverage logic of the legacy model.

## 7. Current recommendation

Use **Candidate B: module-wise demand coverage** as the primary actor-level first-passage endpoint.

The core quantity should be

`T_q = inf{t : min(R_A(t),R_B(t)) >= q}`.

Retain

`R_pair(t)=R_A(t)R_B(t)`

as a secondary interpretable diagnostic.

Use a high but incomplete service-level threshold `q<1` for the core model and examine threshold robustness explicitly. A baseline near the legacy value `q=0.8` is a natural candidate, but the exact numerical baseline is not frozen by this gate.

## 8. Why q is scientifically meaningful rather than a nuisance parameter

With transferable actor learning, concentration changes who receives practice opportunities.

In a no-capacity approximation with homogeneous learning effectiveness `ell`, actor `i` needs roughly

`t_i* ~= K_theta/(p_i ell)`

global demand attempts to become ready.

Therefore high-responsibility actors learn faster because they are exposed more frequently.

For the one-heavy responsibility family, this creates a simple qualitative switch:

- if the coverage target can be achieved mainly by the high-responsibility carrier, concentration focuses practice and can accelerate readiness;
- if the target requires low-responsibility carriers to become ready as well, concentration reduces their exposure and can delay readiness.

Thus concentration can create a **learning-focus benefit** before any capacity bottleneck exists.

Capacity mismatch creates a different mechanism: it blocks some of those concentrated opportunities.

The coupled theory may therefore contain a genuine trade-off between

`learning focus`

and

`congestion`.

Competence `ell_i` changes how efficiently admitted opportunities are converted into learning, adding a third, separable mechanism.

## 9. Next step after the endpoint is locked

Before production simulation, implement one deterministic/no-capacity readiness benchmark that verifies the expected exposure-ordering mechanism. Then couple the already-tested layers in this order:

`demand -> admission -> productive-learning draw -> w_i update -> R_A,R_B -> T_q`.

The first coupled experiment should use homogeneous competence and compare matched capacity architectures. Specialist competence must be introduced only after the learning-focus effect of concentration is understood independently.
