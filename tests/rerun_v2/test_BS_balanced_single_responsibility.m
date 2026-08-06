function test_BS_balanced_single_responsibility()
  % TEST_BS_BALANCED_SINGLE_RESPONSIBILITY
  % Tests the locked balanced single-responsibility BS architecture.
  %
  % This test is expected to fail against the old generator because the old
  % generator allows pairs with at least one boundary spanner, rather than
  % enforcing exactly one spanner endpoint and balanced side responsibility.

  setup_rerun_v2_tests();

  P0 = baseline_params();

  b_values = [1, 2, 4, 6];
  expected_max_load = [6, 3, 2, 1];

  for bi = 1:length(b_values)

    P = P0;
    P.b = b_values(bi);

    for s = 1:10

      rand('seed', P.seed + 1000 * P.b + s);
      G = generate_network(P, 'boundary_spanning');

      D = assert_balanced_bs_network(G, P);

      expected_mean = P.k / (2 * P.b);

      assert(abs(D.workload_mean - expected_mean) < 1e-12, ...
        'Mean realized workload must equal k/(2b).');

      assert(D.workload_max == expected_max_load(bi), ...
        'Maximum realized workload does not match expected load table.');
    end
  end

  fprintf('test_BS_balanced_single_responsibility passed.\n');
end
