function run_estimand_tests()
  % RUN_ESTIMAND_TESTS
  % Runs rerun_v2 tests for manuscript-facing event-time estimands.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(this_dir);

  tests = {
    'test_event_time_estimands_complete_data',
    'test_event_time_estimands_censored',
    'test_event_time_estimands_all_censored',
    'test_event_time_estimands_struct_input',
    'test_event_time_estimands_invalid_inputs'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 EVENT-TIME ESTIMAND TESTS\n');
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
    fprintf('ALL RERUN V2 EVENT-TIME ESTIMAND TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');

    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end

    error('One or more rerun_v2 event-time estimand tests failed.');
  end

  fprintf('============================================\n');
end
