% TEST_COUPLED_CAPACITY_LEARNING
% Mechanistic tests for Model v0.7 coupled capacity + learning dynamics.

fprintf('Running coupled capacity-learning tests...\n');

tol = 1e-12;
w0 = 0.4;
alpha = 0.08;
Theta = 0.8;

%% 1. Guaranteed-no-blocking limit reproduces the v0.6 no-capacity simulator exactly.
p = [0.4, 0.3, 0.2, 0.1];
x = ones(1,4)/4;
D = 200;
C = 4 * D;  % each actor has D slots; no actor can exhaust within D attempts
ell = 0.6;
demand_seed = 1201;
learning_seed = 2201;

cap = simulate_capacity_learning_readiness(p, p, x, x, w0, alpha, ell, ell, ...
  Theta, C, D, 1, demand_seed, learning_seed);
free = simulate_no_capacity_interface_readiness(p, p, w0, alpha, ell, ell, ...
  Theta, D, demand_seed, learning_seed);

assert(cap.n_blocked == 0, 'Guaranteed-no-blocking construction unexpectedly blocked demand.');
assert(isequaln(cap.T, free.T) && cap.delta == free.delta, ...
  'Coupled simulator must reproduce no-capacity first passage when blocking is impossible.');
assert(abs(cap.WA-free.WA) < tol && abs(cap.WB-free.WB) < tol, ...
  'Coupled and no-capacity terminal readiness states differ in the no-blocking limit.');

%% 2. With ell=0 and one window, admission bookkeeping reproduces run_capacity_window.
p2 = [0.5, 1/6, 1/6, 1/6];
x2 = ones(1,4)/4;
C2 = 30;
D2 = 60;
seed2 = 3301;

adm = run_capacity_window(D2, C2, p2, p2, x2, x2, seed2);
cpl = simulate_capacity_learning_readiness(p2, p2, x2, x2, w0, alpha, 0, 0, ...
  Theta, C2, D2, 1, seed2, 4401);

assert(cpl.delta == 0 && isnan(cpl.T), 'ell=0 must not reach readiness from w0<Theta.');
assert(cpl.n_attempted == D2, 'One-window ell=0 case must process every attempt.');
assert(cpl.n_served == adm.n_served && cpl.n_blocked == adm.n_blocked, ...
  'Coupled simulator admission counts differ from admission-only kernel.');
assert(abs(cpl.blocked_fraction-adm.blocked_fraction) < tol, ...
  'Coupled simulator blocking fraction differs from admission-only kernel.');
if adm.n_blocked > 0
  expected_first_block = find(adm.blocked_mask, 1, 'first');
  assert(cpl.first_block_attempt == expected_first_block, ...
    'First blocked attempt differs from admission-only kernel.');
end

%% 3. Capacity resets each window while transferable memory persists.
% All demand goes to actor 1; actor 1 has exactly five slots per window.
% With ell=1, 14 productive encounters are required, so readiness must occur
% at global attempt 14 in the third window.
p3 = [1, 0, 0, 0];
x3 = [1, 0, 0, 0];
reset_case = simulate_capacity_learning_readiness(p3, p3, x3, x3, w0, alpha, 1, 1, ...
  Theta, 5, 5, 3, 5501, 6501);
assert(reset_case.delta == 1 && reset_case.T == 14, ...
  'Persistent memory with capacity resets should cross exactly at attempt 14.');
assert(reset_case.n_windows_started == 3, ...
  'The 14-event toy case should require exactly three capacity windows.');
assert(reset_case.n_blocked == 0 && reset_case.n_served == 14, ...
  'Matched single-carrier toy case should serve all attempts up to readiness.');

%% 4. Blocked attempts never produce learning.
% Actor 1 receives all demand but only one of five capacity units each window.
x4 = [0.2, 0.8, 0, 0];
blocked_case = simulate_capacity_learning_readiness(p3, p3, x4, x4, w0, alpha, 1, 1, ...
  Theta, 5, 3, 2, 7701, 8701);
assert(blocked_case.delta == 0, 'Two productive events cannot reach Theta=0.8.');
assert(blocked_case.n_served == 2 && blocked_case.n_blocked == 4, ...
  'Expected one served and two blocked attempts per window.');
assert(blocked_case.n_productive_A == 2 && blocked_case.n_productive_B == 2, ...
  'Blocked attempts must not generate productive-learning updates.');
assert(blocked_case.first_block_attempt == 2, ...
  'First blocked attempt should occur immediately after the first slot is used.');
expected_w2 = 1 - (1-w0)*(1-alpha)^2;
assert(abs(blocked_case.WA-expected_w2) < tol && abs(blocked_case.WB-expected_w2) < tol, ...
  'Terminal readiness should reflect exactly two productive learning events.');

%% 5. Capacity resets are operational, not memory resets.
% If memory were incorrectly reset, terminal W would equal one update, not two.
expected_w1 = 1 - (1-w0)*(1-alpha);
assert(blocked_case.WA > expected_w1 + tol, ...
  'Transferable memory appears to have reset across capacity windows.');

%% 6. Realized load metrics use integer-realized capacity shares, not targets.
% C2=30 and target x=(1/4,... ) realizes c=(8,8,7,7), so the heavy
% carrier has x_realized=8/30 and Lambda=0.5/(8/30)=1.875 rather than 2.
assert(abs(cpl.Omega_realized - adm.Omega_realized) < tol, ...
  'Coupled and admission-only realized Omega must agree.');
assert(abs(cpl.Lambda_realized - adm.Lambda_realized) < tol, ...
  'Coupled and admission-only realized Lambda must agree.');
assert(abs(cpl.chi_realized - adm.chi_realized) < tol, ...
  'Coupled and admission-only realized chi must agree.');
assert(abs(cpl.Lambda_realized - 1.875) < tol, ...
  'Expected Lambda=1.875 after largest-remainder integer realization.');

%% 7. Fixed seeds reproduce the complete coupled first passage.
r1 = simulate_capacity_learning_readiness(p2, p2, x2, x2, w0, alpha, 0.7, 0.7, ...
  Theta, 60, 72, 4, 9901, 10901);
r2 = simulate_capacity_learning_readiness(p2, p2, x2, x2, w0, alpha, 0.7, 0.7, ...
  Theta, 60, 72, 4, 9901, 10901);
assert(isequaln(r1.T,r2.T) && r1.delta == r2.delta && ...
  r1.n_blocked == r2.n_blocked && abs(r1.Wmin-r2.Wmin) < tol, ...
  'Coupled first passage must reproduce under fixed seeds.');

%% 8. Coupled simulator preserves caller RNG state.
rng(20260903, 'twister');
state_before = rng();
simulate_capacity_learning_readiness(p2, p2, x2, x2, w0, alpha, 0.7, 0.7, ...
  Theta, 60, 72, 2, 11101, 12101);
state_after = rng();
assert(isequal(state_before, state_after), ...
  'Coupled simulator must preserve caller RNG state.');

fprintf('PASS: coupled capacity-learning tests.\n');
