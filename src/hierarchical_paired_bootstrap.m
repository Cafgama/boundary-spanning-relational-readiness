function B = hierarchical_paired_bootstrap(results_x, results_y, n_boot, seed, quantile_probs)
  % HIERARCHICAL_PAIRED_BOOTSTRAP
  % Paired hierarchical bootstrap for rerun-v2 event-time estimands.
  %
  % Purpose:
  %   Compare two matched simulation conditions while preserving the nested
  %   graph/trajectory design.
  %
  % Required result fields:
  %   graph_id
  %   trajectory_id
  %   T_tilde
  %   delta
  %
  % Bootstrap design:
  %   1. Sample matched graph identifiers with replacement.
  %   2. Within each selected graph, sample matched trajectory identifiers
  %      with replacement.
  %   3. Use the same sampled graph/trajectory pairs in both conditions.
  %   4. Compute pooled marginal estimands for each bootstrap sample.
  %
  % Difference convention:
  %   difference = condition_x - condition_y
  %
  % Interpretation:
  %   For time metrics such as RMST and event-time quantiles, positive
  %   differences mean condition_y is faster/lower. For readiness probability,
  %   positive differences mean condition_x has higher readiness probability.

  if nargin < 3 || isempty(n_boot)
    n_boot = 10000;
  end

  if nargin < 4 || isempty(seed)
    seed = 12345;
  end

  if nargin < 5 || isempty(quantile_probs)
    quantile_probs = [0.50; 0.90; 0.95];
  end

  validate_bootstrap_inputs(results_x, results_y, n_boot, seed, quantile_probs);

  pairs = build_matched_graph_trajectory_pairs(results_x, results_y);

  Sx = compute_event_time_estimands(results_x, quantile_probs);
  Sy = compute_event_time_estimands(results_y, quantile_probs);

  metric_names = {
    'rmst',
    'readiness_probability',
    'censoring_probability',
    'T50',
    'T90',
    'T95'
  };

  n_metrics = length(metric_names);
  boot_differences = NaN(n_boot, n_metrics);

  rand('seed', seed);

  for b = 1:n_boot
    [Tx, dx, Ty, dy] = paired_hierarchical_sample(results_x, results_y, pairs);

    Sx_b = compute_event_time_estimands(Tx, dx, quantile_probs);
    Sy_b = compute_event_time_estimands(Ty, dy, quantile_probs);

    for m = 1:n_metrics
      metric = metric_names{m};
      boot_differences(b, m) = metric_value(Sx_b, metric) - metric_value(Sy_b, metric);
    end
  end

  observed_difference = struct();
  ci_low = struct();
  ci_high = struct();
  bootstrap_valid_share = struct();

  for m = 1:n_metrics
    metric = metric_names{m};

    observed_difference.(metric) = metric_value(Sx, metric) - metric_value(Sy, metric);

    finite_values = boot_differences(:, m);
    finite_values = finite_values(~isnan(finite_values));

    bootstrap_valid_share.(metric) = length(finite_values) / n_boot;

    if length(finite_values) >= 2
      ci_low.(metric) = local_percentile(finite_values, 2.5);
      ci_high.(metric) = local_percentile(finite_values, 97.5);
    else
      ci_low.(metric) = NaN;
      ci_high.(metric) = NaN;
    end
  end

  B.n_boot = n_boot;
  B.seed = seed;
  B.quantile_probs = quantile_probs(:);

  B.n_graphs = length(pairs);
  B.n_trajectories_x = length(results_x.T_tilde);
  B.n_trajectories_y = length(results_y.T_tilde);
  B.n_matched_trajectories = count_matched_trajectories(pairs);

  B.metric_names = metric_names;

  B.observed_x = Sx;
  B.observed_y = Sy;
  B.observed_difference = observed_difference;

  B.ci_low = ci_low;
  B.ci_high = ci_high;
  B.bootstrap_valid_share = bootstrap_valid_share;
  B.bootstrap_differences = boot_differences;

  B.difference_convention = 'condition_x_minus_condition_y';
  B.time_metric_interpretation = 'positive means condition_y is faster/lower';
  B.probability_metric_interpretation = 'for readiness_probability, positive means condition_x is higher';
end


function validate_bootstrap_inputs(results_x, results_y, n_boot, seed, quantile_probs)
  assert(isstruct(results_x), 'results_x must be a structure.');
  assert(isstruct(results_y), 'results_y must be a structure.');

  required_fields = {'graph_id', 'trajectory_id', 'T_tilde', 'delta'};

  for i = 1:length(required_fields)
    fname = required_fields{i};

    assert(isfield(results_x, fname), ['results_x missing field: ', fname]);
    assert(isfield(results_y, fname), ['results_y missing field: ', fname]);
  end

  validate_result_vectors(results_x, 'results_x');
  validate_result_vectors(results_y, 'results_y');

  assert(n_boot > 0 && n_boot == floor(n_boot), ...
    'n_boot must be a positive integer.');

  assert(seed > 0 && seed == floor(seed), ...
    'seed must be a positive integer.');

  assert(isnumeric(quantile_probs), 'quantile_probs must be numeric.');
  assert(all(quantile_probs(:) > 0 & quantile_probs(:) < 1), ...
    'quantile_probs must be inside (0,1).');
