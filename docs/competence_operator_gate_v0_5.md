# Competence Operator — Decision Gate for Model v0.5

**Status:** OPEN. No competence mechanism is frozen or implemented in the actor-learning dynamics yet.

## 1. The question in natural language

Model v0.4 says that an admitted interaction can produce a useful, transferable learning event for each participating actor. It deliberately leaves open how this happens.

The next question is therefore:

> What does it mean, mechanistically, for one interface actor to be more competent than another?

This must be answered before reusing the symbol `pi` from the legacy tie-level model.

## 2. Why the legacy interpretation cannot simply be copied

In the legacy model, `pi` was the success probability of an interaction updating a relationship-specific state `w_ij`. The new state `w_i` has a different meaning: accumulated transferable interface learning.

Therefore the same numerical values do not automatically retain the same scientific meaning.

For example, under the Model v0.4 learning rule with `w0=0.4`, `theta=0.8`, and `alpha=0.08`, exactly 14 productive learning events are required for an actor to become ready.

If `pi_i` is redefined as the probability that an admitted interaction generates one productive learning event for actor `i`, then the admitted-interaction count required to obtain those 14 events follows a negative-binomial distribution:

`N_i ~ NegBin(K_theta=14, pi_i)`.

Its moments are

`E[N_i] = K_theta/pi_i`,

`Var[N_i] = K_theta(1-pi_i)/pi_i^2`.

Consequently the expected service-efficiency ratio between specialist and ordinary actors becomes simply

`G_learning = pi_s/pi_o`.

Using the legacy numerical values `pi_o=0.55` and `pi_s=0.65` would imply only

`G_learning = 0.65/0.55 ~= 1.18`,

not the legacy mean-field gain of about 1.67. This is evidence that the old numerical values must not be transplanted without semantic recalibration.

## 3. Candidate A — endpoint-specific productive-learning probability

For an admitted pair `(i,j)`:

`L_i ~ Bernoulli(pi_i)`

`L_j ~ Bernoulli(pi_j)`.

Each endpoint converts the shared encounter into transferable learning according to its own interface-learning effectiveness.

### Natural-language interpretation

Two people can participate in the same encounter and extract different amounts of transferable learning from it. A more competent interface actor is more likely to convert each encounter into reusable coordination knowledge.

### Advantages

- actor-specific competence maps directly to actor-specific transferable memory;
- no arbitrary pair-combination operator is required;
- yields an exact negative-binomial service requirement;
- keeps capacity, competence, and learning causally separate;
- permits one endpoint to learn even when the other does not, which is plausible for asymmetric learning.

### Limitation

The specialist's competence has no direct positive externality on the counterpart in the minimal model. Cross-endpoint translation externalities would require an extension.

## 4. Candidate B — common pair-success probability

Define one interaction-level success event

`L_ij ~ Bernoulli(pi_ij)`

and update both endpoints together.

The unresolved issue is how to construct `pi_ij` from actor competences. Plausible operators include product, minimum, maximum, arithmetic mean, geometric mean, or a complementary-success expression. Each encodes a different theory of coordination.

### Advantage

A successful interaction is naturally a shared event.

### Limitation

Without a specific causal mechanism, selecting the pair operator would be mathematically convenient but theoretically arbitrary.

## 5. Candidate C — deterministic learning efficiency

Every admitted interaction produces learning, but actor `i` updates by an actor-specific rate

`w_i' = w_i + eta_i(1-w_i)`.

Higher competence means larger `eta_i`.

### Advantages

- extremely parsimonious;
- removes Bernoulli noise from the learning layer;
- gives an exact deterministic service requirement.

### Limitation

It suppresses interaction-level stochasticity and makes competence a learning-rate parameter rather than a probability/effectiveness of productive encounters.

## 6. Current recommendation

Use **Candidate A** as the first stochastic competence mechanism:

> competence is the probability that an admitted cross-boundary encounter produces a useful transferable learning increment for that actor.

The reasons are mechanistic rather than computational: it is the only candidate that requires no unmotivated bilateral aggregation rule while preserving actor-specific learning and stochasticity.

Candidate C should be retained as an analytical deterministic benchmark.

Candidate B should be used only after specifying a substantive theory of pair success or as a robustness family.

## 7. Important semantic consequence

If Candidate A is adopted, the old symbol `pi` may be retained only if the manuscript explicitly states its new meaning. A cleaner notation may be preferable, for example

`ell_i = P(productive transferable learning | admitted interaction, actor i)`.

This would prevent readers from confusing actor learning effectiveness with pair-level interaction success.

## 8. New causal decomposition

Under Candidate A, the process becomes

`attempted demand`

`-> capacity admission`

`-> endpoint-specific productive-learning draws`

`-> transferable actor-state updates`

`-> demand-weighted readiness`

`-> first passage`.

The expected useful-learning production of actor `i` is controlled by two different mechanisms:

1. how many admitted interactions reach the actor;
2. how effectively the actor converts admitted interactions into productive learning.

This is the precise location of the specialization-versus-congestion trade-off.

## 9. Next implementation step if Candidate A is locked

Implement only the stochastic learning-event generator and verify:

- exact Bernoulli frequencies under fixed seeds;
- separate RNG stream from demand/admission generation;
- endpoint-specific competence;
- no learning on blocked interactions;
- negative-binomial service-requirement benchmark in a no-capacity toy case;
- deterministic equivalence at learning probability one.

Only after those tests pass should capacity windows, learning, and first-passage readiness be combined in one simulator.
