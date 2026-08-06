function out = run_dynamics_fast(G, P, record_history)
  % RUN_DYNAMICS_FAST
  % Faster version of run_dynamics.m.
  %
  % Core optimization:
  %   Instead of recomputing R_B(t) by scanning all boundary edges at every
  %   time step, this function maintains the number of ready boundary edges
  %   incrementally.
  %
  % Baseline interaction rule:
  %   1. Select one active agent uniformly at random.
  %   2. Select one neighbor of that agent uniformly at random.
  %   3. Generate a success/failure interaction outcome.
  %   4. Update relational confidence on the selected tie.
  %   5. If the selected tie is cross-boundary, update readiness count.
  %
  % Inputs:
  %   G              network structure from generate_network()
  %   P              parameter structure from baseline_params()
  %   record_history optional boolean. If true, stores RB over time.
  %
  % Output:
  %   out structure with the same main fields as run_dynamics.m.

  if nargin < 3
    record_history = false;
  end

  validate_inputs_fast(G, P, record_history);

  W = G.W;

  % -----------------------------
  % Precompute active agents and neighbor lists
  % -----------------------------
  degrees = sum(G.A, 2);
  active_agents = find(degrees > 0);

  assert(~isempty(active_agents), ...
    'Network contains no active agents with at least one tie.');

  neighbor_lists = cell(P.N, 1);

  for a = 1:P.N
    neighbor_lists{a} = find(G.A(a, :) == 1);
  end

  % -----------------------------
  % Precompute boundary-edge lookup
  % -----------------------------
  % boundary_edge_index(a,b) = row index in G.EB if (a,b) is a boundary edge.
  % Otherwise zero.
  boundary_edge_index = zeros(P.N, P.N);

  for r = 1:rows(G.EB)
    u = G.EB(r, 1);
    i = G.EB(r, 2);

    boundary_edge_index(u, i) = r;
    boundary_edge_index(i, u) = r;
  end

  total_edges = rows(G.EB);

  % -----------------------------
  % Initial boundary readiness status
  % -----------------------------
  boundary_ready = zeros(total_edges, 1);

  for r = 1:total_edges
    u = G.EB(r, 1);
    i = G.EB(r, 2);

    if W(u, i) >= P.theta
      boundary_ready(r) = 1;
    end
  end

  ready_edges = sum(boundary_ready);
  RB = ready_edges / total_edges;

  % -----------------------------
  % Optional history
  % -----------------------------
  if record_history
    RB_history = zeros(P.T_max + 1, 1);
    selected_edges = zeros(P.T_max, 2);

    RB_history(1) = RB;
  else
    RB_history = [];
    selected_edges = [];
  end

  % -----------------------------
  % Check readiness at t = 0
  % -----------------------------
  if RB >= P.q
    out.T = 0;
    out.converged = 1;
    out.final_RB = RB;
    out.final_ready = ready_edges;
    out.total_boundary_edges = total_edges;
    out.final_W = W;

    if record_history
      out.RB_history = RB_history(1);
      out.selected_edges = [];
    else
      out.RB_history = [];
      out.selected_edges = [];
    end

    return;
  end

  % -----------------------------
  % Main dynamic loop
  % -----------------------------
  for t = 1:P.T_max

    % Select one active agent.
    a = active_agents(randi(length(active_agents)));

    % Select one neighbor of that agent.
    neighbors = neighbor_lists{a};

    assert(~isempty(neighbors), ...
      'Selected active agent has no neighbors. This should not happen.');

    b = neighbors(randi(length(neighbors)));

    % Edge type determines success probability.
    etype = G.edge_type(a, b);

    assert(etype == 1 || etype == 2 || etype == 3, ...
      'Selected pair must be an existing edge with valid edge_type.');

    pi_ab = success_probability_fast(etype, P);

    % Draw interaction outcome.
    x = rand() < pi_ab;

    % Update relational confidence.
    old_w = W(a, b);

    assert(old_w >= 0 && old_w <= 1, ...
      'Relational confidence before update must be in [0,1].');

    old_ready_status = old_w >= P.theta;

    if x == 1
      new_w = old_w + P.alpha * (1 - old_w);
    else
      new_w = old_w - P.beta * old_w;
    end

    % Numerical protection against floating point artifacts.
    new_w = min(max(new_w, 0), 1);

    W(a, b) = new_w;
    W(b, a) = new_w;

    new_ready_status = new_w >= P.theta;

    % -----------------------------
    % Incremental readiness update
    % -----------------------------
    boundary_idx = boundary_edge_index(a, b);

    if boundary_idx > 0
      if old_ready_status == 0 && new_ready_status == 1
        boundary_ready(boundary_idx) = 1;
        ready_edges = ready_edges + 1;

      elseif old_ready_status == 1 && new_ready_status == 0
        boundary_ready(boundary_idx) = 0;
        ready_edges = ready_edges - 1;
      end

      % Defensive check
      assert(ready_edges >= 0 && ready_edges <= total_edges, ...
        'ready_edges out of valid range.');
    end

    RB = ready_edges / total_edges;

    if record_history
      selected_edges(t, :) = [a, b];
      RB_history(t + 1) = RB;
    end

    % First-passage condition.
    if RB >= P.q
      out.T = t;
      out.converged = 1;
      out.final_RB = RB;
      out.final_ready = ready_edges;
      out.total_boundary_edges = total_edges;
      out.final_W = W;

      if record_history
        out.RB_history = RB_history(1:(t + 1));
        out.selected_edges = selected_edges(1:t, :);
      else
        out.RB_history = [];
        out.selected_edges = [];
      end

      return;
    end
  end

  % -----------------------------
  % Non-convergence
  % -----------------------------
  out.T = NaN;
  out.converged = 0;
  out.final_RB = RB;
  out.final_ready = ready_edges;
  out.total_boundary_edges = total_edges;
  out.final_W = W;

  if record_history
    out.RB_history = RB_history;
    out.selected_edges = selected_edges;
  else
    out.RB_history = [];
    out.selected_edges = [];
  end
