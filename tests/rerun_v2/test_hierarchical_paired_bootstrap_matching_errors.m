function test_hierarchical_paired_bootstrap_matching_errors()
  % TEST_HIERARCHICAL_PAIRED_BOOTSTRAP_MATCHING_ERRORS
  % Ensures that unmatched graph/trajectory designs fail loudly.

  setup_rerun_v2_tests();

  X.graph_id = [1; 1; 2; 2];
  X.trajectory_id = [1; 2; 1; 2];
  X.T_tilde = [10; 20; 30; 40];
  X.delta = [1; 1; 1; 1];

  Y = X;
  Y.graph_id = [1; 1; 3; 3];

  did_fail = false;

  try
    hierarchical_paired_bootstrap(X, Y, 10, 111);
  catch
    did_fail = true;
  end

  assert(did_fail, 'Bootstrap should fail when graph identifiers are unmatched.');

  Y = X;
  Y.trajectory_id = [1; 3; 1; 2];

  did_fail = false;

  try
    hierarchical_paired_bootstrap(X, Y, 10, 111);
  catch
    did_fail = true;
  end

  assert(did_fail, 'Bootstrap should fail when trajectory identifiers are unmatched.');

  disp('test_hierarchical_paired_bootstrap_matching_errors passed.');
end
