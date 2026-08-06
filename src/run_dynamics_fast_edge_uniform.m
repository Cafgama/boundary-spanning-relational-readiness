function out = run_dynamics_fast_edge_uniform(G, P, verbose)
  % RUN_DYNAMICS_FAST_EDGE_UNIFORM
  % Edge-uniform version of the relational-confidence dynamics.
  %
  % At each time step:
  %   1. Select one existing undirected edge uniformly at random.
  %   2. Draw success/failure according to edge type.
  %   3. Update relational confidence.
  %
  % This function is used as a robustness benchmark against the
  % agent-first interaction rule.

  if nargin < 3
    verbose = false;
  end

  assert(isstruct(G), 'G must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  assert(isfield(G, 'A'), 'G must contain adjacency matrix A.');
  assert(isfield(G, 'W'), 'G must contain weight matrix W.');
  assert(isfield(G, 'edge_type'), 'G must contain edge_type matrix.');
  assert(isfield(G, 'EB'), 'G must contain cross-boundary edge list EB.');

  N = size(G.A, 1);

  W = G.W;

  % Existing undirected edges.
  [edge_i, edge_j] = find(triu(G.A, 1));
  num_edges = length(edge_i);

  assert(num_edges > 0, 'Network has no edges.');

  total_boundary_edges = size(G.EB, 1);

  assert(total_boundary_edges > 0, ...
    'Network has no cross-boundary edges.');

  % Initial boundary readiness.
  ready_edges = 0;

  for e = 1:total_boundary_edges
    u = G.EB(e, 1);
    v = G.EB(e, 2);

    if W(u, v) >= P.theta
      ready_edges = ready_edges + 1;
    end
  end

  RB = ready_edges / total_boundary_edges;

  RB_history = NaN(P.T_max + 1, 1);
  RB_history(1) = RB;

  converged = 0;
  T = P.T_max;

  if RB >= P.q
    converged = 1;
    T = 0;
  end

  if verbose
    fprintf('Initial RB = %.4f\n', RB);
  end

  % Main dynamics.
  if converged == 0

    for t = 1:P.T_max

      % Select one edge uniformly.
      selected_edge = ceil(rand() * num_edges);

      a = edge_i(selected_edge);
      b = edge_j(selected_edge);

      etype = G.edge_type(a, b);

      if etype == 1
        success_probability = P.pi_in;
      elseif etype == 2
        success_probability = P.pi_out;
      elseif etype == 3
        success_probability = P.pi_BS;
      else
        error('Invalid edge type for an existing edge.');
      end

      % Check whether this is a boundary edge before update.
      is_boundary_edge = (etype == 2 || etype == 3);
      was_ready = false;

      if is_boundary_edge
        was_ready = (W(a, b) >= P.theta);
      end

      % Interaction outcome.
      if rand() < success_probability
        new_w = W(a, b) + P.alpha * (1 - W(a, b));
      else
        new_w = W(a, b) - P.beta * W(a, b);
      end

      % Numerical safety.
      if new_w < 0
        new_w = 0;
      elseif new_w > 1
        new_w = 1;
      end

      W(a, b) = new_w;
      W(b, a) = new_w;

      % Incremental boundary-readiness update.
      if is_boundary_edge
        is_ready_now = (new_w >= P.theta);

        if was_ready == false && is_ready_now == true
          ready_edges = ready_edges + 1;
        elseif was_ready == true && is_ready_now == false
          ready_edges = ready_edges - 1;
        end
      end

      RB = ready_edges / total_boundary_edges;
      RB_history(t + 1) = RB;

      if RB >= P.q
        converged = 1;
        T = t;
        break;
      end
    end
  end

  if converged == 1
    RB_history = RB_history(1:(T + 1));
  else
    RB_history = RB_history(1:(P.T_max + 1));
  end

  out.T = T;
  out.converged = converged;

  out.final_RB = RB;
  out.final_ready = ready_edges;
  out.total_boundary_edges = total_boundary_edges;

  out.final_W = W;
  out.RB_history = RB_history;

  out.selection_rule = 'edge_uniform';
end
