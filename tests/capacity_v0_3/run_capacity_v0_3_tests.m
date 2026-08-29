% RUN_CAPACITY_V0_3_TESTS
% Standalone test runner for the fluid-limit admission theory.

clear;
clc;

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));

addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('\n============================================\n');
fprintf('SCARCE CAPACITY MODEL v0.3 — FLUID THEORY TESTS\n');
fprintf('============================================\n');

try
  test_fluid_capacity_theory;
catch err
  fprintf('\nFAILED: fluid-limit admission theory\n');
  fprintf('%s\n', err.message);
  rethrow(err);
end

fprintf('\n============================================\n');
fprintf('MODEL v0.3 FLUID THEORY TEST LAYER PASSED\n');
fprintf('============================================\n');
