% TEST_CAPACITY_ADMISSION_LAYER
% Exact tests for the finite-capacity admission mechanism.
% No relational-learning dynamics are exercised here.

fprintf('Testing maximum-entropy pairing...\n');
pA = [0.7, 0.3];
pB = [0.2, 0.5, 0.3];
P = maximum_entropy_pairing(pA, pB);
assert(max(abs(sum(P, 2)' - pA)) < 1e-12, ...
  'Joint distribution does not reproduce pA.');
assert(max(abs(sum(P, 1) - pB)) < 1e-12, ...
  'Joint distribution does not reproduce pB.');
assert(abs(sum(P(:)) - 1) < 1e-12, ...
  'Joint distribution does not sum to one.');
assert(abs(P(1, 2) - pA(1) * pB(2)) < 1e-12, ...
  'Joint distribution is not the product closure.');

fprintf('Testing largest-remainder integer allocation...\n');
[c, xr] = allocate_integer_capacity(7, [0.5, 0.3, 0.2]);
assert(isequal(c, [4, 2, 1]), ...
  'Unexpected largest-remainder allocation.');
assert(sum(c) == 7, 'Total integer capacity is not conserved.');
assert(abs(sum(xr) - 1) < 1e-12, ...
  'Realized capacity shares do not sum to one.');

[c_tie, ~] = allocate_integer_capacity(2, [1/3, 1/3, 1/3]);
assert(isequal(c_tie, [1, 1, 0]), ...
  'Largest-remainder tie-breaking is not deterministic by actor index.');

fprintf('Testing exact matched-capacity identity when integer-feasible...\n');
p = [0.5, 0.3, 0.2];
[c_match, x_match] = allocate_integer_capacity(10, p);
assert(isequal(c_match, [5, 3, 2]), ...
  'Integer-feasible matched allocation is incorrect.');
M_match = capacity_load_metrics(10, 10, p, x_match);
assert(abs(M_match.Lambda - 1) < 1e-12, ...
  'x=p should give Lambda=1 when the shares are integer-feasible.');

fprintf('Testing finite-window integer discretization mismatch...\n');
[~, x_small] = allocate_integer_capacity(7, p);
M_small = capacity_load_metrics(7, 7, p, x_small);
assert(abs(M_small.Lambda - 1.4) < 1e-12, ...
  'Unexpected realized mismatch from integer discretization.');

fprintf('Testing deterministic bilateral admission kernel...\n');
pairs = [1 1; 1 2; 2 2; 2 1];
adm = admit_capacity_sequence(pairs, [1 1], [1 1]);
assert(adm.n_served == 2, 'Expected exactly two served demands.');
assert(adm.n_blocked == 2, 'Expected exactly two blocked demands.');
assert(isequal(adm.served_mask, logical([1; 0; 1; 0])), ...
  'Unexpected served-demand pattern.');
assert(isequal(adm.remaining_capacity_A, [0 0]), ...
  'Module-A capacity accounting is incorrect.');
assert(isequal(adm.remaining_capacity_B, [0 0]), ...
  'Module-B capacity accounting is incorrect.');
assert(isequal(adm.used_capacity_A, [1 1]), ...
  'Module-A served-capacity use is incorrect.');
assert(isequal(adm.used_capacity_B, [1 1]), ...
  'Module-B served-capacity use is incorrect.');
assert(adm.blocked_mask(2) && adm.served_mask(3), ...
  'A blocked attempt appears to have consumed the free opposite-end capacity.');

fprintf('Testing zero-capacity blocking without consumption...\n');
adm_zero = admit_capacity_sequence([1 1; 2 1], [0 1], [1 1]);
assert(adm_zero.blocked_mask(1), ...
  'Demand to a zero-capacity endpoint must be blocked.');
assert(adm_zero.served_mask(2), ...
  'Blocked demand must not consume capacity from the opposite endpoint.');
assert(adm_zero.remaining_capacity_B(1) == 0, ...
  'The later served interaction should consume B1 exactly once.');

fprintf('Testing demand-generator reproducibility and RNG isolation...\n');
rng(999, 'twister');
expected_first = rand();
expected_second = rand();

rng(999, 'twister');
actual_first = rand();
pairs_seed_1 = generate_max_entropy_demands(100, pA, pB, 12345);
actual_second = rand();
pairs_seed_2 = generate_max_entropy_demands(100, pA, pB, 12345);

assert(actual_first == expected_first && actual_second == expected_second, ...
  'Demand generator changed the caller RNG stream.');
assert(isequal(pairs_seed_1, pairs_seed_2), ...
  'Equal demand seeds must generate identical endpoint sequences.');
assert(all(pairs_seed_1(:,1) >= 1 & pairs_seed_1(:,1) <= length(pA)), ...
  'Generated module-A endpoint outside valid range.');
assert(all(pairs_seed_1(:,2) >= 1 & pairs_seed_1(:,2) <= length(pB)), ...
  'Generated module-B endpoint outside valid range.');

fprintf('Testing one-window wrapper invariants...\n');
p4 = ones(1,4) / 4;
out = run_capacity_window(100, 20, p4, p4, p4, p4, 314159);
assert(out.n_served + out.n_blocked == 100, ...
  'One-window attempt conservation failed.');
assert(out.n_served <= 20, ...
  'One module cannot serve more interactions than its total capacity.');
assert(sum(out.used_capacity_A) == out.n_served, ...
  'Module-A capacity use does not equal served demand count.');
assert(sum(out.used_capacity_B) == out.n_served, ...
  'Module-B capacity use does not equal served demand count.');
assert(abs(sum(out.xA_realized) - 1) < 1e-12, ...
  'Realized A capacity shares do not sum to one.');
assert(abs(sum(out.xB_realized) - 1) < 1e-12, ...
  'Realized B capacity shares do not sum to one.');
assert(abs(out.Omega_realized - 5) < 1e-12, ...
  'Incorrect realized scarcity ratio.');
assert(abs(out.Lambda_realized - 1) < 1e-12, ...
  'Uniform responsibility and capacity should give Lambda=1.');
assert(abs(out.chi_realized - 5) < 1e-12, ...
  'Incorrect realized peak offered load.');
assert(~isfield(out, 'w') && ~isfield(out, 'pi') && ...
       ~isfield(out, 'alpha') && ~isfield(out, 'beta'), ...
  'Admission layer must not contain relational-learning state.');

fprintf('All Model v0.2 admission-layer tests passed.\n');
