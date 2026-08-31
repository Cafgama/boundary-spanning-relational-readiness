% RUN_CAPACITY_V0_4_TESTS
% Standalone test runner for transferable actor learning.

clear;
clc;

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));

addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('\n============================================\n');
fprintf('SCARCE CAPACITY MODEL v0.4 — ACTOR LEARNING TESTS\n');
fprintf('============================================\n');

try
  test_transferable_actor_learning;
catch err
  fprintf('\nFAILED: transferable actor-learning layer\n');
  fprintf('%s\n', err.message);
  rethrow(err);
end

fprintf('\n============================================\n');
fprintf('MODEL v0.4 ACTOR-LEARNING TEST LAYER PASSED\n');
fprintf('============================================\n');
