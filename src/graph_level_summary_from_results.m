function S = graph_level_summary_from_results(results)
  % GRAPH_LEVEL_SUMMARY_FROM_RESULTS
  % Computes graph-level summaries from trajectory-level simulation results.
  %
  % Uses censored first-passage time:
  % non-converged or missing T values are treated as T_max = 50000.

  censor_value = 50000;

  graph_ids = unique(results.graph_id);
  n_graphs = length(graph_ids);

  graph_mean = NaN(n_graphs, 1);
  graph_median = NaN(n_graphs, 1);
  graph_p90 = NaN(n_graphs, 1);
  graph_p95 = NaN(n_graphs, 1);
  graph_max = NaN(n_graphs, 1);
  graph_conv = NaN(n_graphs, 1);

  graph_total_edges = NaN(n_graphs, 1);
  graph_mean_degree = NaN(n_graphs, 1);
  graph_max_degree = NaN(n_graphs, 1);
  graph_boundary_edges = NaN(n_graphs, 1);

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

    graph_mean(i) = mean(T_cens);
    graph_median(i) = median(T_cens);
    graph_p90(i) = prctile(T_cens, 90);
    graph_p95(i) = prctile(T_cens, 95);
    graph_max(i) = max(T_cens);

    graph_conv(i) = mean(conv);

    if isfield(results, 'total_edges')
      graph_total_edges(i) = mean(results.total_edges(idx));
    end

    if isfield(results, 'mean_degree')
      graph_mean_degree(i) = mean(results.mean_degree(idx));
    end

    if isfield(results, 'max_degree')
      graph_max_degree(i) = mean(results.max_degree(idx));
    end

    if isfield(results, 'total_boundary_edges')
      graph_boundary_edges(i) = mean(results.total_boundary_edges(idx));
    end
  end

  S.n_graphs = n_graphs;
  S.n_trajectories = length(results.T);

  S.convergence_rate = mean(graph_conv);

  S.mean_T = mean(graph_mean);
  S.median_T = mean(graph_median);
  S.p90_T = mean(graph_p90);
  S.p95_T = mean(graph_p95);
  S.max_T = mean(graph_max);

  S.total_edges = mean(graph_total_edges);
  S.mean_degree = mean(graph_mean_degree);
  S.max_degree = mean(graph_max_degree);
  S.boundary_edges = mean(graph_boundary_edges);
end
