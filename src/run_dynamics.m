function out = run_dynamics(G, P, record_history)
  % RUN_DYNAMICS
  % Runs one dynamic trajectory on a generated collaboration network.
  %
  % Baseline interaction rule:
  %   1. Select one active agent uniformly at random.
  %   2. Select one neighbor of that agent uniformly at random.
  %   3. Generate a success/failure interaction outcome.
  %   4. Update relational confidence on the selected tie.
  %   5. Recalculate cross-boundary readiness.
  %
  % Inputs:
  %   G              network structure from generate_network()
  %   P              parameter structure from baseline_params()
  %   record_history optional boolean. If true, stores RB over time.
  %
  % Output:
  %   out structure containing:
  %     T              first-passage time if converged; NaN otherwise
  %     converged      1 if readiness reached, 0 otherwise
  %     final_RB       final cross-boundary readiness
  %     final_ready    final number of ready cross-boundary ties
  %     final_W        final relational-confidence matrix
  %     RB_history     optional readiness trajectory
  %     selected_edges optional selected edges if record_history = true

  if nargin < 3
    record_history = false;
  end

  validate_inputs(G, P, record_history);

  W = G.W;

  % Active agents are agents with at least one tie.
  degrees = sum(G.A, 2);
  active_agents = find(degrees > 0);

  assert(!isempty(active_agents), ...
    'Network contains no active agents with at least one tie.');

  % Initial readiness
  [RB, ready_edges, total_edges] = compute_readiness(W, G.EB, P.theta);

  if record_history
    RB_history = zeros(P.T_max + 1, 1);
    selected_edges = zeros(P.T_max, 2);

    RB_history(1) = RB;
  else
    RB_history = [];
    selected_edges = [];
  end

  % Check whether already ready at t = 0
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

  % Main dynamic loop
  for t = 1:P.T_max

    % Select one active agent, then one neighbor.
    a = active_agents(randi(length(active_agents)));

    neighbors = find(G.A(a, :) == 1);

    assert(!isempty(neighbors), ...
      'Selected active agent has no neighbors. This should not happen.');

    b = neighbors(randi(length(neighbors)));

    % Edge type determines success probability.
    etype = G.edge_type(a, b);

    assert(etype == 1 || etype == 2 || etype == 3, ...
      'Selected pair must be an existing edge with valid edge_type.');

    pi_ab = success_probability(etype, P);

    % Draw interaction outcome.
    x = rand() < pi_ab;

    % Update relational confidence.
    old_w = W(a, b);

    assert(old_w >= 0 && old_w <= 1, ...
      'Relational confidence before update must be in [0,1].');

    if x == 1
      new_w = old_w + P.alpha * (1 - old_w);
    else
      new_w = old_w - P.beta * old_w;
    end

    % Numerical protection against floating point artifacts.
    new_w = min(max(new_w, 0), 1);

    W(a, b) = new_w;
    W(b, a) = new_w;

    if record_history
      selected_edges(t, :) = [a, b];
    end

    % Recalculate readiness.
    [RB, ready_edges, total_edges] = compute_readiness(W, G.EB, P.theta);

    if record_history
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

  % If this point is reached, the trajectory did not converge.
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


function pi_ab = success_probability(edge_type, P)
  % SUCCESS_PROBABILITY
  % Maps edge type to interaction success probability.
  %
  % edge_type:
  %   1 = internal tie
  %   2 = ordinary cross-boundary tie
  %   3 = boundary-spanning cross-boundary tie

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


function validate_inputs(G, P, record_history)
  % VALIDATE_INPUTS
  % Basic consistency checks before running dynamics.

  assert(isstruct(G), 'G must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  assert(isfield(G, 'A'), 'G must contain adjacency matrix A.');
  assert(isfield(G, 'W'), 'G must contain weight matrix W.');
  assert(isfield(G, 'edge_type'), 'G must contain edge_type matrix.');
  assert(isfield(G, 'EB'), 'G must contain cross-boundary edge list EB.');

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

  assert(isfield(P, 'T_max'), 'P must contain T_max.');
  assert(isfield(P, 'theta'), 'P must contain theta.');
  assert(isfield(P, 'q'), 'P must contain q.');
  assert(isfield(P, 'alpha'), 'P must contain alpha.');
  assert(isfield(P, 'beta'), 'P must contain beta.');
  assert(isfield(P, 'pi_in'), 'P must contain pi_in.');
  assert(isfield(P, 'pi_out'), 'P must contain pi_out.');
  assert(isfield(P, 'pi_BS'), 'P must contain pi_BS.');

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
