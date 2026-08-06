function GS = summarize_by_graph(results, P)
  % SUMMARIZE_BY_GRAPH
  % Aggregates trajectory-level simulation results at graph level.
  %
  % Each output row represents one graph realization.
  %
  % Inputs:
  %   results  structure returned by the resumable experiment
  %   P        parameter structure
  %
  % Output:
  %   GS       graph-level summary structure

  validate_inputs(results, P);

  graph_ids = unique(results.graph_id(:));
  n_graphs = length(graph_ids);

  % Preallocate graph-level arrays.
  graph_id = zeros(n_graphs, 1);
  n_trajectories = zeros(n_graphs, 1);
  n_converged = zeros(n_graphs, 1);
  n_nonconverged = zeros(n_graphs, 1);

  convergence_rate = zeros(n_graphs, 1);
  nonconvergence_rate = zeros(n_graphs, 1);

  T_conv_mean = NaN(n_graphs, 1);
  T_conv_median = NaN(n_graphs, 1);
  T_conv_p90 = NaN(n_graphs, 1);
  T_conv_p95 = NaN(n_graphs, 1);

  T_cens_mean = NaN(n_graphs, 1);
  T_cens_median = NaN(n_graphs, 1);
  T_cens_p90 = NaN(n_graphs, 1);
  T_cens_p95 = NaN(n_graphs, 1);

  final_RB_mean = NaN(n_graphs, 1);

  total_edges = NaN(n_graphs, 1);
  mean_degree = NaN(n_graphs, 1);
  max_degree = NaN(n_graphs, 1);
  total_boundary_edges = NaN(n_graphs, 1);

  for g = 1:n_graphs
    gid = graph_ids(g);
    idx = results.graph_id == gid;

    T_g = results.T(idx);
    conv_g = results.converged(idx);
    final_RB_g = results.final_RB(idx);

    graph_id(g) = gid;
    n_trajectories(g) = sum(idx);
    n_converged(g) = sum(conv_g == 1);
    n_nonconverged(g) = sum(conv_g == 0);

    convergence_rate(g) = n_converged(g) / n_trajectories(g);
    nonconvergence_rate(g) = n_nonconverged(g) / n_trajectories(g);

    % Converged-only times.
    T_success = T_g(conv_g == 1);

    if ~isempty(T_success)
      T_conv_mean(g) = mean(T_success);
      T_conv_median(g) = local_percentile(T_success, 50);
      T_conv_p90(g) = local_percentile(T_success, 90);
      T_conv_p95(g) = local_percentile(T_success, 95);
    end

    % Censored times: assign T_max to non-converged runs.
    T_censored = T_g;
    T_censored(isnan(T_censored)) = P.T_max;

    T_cens_mean(g) = mean(T_censored);
    T_cens_median(g) = local_percentile(T_censored, 50);
    T_cens_p90(g) = local_percentile(T_censored, 90);
    T_cens_p95(g) = local_percentile(T_censored, 95);

    final_RB_mean(g) = mean(final_RB_g);

    % Network statistics must be constant within each graph.
    total_edges(g) = unique_graph_value(results.total_edges(idx), ...
      'total_edges', gid);

    mean_degree(g) = unique_graph_value(results.mean_degree(idx), ...
      'mean_degree', gid);

    max_degree(g) = unique_graph_value(results.max_degree(idx), ...
      'max_degree', gid);

    total_boundary_edges(g) = unique_graph_value( ...
      results.total_boundary_edges(idx), ...
      'total_boundary_edges', gid);
  end

  % Package output.
  GS.architecture = results.architecture;
  GS.NG = results.NG;
  GS.NT = results.NT;
  GS.seed = results.seed;

  GS.graph_id = graph_id;
  GS.n_trajectories = n_trajectories;
  GS.n_converged = n_converged;
  GS.n_nonconverged = n_nonconverged;

  GS.convergence_rate = convergence_rate;
  GS.nonconvergence_rate = nonconvergence_rate;

  GS.T_conv_mean = T_conv_mean;
  GS.T_conv_median = T_conv_median;
  GS.T_conv_p90 = T_conv_p90;
  GS.T_conv_p95 = T_conv_p95;

  GS.T_cens_mean = T_cens_mean;
  GS.T_cens_median = T_cens_median;
  GS.T_cens_p90 = T_cens_p90;
  GS.T_cens_p95 = T_cens_p95;

  GS.final_RB_mean = final_RB_mean;

  GS.total_edges = total_edges;
  GS.mean_degree = mean_degree;
  GS.max_degree = max_degree;
  GS.total_boundary_edges = total_boundary_edges;
end


function value = unique_graph_value(x, variable_name, graph_id)
  % Ensures that a graph-level variable is constant across trajectories.

  x = x(:);
  tolerance = 1e-12;

  assert(~isempty(x), ...
    ['No observations found for graph ', num2str(graph_id), '.']);

  assert(max(abs(x - x(1))) < tolerance, ...
    [variable_name, ' varies within graph ', num2str(graph_id), '.']);

  value = x(1);
end


function p = local_percentile(x, pct)
  % Computes percentile by linear interpolation without requiring
  % the Octave statistics package.

  x = x(:);
  x = x(~isnan(x));

  assert(pct >= 0 && pct <= 100, ...
    'Percentile must be between 0 and 100.');

  if isempty(x)
    p = NaN;
    return;
  end

  x = sort(x);
  n = length(x);

  if n == 1
    p = x(1);
    return;
  end

  position = 1 + (pct / 100) * (n - 1);
  lower_index = floor(position);
  upper_index = ceil(position);

  if lower_index == upper_index
    p = x(lower_index);
  else
    weight = position - lower_index;

    p = x(lower_index) * (1 - weight) + ...
        x(upper_index) * weight;
  end
end


function validate_inputs(results, P)
  assert(isstruct(results), 'results must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  required_fields = {
    'architecture',
    'NG',
    'NT',
    'seed',
    'graph_id',
    'T',
    'converged',
    'final_RB',
    'total_edges',
    'mean_degree',
    'max_degree',
    'total_boundary_edges'
  };

  for i = 1:length(required_fields)
    field_name = required_fields{i};

    assert(isfield(results, field_name), ...
      ['results is missing field: ', field_name]);
  end

  n = length(results.T);

  assert(length(results.graph_id) == n, ...
    'graph_id length must equal T length.');

  assert(length(results.converged) == n, ...
    'converged length must equal T length.');

  assert(length(results.final_RB) == n, ...
    'final_RB length must equal T length.');

  assert(all(results.converged == 0 | results.converged == 1), ...
    'converged must contain only zero or one.');

  assert(P.T_max > 0 && P.T_max == floor(P.T_max), ...
    'P.T_max must be a positive integer.');
end
