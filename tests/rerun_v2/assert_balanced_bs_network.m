function D = assert_balanced_bs_network(G, P)
  % ASSERT_BALANCED_BS_NETWORK
  % Checks the locked balanced single-responsibility BS architecture.
  %
  % Requirements checked:
  %   - exactly k cross-boundary ties;
  %   - every BS cross-boundary tie has exactly one boundary-spanner endpoint;
  %   - the opposite endpoint is a non-boundary-spanner actor;
  %   - when k is even, k/2 ties are assigned to university-side spanners
  %     and k/2 to industry-side spanners;
  %   - within each side, assigned workloads differ by at most one;
  %   - total assigned workload equals k.

  assert(isfield(G, 'BU'), 'G must contain BU.');
  assert(isfield(G, 'BI'), 'G must contain BI.');
  assert(isfield(G, 'EB'), 'G must contain EB.');
  assert(isfield(G, 'edge_type'), 'G must contain edge_type.');

  assert(length(G.BU) == P.b, ...
    'Wrong number of university-side boundary spanners.');

  assert(length(G.BI) == P.b, ...
    'Wrong number of industry-side boundary spanners.');

  assert(rows(G.EB) == P.k, ...
    'BS must contain exactly k cross-boundary ties.');

  assert_no_duplicate_rows(G.EB, 'G.EB');

  load_U = zeros(P.b, 1);
  load_I = zeros(P.b, 1);

  n_U_responsibility = 0;
  n_I_responsibility = 0;

  for r = 1:rows(G.EB)

    u = G.EB(r, 1);
    i = G.EB(r, 2);

    assert(u >= 1 && u <= P.nU, ...
      'First EB endpoint must be a university node.');

    assert(i >= P.nU + 1 && i <= P.N, ...
      'Second EB endpoint must be an industry node.');

    u_is_bs = any(G.BU == u);
    i_is_bs = any(G.BI == i);

    assert(xor(u_is_bs, i_is_bs), ...
      'Each BS cross-boundary tie must have exactly one boundary-spanner endpoint.');

    assert(G.edge_type(u, i) == 3, ...
      'BS cross-boundary ties must have edge_type 3.');

    if u_is_bs
      idx = find(G.BU == u);
      assert(length(idx) == 1, ...
        'University spanner index must be unique.');

      load_U(idx) = load_U(idx) + 1;
      n_U_responsibility = n_U_responsibility + 1;

    else
      idx = find(G.BI == i);
      assert(length(idx) == 1, ...
        'Industry spanner index must be unique.');

      load_I(idx) = load_I(idx) + 1;
      n_I_responsibility = n_I_responsibility + 1;
    end
  end

  if mod(P.k, 2) == 0
    assert(n_U_responsibility == P.k / 2, ...
      'Expected k/2 relationships assigned to university-side spanners.');

    assert(n_I_responsibility == P.k / 2, ...
      'Expected k/2 relationships assigned to industry-side spanners.');
  else
    assert(abs(n_U_responsibility - n_I_responsibility) <= 1, ...
      'Responsibility counts should differ by at most one when k is odd.');
  end

  assert(sum(load_U) + sum(load_I) == P.k, ...
    'Total assigned BS workload must equal k.');

  assert(max(load_U) - min(load_U) <= 1, ...
    'University-side assigned workload must differ by at most one.');

  assert(max(load_I) - min(load_I) <= 1, ...
    'Industry-side assigned workload must differ by at most one.');

  all_load = [load_U; load_I];

  D.load_U = load_U;
  D.load_I = load_I;
  D.n_U_responsibility = n_U_responsibility;
  D.n_I_responsibility = n_I_responsibility;
  D.workload_mean = mean(all_load);
  D.workload_min = min(all_load);
  D.workload_max = max(all_load);
  D.workload_sd = std(all_load);
end
