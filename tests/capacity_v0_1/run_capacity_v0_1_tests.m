% RUN_CAPACITY_V0_1_TESTS
% Standalone deterministic test runner for Scarce Interaction Capacity Model v0.1.
%
% This runner is intentionally separate from tests/run_all_tests.m so the
% validated legacy test suite remains untouched.

clear;
clc;

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));

addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('\n============================================\n');
fprintf('SCARCE CAPACITY MODEL v0.1 — ANALYTICAL TESTS\n');
fprintf('============================================\n');

try
  test_analytical_reductions;
catch err
  fprintf('\nFAILED: deterministic analytical layer\n');
  fprintf('%s\n', err.message);
  rethrow(err);
end

fprintf('\n============================================\n');
fprintf('MODEL v0.1 ANALYTICAL TEST LAYER PASSED\n');
fprintf('============================================\n');
