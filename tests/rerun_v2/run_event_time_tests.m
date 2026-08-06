function run_event_time_tests()
  % RUN_EVENT_TIME_TESTS
  % Runs rerun-v2 event-time field tests.
  %
  % These tests verify that T, T_tilde, and delta follow the locked
  % censoring convention for both agent-first and edge-uniform dynamics.

  setup_rerun_v2_tests();

  tests = {
    'test_event_time_fields_agent_first',
    'test_event_time_fields_edge_uniform'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 EVENT-TIME TESTS\n');
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
    fprintf('ALL RERUN V2 EVENT-TIME TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');

    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end

    error('One or more rerun_v2 event-time tests failed.');
  end

  fprintf('============================================\n');
end
