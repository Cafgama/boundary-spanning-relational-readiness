function test_event_time_estimands_complete_data()
  % TEST_EVENT_TIME_ESTIMANDS_COMPLETE_DATA
  % Complete data: all trajectories reach readiness.

  setup_rerun_v2_tests();

  T_tilde = [1; 2; 3; 4];
  delta = [1; 1; 1; 1];

  S = compute_event_time_estimands(T_tilde, delta);

  assert(S.n == 4, 'Expected four observations.');
  assert(S.n_events == 4, 'Expected four events.');
  assert(S.n_censored == 0, 'Expected zero censored observations.');

  assert_close(S.RMST, 2.5, 1e-12, 'RMST should equal mean observed time.');
  assert_close(S.readiness_probability, 1.0, 1e-12, ...
    'Readiness probability should be one.');

  % Empirical event-time quantile is the first time at which the event CDF
  % reaches the requested probability. With n = 4, ranks are 2, 4, and 4.
  assert(S.T50 == 2, 'Expected T50 = 2.');
  assert(S.T90 == 4, 'Expected T90 = 4.');
  assert(S.T95 == 4, 'Expected T95 = 4.');

  assert(S.T50_estimable == 1, 'T50 should be estimable.');
  assert(S.T90_estimable == 1, 'T90 should be estimable.');
  assert(S.T95_estimable == 1, 'T95 should be estimable.');

  fprintf('test_event_time_estimands_complete_data passed.\n');
end
