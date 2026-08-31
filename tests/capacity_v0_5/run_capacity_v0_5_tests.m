% RUN_CAPACITY_V0_5_TESTS
% Standalone tests for endpoint-specific productive-learning competence.

clear;
clc;

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));

addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('\n============================================\n');
fprintf('SCARCE CAPACITY MODEL v0.5 — COMPETENCE TESTS\n');
fprintf('============================================\n');

try
  test_endpoint_learning_competence;
catch err
  fprintf('\nFAILED: endpoint learning-competence layer\n');
  fprintf('%s\n', err.message);
  rethrow(err);
end

fprintf('\n============================================\n');
fprintf('MODEL v0.5 COMPETENCE TEST LAYER PASSED\n');
fprintf('============================================\n');
