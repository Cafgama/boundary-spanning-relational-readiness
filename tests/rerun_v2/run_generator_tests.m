function run_generator_tests()
  % RUN_GENERATOR_TESTS
  % Runs rerun_v2 structural tests for RB, BS, and matched designs.
  %
  % These tests are intentionally stricter than the old smoke tests.
  % They encode the locked balanced single-responsibility BS design.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(this_dir);

  tests = {
    'test_RB_exact_k',
    'test_BS_balanced_single_responsibility',
    'test_matched_network_invariants',
    'test_BS_low_high_identical_network'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 GENERATOR TESTS\n');
  fprintf('============================================\n');

  failed = {};

  for i = 1:length(tests)

    test_name = tests{i};

    fprintf('\n--------------------------------------------\n');
    fprintf('Running %s\n', test_name);
    fprintf('--------------------------------------------\n');

    try
      feval(test_name);
      fprintf('PASSED: %s\n', test_name);
    catch err
      fprintf('FAILED: %s\n', test_name);
      fprintf('Reason: %s\n', err.message);
      failed{end + 1} = test_name;
    end
  end

  fprintf('\n============================================\n');

  if isempty(failed)
    fprintf('ALL RERUN V2 GENERATOR TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');

    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end

    error('One or more rerun_v2 generator tests failed.');
  end

  fprintf('============================================\n');
end
