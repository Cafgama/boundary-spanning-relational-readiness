% RUN_CAPACITY_V0_7_TESTS
% Run coupled capacity-learning tests from this directory.

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));
addpath(fullfile(repo_root, 'src', 'capacity'));

fprintf('=== Model v0.7 coupled capacity-learning tests ===\n');
run(fullfile(this_dir, 'test_coupled_capacity_learning.m'));
fprintf('=== PASS: Model v0.7 coupled capacity-learning suite ===\n');
