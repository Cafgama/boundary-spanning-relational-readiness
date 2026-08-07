function test_event_time_estimands_struct_input()
  % TEST_EVENT_TIME_ESTIMANDS_STRUCT_INPUT
  % The estimand function should accept a results-like structure.

  setup_rerun_v2_tests();

  results.T_tilde = [5; 15; 25; 50];
  results.delta = [1; 1; 0; 0];

  S = compute_event_time_estimands(results);

  assert(S.n == 4, 'Expected four observations.');
  assert(S.n_events == 2, 'Expected two events.');
  assert(S.n_censored == 2, 'Expected two censored observations.');

  assert_close(S.RMST, 23.75, 1e-12, 'RMST should equal mean T_tilde.');
  assert_close(S.readiness_probability, 0.5, 1e-12, ...
    'Readiness probability should be 2/4.');

  assert(S.T50 == 15, 'Expected T50 = 15.');
  assert(S.T50_estimable == 1, 'T50 should be estimable.');

  assert(isnan(S.T90), 'T90 should not be estimable.');
  assert(isnan(S.T95), 'T95 should not be estimable.');

  fprintf('test_event_time_estimands_struct_input passed.\n');
end
