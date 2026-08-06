function G = generate_network(P, architecture)
  % GENERATE_NETWORK
  % Generates one collaboration network for the boundary-spanning
  % relational coordination readiness model.
  %
  % Inputs:
  %   P            parameter structure from baseline_params()
  %   architecture string:
  %                  'baseline'
  %                  'random_bridging'
  %                  'boundary_spanning'
  %
  % Output:
  %   G structure containing:
  %     A          adjacency matrix
  %     W          relational-confidence matrix
  %     module     module vector: 1 = university, 2 = industry
  %     edge_type  0 = no edge, 1 = internal, 2 = ordinary cross-boundary,
  %                3 = boundary-spanning cross-boundary
  %     BU         university-side boundary spanners
  %     BI         industry-side boundary spanners
  %     EB         list of cross-boundary edges
  %
  % Rerun-v2 boundary-spanning rule:
  %   Every boundary-spanning cross-boundary tie has exactly one
  %   boundary-spanner endpoint. The opposite endpoint is always a
  %   non-boundary-spanner actor. The k cross-boundary ties are split as
  %   evenly as possible between university-side and industry-side
  %   responsibility, and workloads are balanced within each side.

  validate_architecture(architecture);

  N  = P.N;
  nU = P.nU;
  nI = P.nI;

  % -----------------------------
  % Initialize matrices
  % -----------------------------
  A = zeros(N, N);
  W = zeros(N, N);
  edge_type = zeros(N, N);

  % -----------------------------
  % Define modules
  % -----------------------------
  university_nodes = 1:nU;
  industry_nodes   = (nU + 1):N;

  module = zeros(N, 1);
  module(university_nodes) = 1;
  module(industry_nodes)   = 2;

  % Boundary-spanning fields are empty unless architecture is boundary_spanning.
  BU = [];
  BI = [];
  BS_info = empty_boundary_spanning_info();

  % -----------------------------
  % Generate internal ties
  % -----------------------------
  for a = 1:nU
    for b = (a + 1):nU
      if rand() < P.p_in
        A(a, b) = 1;
        A(b, a) = 1;

        W(a, b) = P.w0;
        W(b, a) = P.w0;

        edge_type(a, b) = 1;
        edge_type(b, a) = 1;
      end
    end
  end

  for a = (nU + 1):N
    for b = (a + 1):N
      if rand() < P.p_in
        A(a, b) = 1;
        A(b, a) = 1;

        W(a, b) = P.w0;
        W(b, a) = P.w0;

        edge_type(a, b) = 1;
        edge_type(b, a) = 1;
      end
    end
  end

  % -----------------------------
  % Generate cross-boundary ties
  % -----------------------------
  if strcmp(architecture, 'baseline')
    [A, W, edge_type] = add_baseline_cross_edges(P, A, W, edge_type);

  elseif strcmp(architecture, 'random_bridging')
    [A, W, edge_type] = add_random_bridging_edges(P, A, W, edge_type);

  elseif strcmp(architecture, 'boundary_spanning')
    [A, W, edge_type, BU, BI, BS_info] = ...
      add_boundary_spanning_edges(P, A, W, edge_type);
  end

  % -----------------------------
  % Extract cross-boundary edge list
  % -----------------------------
  EB = extract_cross_boundary_edges(edge_type, nU, N);

  % -----------------------------
  % Basic sanity checks
  % -----------------------------
  assert(isequal(A, A'), 'Adjacency matrix A must be symmetric.');
  assert(isequal(W, W'), 'Weight matrix W must be symmetric.');
  assert(isequal(edge_type, edge_type'), 'edge_type matrix must be symmetric.');
  assert(all(diag(A) == 0), 'Self-loops are not allowed.');
  assert(all(diag(W) == 0), 'Self-loop weights are not allowed.');

  if strcmp(architecture, 'random_bridging') || strcmp(architecture, 'boundary_spanning')
    assert(rows(EB) == P.k, ...
      'Controlled architectures must have exactly k cross-boundary edges.');
  end

  if strcmp(architecture, 'baseline')
    assert(rows(EB) > 0, ...
      'Baseline network generated no cross-boundary ties. Regenerate or adjust p_out.');
  end

  if strcmp(architecture, 'boundary_spanning')
    validate_boundary_spanning_network(P, EB, edge_type, BU, BI, BS_info);
  end

  % -----------------------------
  % Return graph structure
  % -----------------------------
  G.A = A;
  G.W = W;
  G.module = module;
  G.edge_type = edge_type;
  G.BU = BU;
  G.BI = BI;
  G.EB = EB;
  G.architecture = architecture;

  % Workload diagnostics used by rerun-v2 manifests and analyses.
  G.BS_info = BS_info;
  G.BS_load_U = BS_info.load_U;
  G.BS_load_I = BS_info.load_I;
  G.BS_workload_mean = BS_info.workload_mean;
  G.BS_workload_min = BS_info.workload_min;
  G.BS_workload_max = BS_info.workload_max;
  G.BS_workload_sd = BS_info.workload_sd;
end


function [A, W, edge_type] = add_baseline_cross_edges(P, A, W, edge_type)
  % Adds cross-boundary ties using p_out.

  nU = P.nU;
  N  = P.N;

  for u = 1:nU
    for i = (nU + 1):N
      if rand() < P.p_out
        A(u, i) = 1;
        A(i, u) = 1;

        W(u, i) = P.w0;
        W(i, u) = P.w0;

        edge_type(u, i) = 2;
        edge_type(i, u) = 2;
      end
    end
  end
end


function [A, W, edge_type] = add_random_bridging_edges(P, A, W, edge_type)
  % Adds exactly k cross-boundary ties uniformly at random.

  pairs = all_cross_boundary_pairs(P.nU, P.nI);
  selected_idx = randperm(rows(pairs), P.k);
  selected_pairs = pairs(selected_idx, :);

  for r = 1:rows(selected_pairs)
    u = selected_pairs(r, 1);
    i = selected_pairs(r, 2);

    A(u, i) = 1;
    A(i, u) = 1;

    W(u, i) = P.w0;
    W(i, u) = P.w0;

    edge_type(u, i) = 2;
    edge_type(i, u) = 2;
  end
end


function [A, W, edge_type, BU, BI, BS_info] = ...
  add_boundary_spanning_edges(P, A, W, edge_type)
  % Adds exactly k cross-boundary ties using balanced single-responsibility.
  %
  % Each selected cross-boundary tie has exactly one boundary-spanner
  % endpoint. Responsibility is split as evenly as possible between the
  % university side and the industry side.

  nU = P.nU;
  N  = P.N;

  university_nodes = 1:nU;
  industry_nodes   = (nU + 1):N;

  % Select boundary spanners on both sides.
  BU = university_nodes(randperm(P.nU, P.b));
  BI = industry_nodes(randperm(P.nI, P.b));

  non_BU = setdiff(university_nodes, BU);
  non_BI = setdiff(industry_nodes, BI);

  assert(~isempty(non_BU), ...
    'Boundary-spanning design requires at least one university non-spanner.');

  assert(~isempty(non_BI), ...
    'Boundary-spanning design requires at least one industry non-spanner.');

  % Split responsibility between sides.
  k_U = ceil(P.k / 2);
  k_I = P.k - k_U;

  assert(k_U <= P.b * length(non_BI), ...
    'Not enough industry non-spanner partners for university-side responsibility.');

  assert(k_I <= P.b * length(non_BU), ...
    'Not enough university non-spanner partners for industry-side responsibility.');

  load_U = balanced_load_counts(k_U, P.b);
  load_I = balanced_load_counts(k_I, P.b);

  selected_pairs = [];
  responsibility_side = [];

  % University-side responsibility:
  % university boundary spanner -> industry non-spanner.
  for s = 1:P.b
    current_load = load_U(s);

    if current_load > 0
      partner_idx = randperm(length(non_BI), current_load);
      partners = non_BI(partner_idx);

      for p = 1:length(partners)
        selected_pairs = [selected_pairs; BU(s), partners(p)];
        responsibility_side = [responsibility_side; 1];
      end
    end
  end

  % Industry-side responsibility:
  % university non-spanner -> industry boundary spanner.
  for s = 1:P.b
    current_load = load_I(s);

    if current_load > 0
      partner_idx = randperm(length(non_BU), current_load);
      partners = non_BU(partner_idx);

      for p = 1:length(partners)
        selected_pairs = [selected_pairs; partners(p), BI(s)];
        responsibility_side = [responsibility_side; 2];
      end
    end
  end

  assert(rows(selected_pairs) == P.k, ...
    'Boundary-spanning selected_pairs must contain exactly k rows.');

  assert_no_duplicate_rows(selected_pairs, 'boundary-spanning selected_pairs');

  for r = 1:rows(selected_pairs)
    u = selected_pairs(r, 1);
    i = selected_pairs(r, 2);

    A(u, i) = 1;
    A(i, u) = 1;

    W(u, i) = P.w0;
    W(i, u) = P.w0;

    edge_type(u, i) = 3;
    edge_type(i, u) = 3;
  end

  all_load = [load_U; load_I];

  BS_info = empty_boundary_spanning_info();
  BS_info.responsibility_side = responsibility_side;
  BS_info.load_U = load_U;
  BS_info.load_I = load_I;
  BS_info.n_U_responsibility = sum(responsibility_side == 1);
  BS_info.n_I_responsibility = sum(responsibility_side == 2);
  BS_info.workload_mean = mean(all_load);
  BS_info.workload_min = min(all_load);
  BS_info.workload_max = max(all_load);
  BS_info.workload_sd = std(all_load);
end


function counts = balanced_load_counts(total_load, n_spanners)
  % BALANCED_LOAD_COUNTS
  % Splits total_load across n_spanners as evenly as possible.

  assert(total_load >= 0 && total_load == floor(total_load), ...
    'total_load must be a non-negative integer.');

  assert(n_spanners > 0 && n_spanners == floor(n_spanners), ...
    'n_spanners must be a positive integer.');

  base_load = floor(total_load / n_spanners);
  remainder = total_load - base_load * n_spanners;

  counts = base_load * ones(n_spanners, 1);

  if remainder > 0
    counts(1:remainder) = counts(1:remainder) + 1;
  end
end


function pairs = all_cross_boundary_pairs(nU, nI)
  % Returns all possible university-industry pairs.
  %
  % University nodes: 1,...,nU
  % Industry nodes: nU+1,...,nU+nI

  pairs = [];

  for u = 1:nU
    for i = (nU + 1):(nU + nI)
      pairs = [pairs; u, i];
    end
  end
end


function EB = extract_cross_boundary_edges(edge_type, nU, N)
  % Extracts cross-boundary edges from edge_type matrix.
  % Returns each undirected edge only once.

  EB = [];

  for u = 1:nU
    for i = (nU + 1):N
      if edge_type(u, i) == 2 || edge_type(u, i) == 3
        EB = [EB; u, i];
      end
    end
  end
end


function validate_boundary_spanning_network(P, EB, edge_type, BU, BI, BS_info)
  % VALIDATE_BOUNDARY_SPANNING_NETWORK
  % Defensive validation of the rerun-v2 BS architecture.

  assert(length(BU) == P.b, ...
    'Wrong number of university boundary spanners.');

  assert(length(BI) == P.b, ...
    'Wrong number of industry boundary spanners.');

  assert(rows(EB) == P.k, ...
    'Boundary-spanning network must have exactly k cross-boundary edges.');

  assert_no_duplicate_rows(EB, 'EB');

  n_U_responsibility = 0;
  n_I_responsibility = 0;

  for r = 1:rows(EB)
    u = EB(r, 1);
    i = EB(r, 2);

    u_is_bs = any(BU == u);
    i_is_bs = any(BI == i);

    assert(xor(u_is_bs, i_is_bs), ...
      'Every BS tie must have exactly one boundary-spanner endpoint.');

    assert(edge_type(u, i) == 3, ...
      'Every BS cross-boundary tie must have edge_type 3.');

    if u_is_bs
      n_U_responsibility = n_U_responsibility + 1;
    else
      n_I_responsibility = n_I_responsibility + 1;
    end
  end

  if mod(P.k, 2) == 0
    assert(n_U_responsibility == P.k / 2, ...
      'University-side responsibility must be k/2 when k is even.');

    assert(n_I_responsibility == P.k / 2, ...
      'Industry-side responsibility must be k/2 when k is even.');
  else
    assert(abs(n_U_responsibility - n_I_responsibility) <= 1, ...
      'Side responsibility counts must differ by at most one when k is odd.');
  end

  assert(sum(BS_info.load_U) == n_U_responsibility, ...
    'University-side load vector does not match responsibility count.');

  assert(sum(BS_info.load_I) == n_I_responsibility, ...
    'Industry-side load vector does not match responsibility count.');

  assert(max(BS_info.load_U) - min(BS_info.load_U) <= 1, ...
    'University-side workload must be balanced.');

  assert(max(BS_info.load_I) - min(BS_info.load_I) <= 1, ...
    'Industry-side workload must be balanced.');
end


function assert_no_duplicate_rows(X, label)
  % ASSERT_NO_DUPLICATE_ROWS
  % Fails if a two-column matrix contains duplicate rows.

  if rows(X) <= 1
    return;
  end

  X_sorted = sortrows(X);

  for r = 2:rows(X_sorted)
    assert(~isequal(X_sorted(r, :), X_sorted(r - 1, :)), ...
      [label, ' contains duplicate rows.']);
  end
end


function info = empty_boundary_spanning_info()
  % EMPTY_BOUNDARY_SPANNING_INFO
  % Returns a consistently shaped empty BS diagnostics structure.

  info.responsibility_side = [];
  info.load_U = [];
  info.load_I = [];
  info.n_U_responsibility = NaN;
  info.n_I_responsibility = NaN;
  info.workload_mean = NaN;
  info.workload_min = NaN;
  info.workload_max = NaN;
  info.workload_sd = NaN;
end


function validate_architecture(architecture)
  valid = strcmp(architecture, 'baseline') || ...
          strcmp(architecture, 'random_bridging') || ...
          strcmp(architecture, 'boundary_spanning');

  assert(valid, ...
    'Invalid architecture. Use baseline, random_bridging, or boundary_spanning.');
end
