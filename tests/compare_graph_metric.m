function C = compare_graph_metric(GS_x, GS_y, metric_name, n_boot, seed)
  % COMPARE_GRAPH_METRIC
  % Performs a paired graph-level comparison between two architectures.
  %
  % The reported difference is:
  %
  %   architecture_x - architecture_y
  %
  % Therefore, a positive difference means architecture_y has a lower
  % value than architecture_x.
  %
  % Inputs:
  %   GS_x         first graph-summary structure
  %   GS_y         second graph-summary structure
  %   metric_name  graph-level metric field
  %   n_boot       number of bootstrap samples
  %   seed         random seed
  %
  % Output:
  %   C            comparison structure

  validate_graph_summary(GS_x);
  validate_graph_summary(GS_y);

  assert(ischar(metric_name), ...
    'metric_name must be a character string.');

  assert(isfield(GS_x, metric_name), ...
    ['Metric not found in first summary: ', metric_name]);

  assert(isfield(GS_y, metric_name), ...
    ['Metric not found in second summary: ', metric_name]);

  [common_ids, idx_x, idx_y] = intersect( ...
    GS_x.graph_id(:), GS_y.graph_id(:));

  assert(~isempty(common_ids), ...
    'The two summaries have no common graph identifiers.');

  assert(length(common_ids) == length(GS_x.graph_id), ...
    'Not all first-summary graphs have paired observations.');

  assert(length(common_ids) == length(GS_y.graph_id), ...
    'Not all second-summary graphs have paired observations.');

  x = GS_x.(metric_name);
  y = GS_y.(metric_name);

  x = x(idx_x);
  y = y(idx_y);

  assert(all(~isnan(x)), ...
    ['First architecture contains NaN values for ', metric_name]);

  assert(all(~isnan(y)), ...
    ['Second architecture contains NaN values for ', metric_name]);

  B = paired_bootstrap_difference(x, y, n_boot, seed);

  C.architecture_x = GS_x.architecture;
  C.architecture_y = GS_y.architecture;
  C.metric = metric_name;

  C.n_pairs = B.n_pairs;
  C.mean_x = B.mean_x;
  C.mean_y = B.mean_y;

  C.mean_difference = B.mean_difference;
  C.median_difference = B.median_difference;
  C.relative_reduction = B.relative_reduction;

  C.ci_lower = B.ci_lower;
  C.ci_upper = B.ci_upper;

  C.n_x_greater = B.n_positive;
  C.n_x_lower = B.n_negative;
  C.n_equal = B.n_equal;

  C.fraction_y_lower = B.n_positive / B.n_pairs;

  C.min_difference = B.min_difference;
  C.max_difference = B.max_difference;

  C.graph_ids = common_ids;
end


function validate_graph_summary(GS)
  assert(isstruct(GS), 'Graph summary must be a structure.');

  assert(isfield(GS, 'architecture'), ...
    'Graph summary must contain architecture.');

  assert(isfield(GS, 'graph_id'), ...
    'Graph summary must contain graph_id.');

  assert(length(unique(GS.graph_id)) == length(GS.graph_id), ...
    'Graph identifiers must be unique.');
end
