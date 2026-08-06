% TEST_CONFIGURE_MECHANISM_CONDITION

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

[P_RB, arch_RB, label_RB] = configure_mechanism_condition(P, 'RB_low');

assert(strcmp(label_RB, 'RB_low'), 'Wrong label for RB_low.');
assert(strcmp(arch_RB, 'random_bridging'), 'RB_low must use random_bridging.');
assert(abs(P_RB.pi_BS - P_RB.pi_out) < 1e-12, ...
  'RB_low should set pi_BS equal to pi_out for clarity.');

[P_BS_low, arch_BS_low, label_BS_low] = configure_mechanism_condition(P, 'BS_low');

assert(strcmp(label_BS_low, 'BS_low'), 'Wrong label for BS_low.');
assert(strcmp(arch_BS_low, 'boundary_spanning'), ...
  'BS_low must use boundary_spanning.');
assert(abs(P_BS_low.pi_BS - P_BS_low.pi_out) < 1e-12, ...
  'BS_low must have no translation advantage.');

[P_BS_high, arch_BS_high, label_BS_high] = configure_mechanism_condition(P, 'BS_high');

assert(strcmp(label_BS_high, 'BS_high'), 'Wrong label for BS_high.');
assert(strcmp(arch_BS_high, 'boundary_spanning'), ...
  'BS_high must use boundary_spanning.');
assert(P_BS_high.pi_BS > P_BS_high.pi_out, ...
  'BS_high must have translation advantage.');

disp('Mechanism condition configuration test passed.');
