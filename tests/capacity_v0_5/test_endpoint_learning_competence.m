% TEST_ENDPOINT_LEARNING_COMPETENCE
% Tests for endpoint-specific productive-learning effectiveness (Model v0.5).

fprintf('Running endpoint learning-competence tests...\n');

tol = 1e-12;

%% 1. Boundary probabilities are exact.
ell = [0, 1, 0, 1];
flags = draw_productive_learning_events(ell, 123);
assert(isequal(flags, logical([0, 1, 0, 1])), ...
  'ell=0 and ell=1 must produce deterministic learning flags.');

%% 2. Fixed seed is reproducible.
ell = 0.37 * ones(200, 1);
f1 = draw_productive_learning_events(ell, 777);
f2 = draw_productive_learning_events(ell, 777);
assert(isequal(f1, f2), ...
  'Productive-learning draws must reproduce under a fixed seed.');

%% 3. Learning RNG preserves the caller RNG state.
rng(991, 'twister');
state_before = rng();
draw_productive_learning_events(0.5 * ones(100,1), 321);
state_after = rng();
assert(isequal(state_before, state_after), ...
  'Learning-event generator must restore caller RNG state.');

%% 4. Endpoint-specific frequencies converge to prescribed ell values.
n = 50000;
ells = [0.25 * ones(n,1), 0.75 * ones(n,1)];
F = draw_productive_learning_events(ells, 20260831);
freq = mean(F, 1);
assert(abs(freq(1) - 0.25) < 0.01, ...
  'Empirical learning frequency for endpoint 1 is inconsistent with ell.');
assert(abs(freq(2) - 0.75) < 0.01, ...
  'Empirical learning frequency for endpoint 2 is inconsistent with ell.');

%% 5. Negative-binomial analytical moments are exact.
K = 14;
ell_o = 0.55;
ell_s = 0.65;
Mo = negative_binomial_learning_metrics(K, ell_o);
Ms = negative_binomial_learning_metrics(K, ell_s);
assert(abs(Mo.mean_admitted - K/ell_o) < tol, ...
  'Incorrect ordinary-actor negative-binomial mean.');
assert(abs(Mo.var_admitted - K*(1-ell_o)/(ell_o^2)) < tol, ...
  'Incorrect ordinary-actor negative-binomial variance.');
assert(abs(Ms.mean_admitted - K/ell_s) < tol, ...
  'Incorrect specialist negative-binomial mean.');
assert(abs((Mo.mean_admitted / Ms.mean_admitted) - (ell_s/ell_o)) < tol, ...
  'Expected competence gain must equal ell_s/ell_o.');

%% 6. ell=1 requires exactly K admitted interactions.
N1 = simulate_no_capacity_learning_requirement(K, 1, 100, 101);
assert(all(N1 == K), ...
  'At ell=1 every admitted interaction must be productive.');

%% 7. No-capacity simulation reproduces negative-binomial mean and variance.
n_rep = 20000;
N = simulate_no_capacity_learning_requirement(K, ell_o, n_rep, 9090);
assert(abs(mean(N) - Mo.mean_admitted) < 0.15, ...
  'Monte Carlo mean does not match negative-binomial prediction.');
assert(abs(var(N, 1) - Mo.var_admitted) < 0.8, ...
  'Monte Carlo variance does not match negative-binomial prediction.');

%% 8. Simulation RNG also preserves caller state.
rng(8123, 'twister');
state_before = rng();
simulate_no_capacity_learning_requirement(K, 0.6, 100, 456);
state_after = rng();
assert(isequal(state_before, state_after), ...
  'No-capacity competence simulator must restore caller RNG state.');

%% 9. v0.4 threshold connects exactly to v0.5 stopping-time benchmark.
T = productive_events_to_threshold(0.4, 0.8, 0.08);
assert(T.k_required == K, ...
  'Expected v0.4 threshold to require K=14 productive events.');
M_from_threshold = negative_binomial_learning_metrics(T.k_required, ell_o);
assert(abs(M_from_threshold.mean_admitted - 14/0.55) < tol, ...
  'v0.4 threshold and v0.5 competence benchmark are inconsistent.');

%% 10. Higher ell lowers expected admitted-interaction requirement.
ell_grid = [0.25, 0.5, 0.75, 1.0];
Mg = negative_binomial_learning_metrics(K, ell_grid);
assert(all(diff(Mg.mean_admitted) < 0), ...
  'Expected service requirement must decrease monotonically with ell.');

fprintf('PASS: endpoint learning-competence tests.\n');
