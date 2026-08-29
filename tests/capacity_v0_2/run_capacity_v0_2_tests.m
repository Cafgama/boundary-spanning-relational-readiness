% RUN_CAPACITY_V0_2_TESTS
% Standalone test runner for the finite-capacity admission layer.
% The legacy test runner remains untouched.

clear;
clc;

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));

addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('\n============================================\n');
fprintf('SCARCE CAPACITY MODEL v0.2 — ADMISSION TESTS\n');
fprintf('============================================\n');

try
  test_capacity_admission_layer;
catch err
  fprintf('\nFAILED: finite-capacity admission layer\n');
  fprintf('%s\n', err.message);
  rethrow(err);
end

fprintf('\n============================================\n');
fprintf('MODEL v0.2 ADMISSION TEST LAYER PASSED\n');
fprintf('============================================\n');
