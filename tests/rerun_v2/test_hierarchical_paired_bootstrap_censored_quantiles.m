function test_hierarchical_paired_bootstrap_censored_quantiles()
  % TEST_HIERARCHICAL_PAIRED_BOOTSTRAP_CENSORED_QUANTILES
  % Checks that non-estimable observed quantiles remain NaN and are not
  % replaced by the censoring time.

  setup_rerun_v2_tests();

  X.graph_id = [1; 1; 2; 2];
  X.trajectory_id = [1; 2; 1; 2];
  X.T_tilde = [10; 20; 50; 50];
  X.delta = [1; 1; 0; 0];

  Y.graph_id = [1; 1; 2; 2];
  Y.trajectory_id = [1; 2; 1; 2];
  Y.T_tilde = [8; 16; 24; 50];
  Y.delta = [1; 1; 1; 0];

  B = hierarchical_paired_bootstrap(X, Y, 200, 54321);

  assert_close(B.observed_x.readiness_probability, 0.50, 1e-10, ...
    'Unexpected readiness probability for X.');

  assert_close(B.observed_y.readiness_probability, 0.75, 1e-10, ...
    'Unexpected readiness probability for Y.');

  assert_close(B.observed_difference.readiness_probability, -0.25, 1e-10, ...
    'Unexpected readiness-probability difference.');

  assert(B.observed_x.T50_estimable == 1, 'X T50 should be estimable.');
  assert(B.observed_y.T50_estimable == 1, 'Y T50 should be estimable.');

  assert(B.observed_x.T90_estimable == 0, 'X T90 should not be estimable.');
  assert(B.observed_y.T90_estimable == 0, 'Y T90 should not be estimable.');

  assert(isnan(B.observed_difference.T90), ...
    'Observed T90 difference should be NaN when either side is non-estimable.');

  assert(isnan(B.observed_difference.T95), ...
    'Observed T95 difference should be NaN when either side is non-estimable.');

  assert(B.bootstrap_valid_share.rmst == 1, ...
    'RMST should be valid in every bootstrap sample.');

  assert(B.bootstrap_valid_share.T90 < 1, ...
    'T90 should not be valid in every censored bootstrap sample.');

  disp('test_hierarchical_paired_bootstrap_censored_quantiles passed.');
end
