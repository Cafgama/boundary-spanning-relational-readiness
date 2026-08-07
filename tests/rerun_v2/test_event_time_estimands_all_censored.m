function test_event_time_estimands_all_censored()
  % TEST_EVENT_TIME_ESTIMANDS_ALL_CENSORED
  % All trajectories are censored. Quantiles must not be reported as T_max.

  setup_rerun_v2_tests();

  T_tilde = 100 * ones(5, 1);
  delta = zeros(5, 1);

  S = compute_event_time_estimands(T_tilde, delta);

  assert(S.n == 5, 'Expected five observations.');
  assert(S.n_events == 0, 'Expected zero events.');
  assert(S.n_censored == 5, 'Expected five censored observations.');

  assert_close(S.RMST, 100.0, 1e-12, 'RMST should equal censoring horizon.');
  assert_close(S.readiness_probability, 0.0, 1e-12, ...
    'Readiness probability should be zero.');

  assert(isnan(S.T50), 'T50 should be NaN when no events occur.');
  assert(isnan(S.T90), 'T90 should be NaN when no events occur.');
  assert(isnan(S.T95), 'T95 should be NaN when no events occur.');

  assert(S.T50_estimable == 0, 'T50 should not be estimable.');
  assert(S.T90_estimable == 0, 'T90 should not be estimable.');
  assert(S.T95_estimable == 0, 'T95 should not be estimable.');

  fprintf('test_event_time_estimands_all_censored passed.\n');
end
