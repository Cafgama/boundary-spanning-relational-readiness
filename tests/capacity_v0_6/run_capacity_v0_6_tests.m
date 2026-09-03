% RUN_CAPACITY_V0_6_TESTS
% Test runner for continuous demand-weighted readiness.

this_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(this_dir));
addpath(fullfile(repo_root, 'src', 'capacity'));
addpath(this_dir);

fprintf('=== Model v0.6 continuous-readiness test suite ===\n');
test_continuous_readiness;
fprintf('=== PASS: Model v0.6 test suite ===\n');
