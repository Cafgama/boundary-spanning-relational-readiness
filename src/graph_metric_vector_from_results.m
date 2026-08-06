function v = graph_metric_vector_from_results(results, metric_name)
  % GRAPH_METRIC_VECTOR_FROM_RESULTS
  % Returns one graph-level metric vector from trajectory-level results.
  %
  % Uses censored first-passage time:
  % non-converged or missing T values are treated as T_max = 50000.

  censor_value = 50000;

  graph_ids = unique(results.graph_id);
  n_graphs = length(graph_ids);

  v = NaN(n_graphs, 1);

  for i = 1:n_graphs

    g = graph_ids(i);
    idx = find(results.graph_id == g);

    T = results.T(idx);

    if isfield(results, 'converged')
      conv = results.converged(idx);
    else
      conv = ones(length(T), 1);
    end

    T_cens = T;
    bad_idx = find(isnan(T_cens) | conv == 0);
    T_cens(bad_idx) = censor_value;

    if strcmp(metric_name, 'mean_T')
      v(i) = mean(T_cens);

    elseif strcmp(metric_name, 'median_T')
      v(i) = median(T_cens);

    elseif strcmp(metric_name, 'p90_T')
      v(i) = prctile(T_cens, 90);

    elseif strcmp(metric_name, 'p95_T')
      v(i) = prctile(T_cens, 95);

    elseif strcmp(metric_name, 'max_T')
      v(i) = max(T_cens);

    elseif strcmp(metric_name, 'convergence_rate')
      v(i) = mean(conv);

    else
      error(['Unknown metric name: ', metric_name]);
    end
  end
end
