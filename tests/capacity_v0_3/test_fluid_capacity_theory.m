% TEST_FLUID_CAPACITY_THEORY
% Exact tests for the symmetric maximum-entropy fluid-limit solution.

fprintf('Testing matched-allocation fluid benchmark...\n');
p = [0.5, 1/6, 1/6, 1/6];
x_match = p;

F08 = fluid_capacity_symmetric(0.8, p, x_match);
assert(abs(F08.Lambda - 1) < 1e-12, ...
  'Matched allocation should have Lambda=1.');
assert(abs(F08.onset_s - 1) < 1e-12, ...
  'Matched allocation should exhaust first at s=1.');
assert(abs(F08.blocked_fraction) < 1e-12, ...
  'Matched allocation should have no fluid blocking for Omega<1.');

F125 = fluid_capacity_symmetric(1.25, p, x_match);
assert(abs(F125.blocked_fraction - 0.2) < 1e-12, ...
  'Matched allocation should satisfy f_blocked=1-1/Omega above Omega=1.');
assert(abs(F125.served_fraction - 0.8) < 1e-12, ...
  'Matched allocation served fraction is incorrect.');

fprintf('Testing canonical one-heavy mismatch benchmark...\n');
x_uniform = ones(1,4) / 4;
F04 = fluid_capacity_symmetric(0.4, p, x_uniform);
F05 = fluid_capacity_symmetric(0.5, p, x_uniform);
F10 = fluid_capacity_symmetric(1.0, p, x_uniform);
F20 = fluid_capacity_symmetric(2.0, p, x_uniform);
F25 = fluid_capacity_symmetric(2.5, p, x_uniform);
F30 = fluid_capacity_symmetric(3.0, p, x_uniform);

assert(abs(F04.Lambda - 2) < 1e-12, ...
  'Canonical mismatch should have Lambda=2.');
assert(abs(F04.onset_s - 0.5) < 1e-12, ...
  'Canonical mismatch should first exhaust at s=1/2.');
assert(abs(F04.blocked_fraction) < 1e-12, ...
  'No fluid blocking is expected below Omega=1/2.');
assert(abs(F05.blocked_fraction) < 1e-12, ...
  'Fluid blocking should begin only after Omega=1/2.');

% For 1/2 < Omega < 5/2:
%   f_blocked = 3/4 - 3/(8 Omega).
assert(abs(F10.blocked_fraction - 0.375) < 1e-12, ...
  'Canonical mismatch fluid curve is incorrect at Omega=1.');
assert(abs(F20.blocked_fraction - 0.5625) < 1e-12, ...
  'Canonical mismatch fluid curve is incorrect at Omega=2.');
assert(abs(F25.blocked_fraction - 0.6) < 1e-12, ...
  'Canonical mismatch fluid curve is incorrect at full exhaustion.');

% For Omega > 5/2, all usable capacity is exhausted:
%   f_blocked = 1 - 1/Omega.
assert(abs(F30.blocked_fraction - (2/3)) < 1e-12, ...
  'Post-exhaustion fluid curve is incorrect.');

fprintf('Testing chi=1 onset identity...\n');
assert(abs(F05.chi - 1) < 1e-12, ...
  'Canonical mismatch should satisfy chi=1 at Omega=1/2.');
assert(abs(F125.chi - 1.25) < 1e-12, ...
  'Matched-allocation chi calculation is incorrect.');

fprintf('Testing diffuse matched benchmark equivalence...\n');
p_diffuse = ones(1,4) / 4;
F_diff = fluid_capacity_symmetric(1.25, p_diffuse, p_diffuse);
assert(abs(F_diff.blocked_fraction - F125.blocked_fraction) < 1e-12, ...
  'Fluid matched-allocation curve should not depend on responsibility concentration.');

fprintf('All Model v0.3 fluid-theory tests passed.\n');
