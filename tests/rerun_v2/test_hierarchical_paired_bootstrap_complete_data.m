function test_hierarchical_paired_bootstrap_complete_data()
  % TEST_HIERARCHICAL_PAIRED_BOOTSTRAP_COMPLETE_DATA
  % Checks observed paired differences and bootstrap bookkeeping when all
  % trajectories reach readiness.

  setup_rerun_v2_tests();

  X.graph_id = [1; 1; 2; 2];
  X.trajectory_id = [1; 2; 1; 2];
  X.T_tilde = [10; 20; 30; 40];
  X.delta = [1; 1; 1; 1];

  Y.graph_id = [1; 1; 2; 2];
  Y.trajectory_id = [1; 2; 1; 2];
  Y.T_tilde = [5; 10; 15; 20];
  Y.delta = [1; 1; 1; 1];

  B = hierarchical_paired_bootstrap(X, Y, 200, 12345);

  assert(B.n_graphs == 2, 'Expected two matched graphs.');
  assert(B.n_matched_trajectories == 4, 'Expected four matched trajectories.');

  assert_close(B.observed_difference.rmst, 12.5, 1e-10, ...
    'Unexpected observed RMST difference.');

  assert_close(B.observed_difference.readiness_probability, 0, 1e-10, ...
    'Readiness-probability difference should be zero.');

  assert_close(B.observed_difference.T50, 10, 1e-10, ...
    'Unexpected observed T50 difference.');

  assert_close(B.observed_difference.T90, 20, 1e-10, ...
    'Unexpected observed T90 difference.');

  assert_close(B.observed_difference.T95, 20, 1e-10, ...
    'Unexpected observed T95 difference.');

  assert(~isnan(B.ci_low.rmst), 'RMST lower CI should be finite.');
  assert(~isnan(B.ci_high.rmst), 'RMST upper CI should be finite.');

  assert_close(B.bootstrap_valid_share.rmst, 1, 1e-10, ...
    'RMST should be valid in every bootstrap sample.');

  assert_close(B.bootstrap_valid_share.T50, 1, 1e-10, ...
    'T50 should be valid in every complete-data bootstrap sample.');

  disp('test_hierarchical_paired_bootstrap_complete_data passed.');
end
