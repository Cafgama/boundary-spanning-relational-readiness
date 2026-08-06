function test_RB_exact_k()
  % TEST_RB_EXACT_K
  % Tests the locked random-bridging architecture requirements.

  setup_rerun_v2_tests();

  P = baseline_params();
  seeds = P.seed + (1:10);

  for s = 1:length(seeds)

    rand('seed', seeds(s));
    G1 = generate_network(P, 'random_bridging');

    assert(rows(G1.EB) == P.k, ...
      'RB must contain exactly k cross-boundary ties.');

    assert_no_duplicate_rows(G1.EB, 'RB EB');

    for r = 1:rows(G1.EB)
      u = G1.EB(r, 1);
      i = G1.EB(r, 2);

      assert(u >= 1 && u <= P.nU, ...
        'RB first endpoint must be a university node.');

      assert(i >= P.nU + 1 && i <= P.N, ...
        'RB second endpoint must be an industry node.');

      assert(G1.edge_type(u, i) == 2, ...
        'RB cross-boundary ties must have edge_type 2.');
    end

    % Reproducibility under fixed seed.
    rand('seed', seeds(s));
    G2 = generate_network(P, 'random_bridging');

    assert(isequal(G1.A, G2.A), ...
      'RB generation must be reproducible under fixed seed.');

    assert(isequal(G1.edge_type, G2.edge_type), ...
      'RB edge types must be reproducible under fixed seed.');

    assert(isequal(G1.EB, G2.EB), ...
      'RB EB list must be reproducible under fixed seed.');
  end

  fprintf('test_RB_exact_k passed.\n');
end
