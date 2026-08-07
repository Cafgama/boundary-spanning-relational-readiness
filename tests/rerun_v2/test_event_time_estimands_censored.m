function test_event_time_estimands_censored()
  % TEST_EVENT_TIME_ESTIMANDS_CENSORED
  % Mixed event/censoring case with some estimable and non-estimable quantiles.

  setup_rerun_v2_tests();

  T_tilde = [10; 20; 30; 100; 100];
  delta = [1; 1; 1; 0; 0];

  S = compute_event_time_estimands(T_tilde, delta);

  assert(S.n == 5, 'Expected five observations.');
  assert(S.n_events == 3, 'Expected three events.');
  assert(S.n_censored == 2, 'Expected two censored observations.');

  assert_close(S.RMST, 52.0, 1e-12, 'RMST should equal mean T_tilde.');
  assert_close(S.readiness_probability, 0.6, 1e-12, ...
    'Readiness probability should be 3/5.');

  % n = 5, so T50 requires ceil(0.50*5) = 3 observed events.
  assert(S.T50 == 30, 'Expected T50 = 30.');
  assert(S.T50_estimable == 1, 'T50 should be estimable.');

  % T90 and T95 require five observed events, but only three occurred.
  assert(isnan(S.T90), 'T90 should be NaN when not estimable.');
  assert(isnan(S.T95), 'T95 should be NaN when not estimable.');

  assert(S.T90_estimable == 0, 'T90 should not be estimable.');
  assert(S.T95_estimable == 0, 'T95 should not be estimable.');

  fprintf('test_event_time_estimands_censored passed.\n');
end
