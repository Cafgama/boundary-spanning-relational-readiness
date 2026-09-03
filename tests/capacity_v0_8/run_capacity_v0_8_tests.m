function run_capacity_v0_8_tests()
  fprintf('=== Model v0.8 coupled fluid-learning tests ===\n');
  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));
  run(fullfile(this_dir,'test_fluid_learning_readiness.m'));
  fprintf('=== PASS: Model v0.8 coupled fluid-learning suite ===\n');
end
