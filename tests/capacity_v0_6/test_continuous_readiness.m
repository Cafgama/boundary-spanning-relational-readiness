% TEST_CONTINUOUS_READINESS
% Tests for continuous demand-weighted readiness and exact no-capacity mean law.

fprintf('Running continuous-readiness tests...\n');

tol = 1e-12;
w0 = 0.4;
alpha = 0.08;
Theta = 0.8;

%% 1. Demand-weighted readiness is computed exactly.
wA = [0.8, 0.4];
pA = [0.75, 0.25];
wB = [0.6, 0.5];
pB = [0.4, 0.6];
R = continuous_interface_readiness(wA, pA, wB, pB);
assert(abs(R.WA - 0.7) < tol, 'Incorrect WA.');
assert(abs(R.WB - 0.54) < tol, 'Incorrect WB.');
assert(abs(R.Wmin - 0.54) < tol, 'Incorrect conservative readiness.');
assert(abs(R.Wpair - 0.378) < tol, 'Incorrect product diagnostic.');

%% 2. Zero-responsibility actors have exactly zero effect.
R0 = continuous_interface_readiness([0.9, 0.0], [1, 0], [0.8, 0.1], [1, 0]);
assert(abs(R0.WA - 0.9) < tol && abs(R0.WB - 0.8) < tol, ...
  'Zero-responsibility actors must not affect continuous readiness.');

%% 3. Exact mean law recovers the initial state at t=0.
p = [0.5, 1/6, 1/6, 1/6];
M0 = no_capacity_mean_readiness(0, p, w0, alpha, 1);
assert(abs(M0.Wmean - w0) < tol, ...
  'Mean readiness at t=0 must equal the common initial state.');

%% 4. Exact one-step increment equals alpha*ell*(1-w0)*sum p_i^2.
ell = 0.7;
M1 = no_capacity_mean_readiness([0,1], p, w0, alpha, ell);
expected_inc = alpha * ell * (1-w0) * sum(p.^2);
assert(abs((M1.Wmean(2)-M1.Wmean(1)) - expected_inc) < tol, ...
  'Incorrect exact initial learning-focus increment.');
assert(abs(M1.initial_increment - expected_inc) < tol, ...
  'Stored initial increment is inconsistent with theory.');

%% 5. One-heavy second moment equals [1+(n-1)h^2]/n.
n = 4;
h = 0.5;
p_h = one_heavy_responsibility(n, h);
expected_s2 = (1 + (n-1)*h^2) / n;
assert(abs(sum(p_h.^2) - expected_s2) < tol, ...
  'One-heavy responsibility second moment is inconsistent with theory.');

%% 6. Diffuse exact-mean crossing is the analytically predicted integer time.
p_diff = ones(1,4)/4;
F = no_capacity_mean_first_passage(p_diff, w0, alpha, 1, Theta, 200);
continuous_cross = log((1-Theta)/(1-w0)) / log(1-alpha/4);
assert(F.T_mean_cross == ceil(continuous_cross), ...
  'Diffuse exact-mean crossing time is incorrect.');
assert(F.T_mean_cross == 55, ...
  'Expected diffuse mean-readiness crossing at t=55.');

%% 7. Concentration increases the exact initial learning increment.
p_conc = one_heavy_responsibility(4, 0.6);
Md = no_capacity_mean_readiness(1, p_diff, w0, alpha, 1);
Mc = no_capacity_mean_readiness(1, p_conc, w0, alpha, 1);
assert(Mc.initial_increment > Md.initial_increment, ...
  'Responsibility concentration should increase initial learning focus.');

%% 8. Single-actor no-capacity simulator is deterministic at ell=1.
out = simulate_no_capacity_interface_readiness(1, 1, w0, alpha, 1, 1, Theta, 100, 111, 222);
assert(out.delta == 1 && out.T == 14, ...
  'Single-actor ell=1 simulator should cross after exactly 14 interactions.');

%% 9. No learning produces censoring when the initial state is below Theta.
out0 = simulate_no_capacity_interface_readiness(1, 1, w0, alpha, 0, 0, Theta, 30, 333, 444);
assert(out0.delta == 0 && isnan(out0.T) && out0.T_tilde == 30, ...
  'ell=0 should censor below the readiness threshold.');
assert(abs(out0.Wmin - w0) < tol, ...
  'State must remain unchanged when ell=0.');

%% 10. Fixed seeds reproduce the complete stochastic first passage.
p_test = [0.5, 0.2, 0.2, 0.1];
o1 = simulate_no_capacity_interface_readiness(p_test, p_test, w0, alpha, 0.6, 0.6, Theta, 1000, 555, 666);
o2 = simulate_no_capacity_interface_readiness(p_test, p_test, w0, alpha, 0.6, 0.6, Theta, 1000, 555, 666);
assert(isequaln(o1.T, o2.T) && o1.delta == o2.delta && ...
  abs(o1.WA-o2.WA) < tol && abs(o1.WB-o2.WB) < tol, ...
  'No-capacity first passage must reproduce under fixed seeds.');

%% 11. Simulator preserves caller RNG state through isolated streams.
rng(20260903, 'twister');
state_before = rng();
simulate_no_capacity_interface_readiness(p_test, p_test, w0, alpha, 0.6, 0.6, Theta, 100, 777, 888);
state_after = rng();
assert(isequal(state_before, state_after), ...
  'No-capacity interface simulator must preserve caller RNG state.');

fprintf('PASS: continuous-readiness tests.\n');
