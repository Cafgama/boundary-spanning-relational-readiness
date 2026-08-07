function run_smoke_tests()
  % RUN_SMOKE_TESTS
  % Runs the rerun_v2 end-to-end smoke pipeline test.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(this_dir);
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SMOKE TESTS\n');
  fprintf('============================================\n');

  try
    test_smoke_pipeline();
    fprintf('\n============================================\n');
    fprintf('ALL RERUN V2 SMOKE TESTS PASSED\n');
    fprintf('============================================\n');
  catch err
    fprintf('\nFAILED: test_smoke_pipeline\n');
    fprintf('Reason: %s\n', err.message);
    rethrow(err);
  end
end