end


function validate_result_vectors(R, label)
  n = length(R.T_tilde);

  assert(length(R.delta) == n, [label, ': delta length mismatch.']);
  assert(length(R.graph_id) == n, [label, ': graph_id length mismatch.']);
  assert(length(R.trajectory_id) == n, [label, ': trajectory_id length mismatch.']);

  assert(all(~isnan(R.T_tilde(:))), [label, ': T_tilde cannot contain NaN.']);
  assert(all(isfinite(R.T_tilde(:))), [label, ': T_tilde must be finite.']);
  assert(all(R.T_tilde(:) >= 0), [label, ': T_tilde must be non-negative.']);

  assert(all(R.delta(:) == 0 | R.delta(:) == 1), ...
    [label, ': delta must contain only 0 or 1.']);

  assert(all(R.graph_id(:) == floor(R.graph_id(:))), ...
    [label, ': graph_id must contain integers.']);

  assert(all(R.trajectory_id(:) == floor(R.trajectory_id(:))), ...
    [label, ': trajectory_id must contain integers.']);
end


function pairs = build_matched_graph_trajectory_pairs(X, Y)
  graph_x = unique(X.graph_id(:));
  graph_y = unique(Y.graph_id(:));

  common_graphs = intersect(graph_x, graph_y);

  assert(~isempty(common_graphs), ...
    'No common graph identifiers found.');

  assert(length(common_graphs) == length(graph_x), ...
    'results_x contains graphs not found in results_y.');

  assert(length(common_graphs) == length(graph_y), ...
    'results_y contains graphs not found in results_x.');

  pairs = struct('graph_id', {}, 'x_idx', {}, 'y_idx', {}, 'trajectory_id', {});

  for g = 1:length(common_graphs)
    gid = common_graphs(g);

    ix_g = find(X.graph_id(:) == gid);
    iy_g = find(Y.graph_id(:) == gid);

    traj_x = X.trajectory_id(ix_g);
    traj_y = Y.trajectory_id(iy_g);

    [common_traj, ix_t, iy_t] = intersect(traj_x(:), traj_y(:));

    assert(~isempty(common_traj), ...
      ['No common trajectories in graph ', num2str(gid), '.']);

    assert(length(common_traj) == length(traj_x), ...
      ['results_x has unmatched trajectories in graph ', num2str(gid), '.']);

    assert(length(common_traj) == length(traj_y), ...
      ['results_y has unmatched trajectories in graph ', num2str(gid), '.']);

    pairs(g).graph_id = gid;
    pairs(g).x_idx = ix_g(ix_t);
    pairs(g).y_idx = iy_g(iy_t);
    pairs(g).trajectory_id = common_traj;
  end
end


function [Tx, dx, Ty, dy] = paired_hierarchical_sample(X, Y, pairs)
  n_graphs = length(pairs);

  Tx = [];
  dx = [];
  Ty = [];
  dy = [];

  for g_draw = 1:n_graphs
    selected_graph_pos = randi(n_graphs);

    x_idx = pairs(selected_graph_pos).x_idx;
    y_idx = pairs(selected_graph_pos).y_idx;

    n_traj = length(x_idx);
    sampled_pos = randi(n_traj, n_traj, 1);

    sampled_x_idx = x_idx(sampled_pos);
    sampled_y_idx = y_idx(sampled_pos);

    Tx = [Tx; X.T_tilde(sampled_x_idx)(:)];
    dx = [dx; X.delta(sampled_x_idx)(:)];

    Ty = [Ty; Y.T_tilde(sampled_y_idx)(:)];
    dy = [dy; Y.delta(sampled_y_idx)(:)];
  end
end


function n = count_matched_trajectories(pairs)
  n = 0;

  for g = 1:length(pairs)
    n = n + length(pairs(g).x_idx);
  end
end


function value = metric_value(S, metric)
  if strcmp(metric, 'rmst')
    value = S.rmst;
  elseif strcmp(metric, 'readiness_probability')
    value = S.readiness_probability;
  elseif strcmp(metric, 'censoring_probability')
    value = S.censoring_probability;
  elseif strcmp(metric, 'T50')
    value = S.T50;
  elseif strcmp(metric, 'T90')
    value = S.T90;
  elseif strcmp(metric, 'T95')
    value = S.T95;
  else
    error(['Unknown metric: ', metric]);
  end
end


function p = local_percentile(x, pct)
  x = x(:);
  x = x(~isnan(x));

  assert(~isempty(x), 'Cannot compute percentile of an empty vector.');
  assert(pct >= 0 && pct <= 100, 'pct must be in [0,100].');

  x = sort(x);
  n = length(x);

  if n == 1
    p = x(1);
    return;
  end

  pos = 1 + (pct / 100) * (n - 1);
  lo = floor(pos);
  hi = ceil(pos);

  if lo == hi
    p = x(lo);
  else
    weight = pos - lo;
    p = x(lo) * (1 - weight) + x(hi) * weight;
  end
end
