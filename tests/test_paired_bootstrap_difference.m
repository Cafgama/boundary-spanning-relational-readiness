% TEST_PAIRED_BOOTSTRAP_DIFFERENCE

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

x = [10; 12; 14; 16; 18];
y = [8; 9; 11; 12; 14];

B = paired_bootstrap_difference(x, y, 2000, 12345);

assert(B.n_pairs == 5, ...
  'Unexpected number of pairs.');

assert(abs(B.mean_difference - mean(x - y)) < 1e-12, ...
  'Incorrect paired mean difference.');

assert(B.n_positive == 5, ...
  'All paired differences should be positive.');

assert(B.ci_lower > 0, ...
  'Bootstrap interval should be positive for this test.');

assert(B.relative_reduction > 0, ...
  'Relative reduction should be positive.');

disp('Paired bootstrap test passed.');
