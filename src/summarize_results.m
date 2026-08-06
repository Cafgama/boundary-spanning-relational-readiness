function S = summarize_results(results, P)
  % SUMMARIZE_RESULTS
  % Summarizes first-passage simulation results for one architecture.
  %
  % Inputs:
  %   results  structure returned by run_single_experiment()
  %   P        parameter structure from baseline_params()
  %
  % Output:
  %   S        summary structure with convergence, first-passage,
  %            censored-time, and graph-level metrics.
  %
  % Important:
  %   Non-converged trajectories have T = NaN in the raw results.
  %   This function reports two families of time statistics:
  %
  %   1. Converged-only statistics:
  %      calculated only among trajectories that reached readiness.
  %
  %   2. Censored statistics:
  %      non-converged trajectories are assigned T_max.
  %
  %   Both are useful. Converged-only statistics show the timing among
  %   successful trajectories. Censored statistics penalize architectures
  %   with many non-converged runs.

  validate_inputs(results, P);

  T = results.T;
  converged = results.converged;

  n_runs = length(T);
  n_converged = sum(converged == 1);
  n_nonconverged = sum(converged == 0);

  convergence_rate = n_converged / n_runs;
  nonconvergence_rate = n_nonconverged / n_runs;

  % -----------------------------
  % Converged-only time statistics
  % -----------------------------
  T_conv = T(converged == 1);

  stats_conv = compute_time_stats(T_conv);

  % -----------------------------
  % Censored time statistics
  % -----------------------------
  % Non-converged trajectories are assigned T_max.
  T_cens = T;

  for i = 1:length(T_cens)
    if isnan(T_cens(i))
      T_cens(i) = P.T_max;
    end
  end

  stats_cens = compute_time_stats(T_cens);

  % -----------------------------
  % Graph-level statistics
  % -----------------------------
  total_edges_stats = compute_time_stats(results.total_edges);
  mean_degree_stats = compute_time_stats(results.mean_degree);
  max_degree_stats = compute_time_stats(results.max_degree);
  boundary_edges_stats = compute_time_stats(results.total_boundary_edges);

  % -----------------------------
  % Package summary
  % -----------------------------
  S.architecture = results.architecture;
  S.seed = results.seed;

  S.NG = results.NG;
  S.NT = results.NT;
  S.n_runs = n_runs;

  S.n_converged = n_converged;
  S.n_nonconverged = n_nonconverged;
  S.convergence_rate = convergence_rate;
  S.nonconvergence_rate = nonconvergence_rate;

  % Converged-only statistics
  S.T_conv_mean = stats_conv.mean;
  S.T_conv_median = stats_conv.median;
  S.T_conv_p75 = stats_conv.p75;
  S.T_conv_p90 = stats_conv.p90;
  S.T_conv_p95 = stats_conv.p95;
  S.T_conv_min = stats_conv.min;
  S.T_conv_max = stats_conv.max;

  % Censored statistics
  S.T_cens_mean = stats_cens.mean;
  S.T_cens_median = stats_cens.median;
  S.T_cens_p75 = stats_cens.p75;
  S.T_cens_p90 = stats_cens.p90;
  S.T_cens_p95 = stats_cens.p95;
  S.T_cens_min = stats_cens.min;
  S.T_cens_max = stats_cens.max;

  % Final readiness
  S.final_RB_mean = mean(results.final_RB);
  S.final_RB_median = local_percentile(results.final_RB, 50);
  S.final_RB_min = min(results.final_RB);
  S.final_RB_max = max(results.final_RB);

  % Network statistics
  S.total_edges_mean = total_edges_stats.mean;
  S.total_edges_median = total_edges_stats.median;

  S.mean_degree_mean = mean_degree_stats.mean;
  S.mean_degree_median = mean_degree_stats.median;

  S.max_degree_mean = max_degree_stats.mean;
  S.max_degree_median = max_degree_stats.median;

  S.boundary_edges_mean = boundary_edges_stats.mean;
  S.boundary_edges_median = boundary_edges_stats.median;
end


function stats = compute_time_stats(x)
  % COMPUTE_TIME_STATS
  % Computes basic descriptive statistics for a numeric vector.
  % Ignores NaN values.
  %
  % If all values are NaN or vector is empty, returns NaN statistics.

  x = x(:);
  x = x(!isnan(x));

  if isempty(x)
    stats.mean = NaN;
    stats.median = NaN;
    stats.p75 = NaN;
    stats.p90 = NaN;
    stats.p95 = NaN;
    stats.min = NaN;
    stats.max = NaN;
    return;
  end

  stats.mean = mean(x);
  stats.median = local_percentile(x, 50);
  stats.p75 = local_percentile(x, 75);
  stats.p90 = local_percentile(x, 90);
  stats.p95 = local_percentile(x, 95);
  stats.min = min(x);
  stats.max = max(x);
end


function p = local_percentile(x, pct)
  % LOCAL_PERCENTILE
  % Computes percentile using linear interpolation.
  %
  % This avoids dependence on the Octave statistics package.

  x = x(:);
  x = x(!isnan(x));

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

  pos = 1 + (pct / 100) * (n - 1);
  lower_idx = floor(pos);
  upper_idx = ceil(pos);

  if lower_idx == upper_idx
    p = x(lower_idx);
  else
    weight = pos - lower_idx;
    p = x(lower_idx) * (1 - weight) + x(upper_idx) * weight;
  end
end


function validate_inputs(results, P)
  % VALIDATE_INPUTS
  % Basic checks for results and parameter structures.

  assert(isstruct(results), 'results must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  required_fields = {
    'architecture',
    'NG',
    'NT',
    'seed',
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
      ['results is missing required field: ', field_name]);
  end

  assert(isfield(P, 'T_max'), 'P must contain T_max.');

  n = length(results.T);

  assert(length(results.converged) == n, ...
    'converged must have same length as T.');

  assert(length(results.final_RB) == n, ...
    'final_RB must have same length as T.');

  assert(length(results.total_edges) == n, ...
    'total_edges must have same length as T.');

  assert(length(results.mean_degree) == n, ...
    'mean_degree must have same length as T.');

  assert(length(results.max_degree) == n, ...
    'max_degree must have same length as T.');

  assert(length(results.total_boundary_edges) == n, ...
    'total_boundary_edges must have same length as T.');

  assert(all(results.converged == 0 | results.converged == 1), ...
    'converged must contain only 0 or 1.');

  assert(all(results.final_RB >= 0 & results.final_RB <= 1), ...
    'final_RB must be in [0,1].');

  assert(P.T_max > 0 && P.T_max == floor(P.T_max), ...
    'P.T_max must be a positive integer.');
end
