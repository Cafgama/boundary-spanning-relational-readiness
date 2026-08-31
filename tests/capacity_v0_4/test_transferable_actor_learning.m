% TEST_TRANSFERABLE_ACTOR_LEARNING
% Deterministic tests for actor-level transferable learning and readiness.

fprintf('Running transferable actor-learning tests...\n');

tol = 1e-12;
alpha = 0.08;

%% 1. Productive learning updates exactly one selected actor.
w = [0.4, 0.4, 0.4];
w2 = update_transferable_actor_learning(w, 2, 1, alpha);
expected = 0.4 + alpha * (1 - 0.4);
assert(abs(w2(2) - expected) < tol, 'Incorrect productive-learning update.');
assert(w2(1) == w(1) && w2(3) == w(3), ...
  'Nonparticipating actors must remain unchanged.');

%% 2. A non-learning event does not erase accumulated experience.
w3 = update_transferable_actor_learning(w2, 2, 0, alpha);
assert(all(abs(w3 - w2) < tol), ...
  'Non-learning events must leave transferable state unchanged.');

%% 3. Transferability: the same actor carries learning across counterpart changes.
wA = [0.4, 0.4];
wB = [0.4, 0.4];
[wA, wB] = apply_transferable_learning_pair(wA, wB, 1, 1, 1, 0, alpha);
after_first = wA(1);
[wA, wB] = apply_transferable_learning_pair(wA, wB, 1, 2, 1, 0, alpha);
assert(wA(1) > after_first, ...
  'Actor learning must persist when the counterpart changes.');
assert(wA(2) == 0.4, 'Uninvolved actor state changed unexpectedly.');

%% 4. Learning is bounded and monotone.
w_single = 0.4;
for k = 1:200
  w_old = w_single;
  w_single = update_transferable_actor_learning(w_single, 1, 1, alpha);
  assert(w_single >= w_old && w_single <= 1, ...
    'Productive learning must be monotone and bounded by one.');
end

%% 5. Exact productive-event solution and integer threshold requirement.
R = productive_events_to_threshold(0.4, 0.8, alpha);
assert(abs(R.k_star - 13.175714676735927) < 1e-10, ...
  'Unexpected continuous productive-event threshold.');
assert(R.k_required == 14, ...
  'Expected 14 productive events to reach theta=0.8.');

w13 = 1 - (1-0.4) * (1-alpha)^13;
w14 = 1 - (1-0.4) * (1-alpha)^14;
assert(w13 < 0.8 && w14 >= 0.8, ...
  'Integer threshold crossing is inconsistent with closed form.');

%% 6. Demand-weighted module readiness.
w_mod = [0.85, 0.70, 0.90, 0.20];
p_mod = [0.50, 1/6, 1/6, 1/6];
M = actor_readiness_coverage(w_mod, p_mod, 0.8);
expected_cov = 0.50 + 1/6;
assert(abs(M.coverage - expected_cov) < tol, ...
  'Demand-weighted readiness coverage is incorrect.');

%% 7. Zero-demand actors do not affect readiness coverage.
w_zero = [0.9, 0.1];
p_zero = [1, 0];
Mzero = actor_readiness_coverage(w_zero, p_zero, 0.8);
assert(Mzero.coverage == 1, ...
  'Zero-demand actors must not reduce demand-weighted readiness.');

%% 8. Joint readiness factorizes exactly under product pairing.
wA = [0.9, 0.2];
pA = [0.75, 0.25];
wB = [0.9, 0.1];
pB = [0.6, 0.4];
J = joint_interface_readiness(wA, pA, wB, pB, 0.8);
assert(abs(J.RA - 0.75) < tol, 'Incorrect module A readiness.');
assert(abs(J.RB - 0.60) < tol, 'Incorrect module B readiness.');
assert(abs(J.R - 0.45) < tol, 'Incorrect joint readiness product.');

P = pA(:) * pB(:)';
readyA = (wA >= 0.8);
readyB = (wB >= 0.8);
explicit_joint = 0;
for i = 1:length(pA)
  for j = 1:length(pB)
    explicit_joint = explicit_joint + P(i,j) * readyA(i) * readyB(j);
  end
end
assert(abs(J.R - explicit_joint) < tol, ...
  'Factorized readiness must equal explicit product-pairing sum.');

fprintf('PASS: transferable actor-learning tests.\n');
