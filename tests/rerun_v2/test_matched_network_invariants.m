function test_matched_network_invariants()
  % TEST_MATCHED_NETWORK_INVARIANTS
  % Tests basic matched-design invariants for RB and BS under a shared seed.
  %
  % Under the current generator order, the same graph seed should produce
  % identical within-module adjacency before the architectures diverge in
  % cross-boundary allocation.

  setup_rerun_v2_tests();

  P = baseline_params();

  for s = 1:10

    seed = P.seed + 2000 + s;

    rand('seed', seed);
    G_RB = generate_network(P, 'random_bridging');

    rand('seed', seed);
    G_BS = generate_network(P, 'boundary_spanning');

    internal_mask = zeros(P.N, P.N);
    internal_mask(1:P.nU, 1:P.nU) = 1;
    internal_mask((P.nU + 1):P.N, (P.nU + 1):P.N) = 1;
    internal_mask = internal_mask - diag(diag(internal_mask));

    assert(isequal(G_RB.A .* internal_mask, G_BS.A .* internal_mask), ...
      'Matched RB and BS graphs must have identical within-module adjacency under same graph seed.');

    assert(rows(G_RB.EB) == P.k, ...
      'Matched RB must have exactly k cross-boundary ties.');

    assert(rows(G_BS.EB) == P.k, ...
      'Matched BS must have exactly k cross-boundary ties.');
  end

  fprintf('test_matched_network_invariants passed.\n');
end
