function test_BS_low_high_identical_network()
  % TEST_BS_LOW_HIGH_IDENTICAL_NETWORK
  % BS-low and BS-high should use the same complete network under the same
  % graph seed. Only the interaction success probability changes later in
  % the dynamics.

  setup_rerun_v2_tests();

  P_low = baseline_params();
  P_high = baseline_params();

  P_low.pi_BS = P_low.pi_out;
  P_high.pi_BS = 0.65;

  for s = 1:10

    seed = P_low.seed + 3000 + s;

    rand('seed', seed);
    G_low = generate_network(P_low, 'boundary_spanning');

    rand('seed', seed);
    G_high = generate_network(P_high, 'boundary_spanning');

    assert(isequal(G_low.A, G_high.A), ...
      'BS-low and BS-high must have identical adjacency under same graph seed.');

    assert(isequal(G_low.edge_type, G_high.edge_type), ...
      'BS-low and BS-high must have identical edge types.');

    assert(isequal(G_low.BU, G_high.BU), ...
      'BS-low and BS-high must have identical university spanners.');

    assert(isequal(G_low.BI, G_high.BI), ...
      'BS-low and BS-high must have identical industry spanners.');

    assert(isequal(G_low.EB, G_high.EB), ...
      'BS-low and BS-high must have identical boundary edge lists.');
  end

  fprintf('test_BS_low_high_identical_network passed.\n');
end
