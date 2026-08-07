function run_bootstrap_tests()
  % RUN_BOOTSTRAP_TESTS
  % Runs rerun_v2 tests for the hierarchical paired bootstrap.

  setup_rerun_v2_tests();

  tests = {
    'test_hierarchical_paired_bootstrap_complete_data',
    'test_hierarchical_paired_bootstrap_censored_quantiles',
    'test_hierarchical_paired_bootstrap_matching_errors'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 HIERARCHICAL BOOTSTRAP TESTS\n');
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
    fprintf('ALL RERUN V2 HIERARCHICAL BOOTSTRAP TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');

    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end

    error('One or more rerun_v2 hierarchical bootstrap tests failed.');
  end

  fprintf('============================================\n');
end