end


function pi_ab = success_probability_fast(edge_type, P)
  % SUCCESS_PROBABILITY_FAST
  % Maps edge type to interaction success probability.

  if edge_type == 1
    pi_ab = P.pi_in;
  elseif edge_type == 2
    pi_ab = P.pi_out;
  elseif edge_type == 3
    pi_ab = P.pi_BS;
  else
    error('Invalid edge_type.');
  end
end


function validate_inputs_fast(G, P, record_history)
  % VALIDATE_INPUTS_FAST
  % Basic consistency checks before running fast dynamics.

  assert(isstruct(G), 'G must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  required_G_fields = {'A', 'W', 'edge_type', 'EB'};

  for i = 1:length(required_G_fields)
    fname = required_G_fields{i};
    assert(isfield(G, fname), ['G must contain field: ', fname]);
  end

  assert(isnumeric(G.A), 'G.A must be numeric.');
  assert(isnumeric(G.W), 'G.W must be numeric.');
  assert(isnumeric(G.edge_type), 'G.edge_type must be numeric.');

  assert(rows(G.A) == columns(G.A), 'G.A must be square.');
  assert(rows(G.W) == columns(G.W), 'G.W must be square.');
  assert(rows(G.edge_type) == columns(G.edge_type), 'G.edge_type must be square.');

  assert(rows(G.A) == rows(G.W), 'G.A and G.W must have same dimension.');
  assert(rows(G.A) == rows(G.edge_type), ...
    'G.A and G.edge_type must have same dimension.');

  assert(isequal(G.A, G.A'), 'G.A must be symmetric.');
  assert(isequal(G.W, G.W'), 'G.W must be symmetric.');
  assert(isequal(G.edge_type, G.edge_type'), 'G.edge_type must be symmetric.');

  assert(all(diag(G.A) == 0), 'Self-loops are not allowed in G.A.');
  assert(all(diag(G.W) == 0), 'Self-loop weights are not allowed in G.W.');

  assert(rows(G.EB) > 0, 'G.EB must contain at least one cross-boundary edge.');

  assert(isfield(P, 'N'), 'P must contain N.');
  assert(isfield(P, 'T_max'), 'P must contain T_max.');
  assert(isfield(P, 'theta'), 'P must contain theta.');
  assert(isfield(P, 'q'), 'P must contain q.');
  assert(isfield(P, 'alpha'), 'P must contain alpha.');
  assert(isfield(P, 'beta'), 'P must contain beta.');
  assert(isfield(P, 'pi_in'), 'P must contain pi_in.');
  assert(isfield(P, 'pi_out'), 'P must contain pi_out.');
  assert(isfield(P, 'pi_BS'), 'P must contain pi_BS.');

  assert(P.N == rows(G.A), 'P.N must match network size.');
  assert(P.T_max == floor(P.T_max) && P.T_max > 0, ...
    'P.T_max must be a positive integer.');

  assert(P.theta >= 0 && P.theta <= 1, 'P.theta must be in [0,1].');
  assert(P.q >= 0 && P.q <= 1, 'P.q must be in [0,1].');

  assert(P.alpha > 0 && P.alpha < 1, 'P.alpha must be in (0,1).');
  assert(P.beta > 0 && P.beta < 1, 'P.beta must be in (0,1).');

  assert(P.pi_in >= 0 && P.pi_in <= 1, 'P.pi_in must be in [0,1].');
  assert(P.pi_out >= 0 && P.pi_out <= 1, 'P.pi_out must be in [0,1].');
  assert(P.pi_BS >= 0 && P.pi_BS <= 1, 'P.pi_BS must be in [0,1].');

  assert(islogical(record_history) || record_history == 0 || record_history == 1, ...
    'record_history must be true or false.');
end
