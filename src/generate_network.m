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

  % Boundary spanners are empty unless architecture is boundary_spanning.
  BU = [];
  BI = [];

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
    [A, W, edge_type, BU, BI] = add_boundary_spanning_edges(P, A, W, edge_type);
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


function [A, W, edge_type, BU, BI] = add_boundary_spanning_edges(P, A, W, edge_type)
  % Adds exactly k cross-boundary ties involving at least one boundary spanner.

  nU = P.nU;
  N  = P.N;

  university_nodes = 1:nU;
  industry_nodes   = (nU + 1):N;

  % Select boundary spanners.
  BU = university_nodes(randperm(P.nU, P.b));
  BI = industry_nodes(randperm(P.nI, P.b));

  % Candidate pairs: u in BU OR i in BI.
  candidate_pairs = [];

  for u = university_nodes
    for i = industry_nodes
      if any(BU == u) || any(BI == i)
        candidate_pairs = [candidate_pairs; u, i];
      end
    end
  end

  assert(rows(candidate_pairs) >= P.k, ...
    'Not enough boundary-spanning candidate pairs for k.');

  selected_idx = randperm(rows(candidate_pairs), P.k);
  selected_pairs = candidate_pairs(selected_idx, :);

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


function validate_architecture(architecture)
  valid = strcmp(architecture, 'baseline') || ...
          strcmp(architecture, 'random_bridging') || ...
          strcmp(architecture, 'boundary_spanning');

  assert(valid, ...
    'Invalid architecture. Use baseline, random_bridging, or boundary_spanning.');
end
