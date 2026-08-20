function mini_heatmap = run_mini_heatmap_production(config)
  % RUN_MINI_HEATMAP_PRODUCTION
  % Runs a compact translation-by-workload grid for manuscript visualization.
  %
  % Purpose:
  %   Build a small RMST surface showing how readiness delay changes jointly
  %   with boundary-spanner translation capability and per-spanner workload.
  %
  % Default production design:
  %   - architecture = boundary_spanning
  %   - selection rule = agent_first
  %   - pi_out fixed at 0.55
  %   - pi_BS grid = [0.55, 0.60, 0.70]
  %   - b grid = [1, 2, 6]
  %   - k = 12 cross-boundary ties
  %   - NG = 50 graph realizations
  %   - NT = 50 trajectories per graph
  %   - T_max = 50000
  %   - no bootstrap by default; this is a visual synthesis grid
  %
  % Usage:
  %   mini_heatmap = run_mini_heatmap_production()
  %
  % Test/small-run usage:
  %   config = struct();
  %   config.run_type = 'mini_heatmap_test';
  %   config.output_tag = 'mini_heatmap_test';
  %   config.NG = 2;
  %   config.NT = 2;
  %   config.T_max = 2000;
  %   config.pi_BS_grid = [0.55, 0.70];
  %   config.b_grid = [1, 2];
  %   mini_heatmap = run_mini_heatmap_production(config);
  %
  % Outputs are written under:
  %   results/raw/rerun_v2/<output_tag>/
  %   results/processed/rerun_v2/<output_tag>/

  if nargin < 1
    config = struct();
  end

  config = fill_mini_heatmap_config(config);

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  raw_dir = fullfile(repo_root, 'results', 'raw', 'rerun_v2', config.output_tag);
  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', config.output_tag);

  ensure_dir(raw_dir);
  ensure_dir(processed_dir);

  timestamp = datestr(now, 'yyyymmdd_HHMMSS');
  wall_clock_tic = tic();

  P_base = baseline_params();
  P_base.T_max = config.T_max;
  P_base.theta = config.theta;
  P_base.q = config.q;
  P_base.pi_out = config.pi_out;

  conditions = define_mini_heatmap_conditions(P_base, config);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 MINI HEATMAP PRODUCTION\n');
  fprintf('============================================\n');
  fprintf('run_type: %s | output_tag: %s\n', config.run_type, config.output_tag);
  fprintf('NG: %d | NT: %d | T_max: %d\n', config.NG, config.NT, config.T_max);
  fprintf('theta: %.2f | q: %.2f | pi_out: %.2f\n', ...
    config.theta, config.q, config.pi_out);
  fprintf('pi_BS grid: ');
  fprintf('%.2f ', config.pi_BS_grid);
  fprintf('\n');
  fprintf('b grid: ');
  fprintf('%d ', config.b_grid);
  fprintf('\n');
  fprintf('seed_base: %d\n', config.seed_base);

  if strcmp(config.run_type, 'mini_heatmap')
    fprintf('\nThis is the mini heatmap production run. It may take several hours.\n');
  else
    fprintf('\nThis is a non-final/test run using the mini heatmap pipeline.\n');
  end

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCell %d/%d: %s | pi_BS %.2f | b %d | load %.2f\n', ...
      c, length(conditions), C.condition_id, C.P.pi_BS, C.P.b, C.load_per_spanner);

    condition_tic = tic();
    R = run_mini_heatmap_condition(C.P, C.condition_id, config.NG, config.NT, config.seed_base);
    condition_elapsed = toc(condition_tic);

    S = compute_event_time_estimands(R);

    results.(C.condition_id) = R;
    estimands.(C.condition_id) = S;

    fprintf('%s readiness probability: %.3f | censoring: %.3f | RMST: %.2f', ...
      C.condition_id, S.readiness_probability, S.censoring_probability, S.RMST);
    fprintf(' | T50: ');
    print_estimable_value(S.T50, S.T50_estimable);
    fprintf(' | T90: ');
    print_estimable_value(S.T90, S.T90_estimable);
    fprintf(' | T95: ');
    print_estimable_value(S.T95, S.T95_estimable);
    fprintf(' | elapsed %.1fs\n', condition_elapsed);
  end

  diagnostic = compute_mini_heatmap_diagnostics(conditions, estimands);
  alerts = diagnostic.alerts;

  elapsed_seconds = toc(wall_clock_tic);

  mini_heatmap = struct();
  mini_heatmap.run_type = config.run_type;
  mini_heatmap.output_tag = config.output_tag;
  mini_heatmap.timestamp = timestamp;
  mini_heatmap.NG = config.NG;
  mini_heatmap.NT = config.NT;
  mini_heatmap.T_max = config.T_max;
  mini_heatmap.seed_base = config.seed_base;
  mini_heatmap.theta = config.theta;
  mini_heatmap.q = config.q;
  mini_heatmap.pi_out = config.pi_out;
  mini_heatmap.pi_BS_grid = config.pi_BS_grid;
  mini_heatmap.b_grid = config.b_grid;
  mini_heatmap.conditions = conditions;
  mini_heatmap.results = results;
  mini_heatmap.estimands = estimands;
  mini_heatmap.diagnostic = diagnostic;
  mini_heatmap.alerts = alerts(:);
  mini_heatmap.n_alerts = length(alerts);
  mini_heatmap.elapsed_seconds = elapsed_seconds;

  raw_file = fullfile(raw_dir, ['mini_heatmap_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['mini_heatmap_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['mini_heatmap_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'P_base', 'config');
  save(processed_file, 'mini_heatmap', 'estimands', 'config');

  write_mini_heatmap_manifest(manifest_file, mini_heatmap, raw_file, processed_file);

  mini_heatmap.raw_file = raw_file;
  mini_heatmap.processed_file = processed_file;
  mini_heatmap.manifest_file = manifest_file;

  fprintf('\nMini heatmap raw file:\n%s\n', raw_file);
  fprintf('\nMini heatmap processed file:\n%s\n', processed_file);
  fprintf('\nMini heatmap manifest file:\n%s\n', manifest_file);

  fprintf('\nMini heatmap diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No mini heatmap diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  fprintf('\nElapsed wall-clock time: %.1f seconds\n', elapsed_seconds);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 MINI HEATMAP PRODUCTION PASSED\n');
  fprintf('============================================\n');
end


function config = fill_mini_heatmap_config(config)
  if ~isfield(config, 'run_type')
    config.run_type = 'mini_heatmap';
  end

  if ~isfield(config, 'output_tag')
    config.output_tag = config.run_type;
  end

  if ~isfield(config, 'NG')
    config.NG = 50;
  end

  if ~isfield(config, 'NT')
    config.NT = 50;
  end

  if ~isfield(config, 'T_max')
    config.T_max = 50000;
  end

  if ~isfield(config, 'theta')
    config.theta = 0.80;
  end

  if ~isfield(config, 'q')
    config.q = 0.80;
  end

  if ~isfield(config, 'pi_out')
    config.pi_out = 0.55;
  end

  if ~isfield(config, 'pi_BS_grid')
    config.pi_BS_grid = [0.55, 0.60, 0.70];
  end

  if ~isfield(config, 'b_grid')
    config.b_grid = [1, 2, 6];
  end

  if ~isfield(config, 'seed_base')
    config.seed_base = 1401000;
  end

  assert(config.NG > 0, 'NG must be positive.');
  assert(config.NT > 0, 'NT must be positive.');
  assert(config.T_max > 0, 'T_max must be positive.');
  assert(length(config.pi_BS_grid) >= 2, 'pi_BS_grid must contain at least two values.');
  assert(length(config.b_grid) >= 2, 'b_grid must contain at least two values.');
  assert(all(diff(config.pi_BS_grid) > 0), 'pi_BS_grid must be strictly increasing.');
  assert(all(diff(config.b_grid) > 0), 'b_grid must be strictly increasing.');
end


function conditions = define_mini_heatmap_conditions(P_base, config)
  conditions = [];

  for b_idx = 1:length(config.b_grid)
    for p_idx = 1:length(config.pi_BS_grid)
      b_value = config.b_grid(b_idx);
      pi_value = config.pi_BS_grid(p_idx);

      C = struct();
      C.condition_id = condition_id_from_pi_b(pi_value, b_value);
      C.architecture = 'boundary_spanning';
      C.selection_rule = 'agent_first';
      C.P = P_base;
      C.P.b = b_value;
      C.P.pi_BS = pi_value;
      C.P.pi_out = config.pi_out;
      C.load_per_spanner = C.P.k / (2 * C.P.b);
      C.pi_BS_index = p_idx;
      C.b_index = b_idx;

      if isempty(conditions)
        conditions = C;
      else
        conditions(end + 1) = C;
      end
    end
  end
end


function condition_id = condition_id_from_pi_b(pi_value, b_value)
  pi_code = strrep(sprintf('%.2f', pi_value), '.', '');
  condition_id = sprintf('HM_pi_%s_b_%02d', pi_code, b_value);
end


function R = run_mini_heatmap_condition(P, condition_id, NG, NT, seed_base)
  n = NG * NT;

  R.graph_id = zeros(n, 1);
  R.trajectory_id = zeros(n, 1);
  R.network_seed = zeros(n, 1);
  R.trajectory_seed = zeros(n, 1);

  R.T = NaN(n, 1);
  R.T_tilde = NaN(n, 1);
  R.delta = NaN(n, 1);
  R.converged = NaN(n, 1);
  R.final_RB = NaN(n, 1);
  R.final_ready = NaN(n, 1);
  R.total_boundary_edges = NaN(n, 1);

  R.pi_BS = P.pi_BS * ones(n, 1);
  R.pi_out = P.pi_out * ones(n, 1);
  R.b = P.b * ones(n, 1);
  R.load_per_spanner = (P.k / (2 * P.b)) * ones(n, 1);
  R.theta = P.theta * ones(n, 1);
  R.q = P.q * ones(n, 1);
  R.T_max = P.T_max * ones(n, 1);

  R.workload_mean = NaN(n, 1);
  R.workload_min = NaN(n, 1);
  R.workload_max = NaN(n, 1);
  R.workload_sd = NaN(n, 1);

  R.condition_id = condition_id;
  R.architecture = 'boundary_spanning';
  R.selection_rule = 'agent_first';

  row = 0;

  for g = 1:NG
    network_seed = seed_base + 1000 * round(100 * P.pi_BS) + 100 * P.b + g;

    rand('seed', network_seed);
    G = generate_network(P, 'boundary_spanning');

    for tr = 1:NT
      row = row + 1;

      trajectory_seed = seed_base + 100000 * g + 1000 * round(100 * P.pi_BS) + 100 * P.b + tr;
      rand('seed', trajectory_seed);

      out = run_dynamics_fast(G, P, false);

      R.graph_id(row) = g;
      R.trajectory_id(row) = tr;
      R.network_seed(row) = network_seed;
      R.trajectory_seed(row) = trajectory_seed;

      R.T(row) = out.T;
      R.T_tilde(row) = out.T_tilde;
      R.delta(row) = out.delta;
      R.converged(row) = out.converged;
      R.final_RB(row) = out.final_RB;
      R.final_ready(row) = out.final_ready;
      R.total_boundary_edges(row) = out.total_boundary_edges;

      R.workload_mean(row) = G.BS_workload_mean;
      R.workload_min(row) = G.BS_workload_min;
      R.workload_max(row) = G.BS_workload_max;
      R.workload_sd(row) = G.BS_workload_sd;
    end
  end

  assert(row == n, 'Internal row counter mismatch.');
  validate_mini_heatmap_condition_results(R, n);
end


function validate_mini_heatmap_condition_results(R, n)
  assert(length(R.graph_id) == n, 'graph_id length mismatch.');
  assert(length(R.trajectory_id) == n, 'trajectory_id length mismatch.');
  assert(length(R.T_tilde) == n, 'T_tilde length mismatch.');
  assert(length(R.delta) == n, 'delta length mismatch.');
  assert(all(~isnan(R.T_tilde)), 'T_tilde cannot contain NaN.');
  assert(all(R.delta == 0 | R.delta == 1), 'delta must contain only 0 or 1.');
  assert(all(R.converged == R.delta), 'converged must equal delta.');

  event_idx = find(R.delta == 1);
  cens_idx = find(R.delta == 0);

  assert(all(~isnan(R.T(event_idx))), 'Event trajectories must have observed T.');
  assert(all(R.T(event_idx) == R.T_tilde(event_idx)), ...
    'For events, T must equal T_tilde.');
  assert(all(isnan(R.T(cens_idx))), 'Censored trajectories must have T = NaN.');
  assert(all(R.T_tilde(cens_idx) == R.T_max(cens_idx)), ...
    'For censoring, T_tilde must equal T_max.');
end


function diagnostic = compute_mini_heatmap_diagnostics(conditions, estimands)
  pi_values = unique_numeric([conditions.pi_BS_index], [conditions.P]);
  b_values = unique([conditions.b_index]);

  n_b = length(b_values);
  n_pi = length(pi_values);
  RMST_matrix = NaN(n_b, n_pi);
  T95_matrix = NaN(n_b, n_pi);
  readiness_matrix = NaN(n_b, n_pi);

  for i = 1:length(conditions)
    C = conditions(i);
    S = estimands.(C.condition_id);
    RMST_matrix(C.b_index, C.pi_BS_index) = S.RMST;
    T95_matrix(C.b_index, C.pi_BS_index) = S.T95;
    readiness_matrix(C.b_index, C.pi_BS_index) = S.readiness_probability;
  end

  translation_monotone_by_b = ones(n_b, 1);
  workload_monotone_by_pi = ones(n_pi, 1);

  for b_idx = 1:n_b
    row = RMST_matrix(b_idx, :);
    if any(diff(row) > 0)
      translation_monotone_by_b(b_idx) = 0;
    end
  end

  for p_idx = 1:n_pi
    col = RMST_matrix(:, p_idx);
    if any(diff(col) > 0)
      workload_monotone_by_pi(p_idx) = 0;
    end
  end

  alerts = {};

  for i = 1:length(conditions)
    C = conditions(i);
    S = estimands.(C.condition_id);

    if S.readiness_probability < 0.95
      alerts{end + 1} = ['LOW_READINESS_PROBABILITY: ', C.condition_id];
    end
    if S.T50_estimable == 0
      alerts{end + 1} = ['T50_NOT_ESTIMABLE: ', C.condition_id];
    end
    if S.T90_estimable == 0
      alerts{end + 1} = ['T90_NOT_ESTIMABLE: ', C.condition_id];
    end
    if S.T95_estimable == 0
      alerts{end + 1} = ['T95_NOT_ESTIMABLE: ', C.condition_id];
    end
  end

  if any(translation_monotone_by_b == 0)
    alerts{end + 1} = 'RMST_NOT_MONOTONIC_DECREASING_IN_PI_FOR_AT_LEAST_ONE_B';
  end

  if any(workload_monotone_by_pi == 0)
    alerts{end + 1} = 'RMST_NOT_MONOTONIC_DECREASING_IN_B_FOR_AT_LEAST_ONE_PI';
  end

  diagnostic = struct();
  diagnostic.RMST_matrix = RMST_matrix;
  diagnostic.T95_matrix = T95_matrix;
  diagnostic.readiness_matrix = readiness_matrix;
  diagnostic.translation_monotone_by_b = translation_monotone_by_b;
  diagnostic.workload_monotone_by_pi = workload_monotone_by_pi;
  diagnostic.translation_monotone_all_b = all(translation_monotone_by_b == 1);
  diagnostic.workload_monotone_all_pi = all(workload_monotone_by_pi == 1);
  diagnostic.alerts = alerts(:);
  diagnostic.n_alerts = length(alerts);
end


function values = unique_numeric(~, P_structs)
  values = [];
  for i = 1:length(P_structs)
    if isfield(P_structs(i), 'pi_BS')
      values(end + 1) = P_structs(i).pi_BS;
    end
  end
  values = unique(values);
end


function print_estimable_value(value, flag)
  if flag == 1
    fprintf('%.2f', value);
  else
    fprintf('not estimable');
  end
end


function write_mini_heatmap_manifest(manifest_file, mini_heatmap, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open mini heatmap manifest file for writing.');

  fprintf(fid, 'RERUN V2 MINI HEATMAP MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', mini_heatmap.timestamp);
  fprintf(fid, 'run_type: %s\n', mini_heatmap.run_type);
  fprintf(fid, 'output_tag: %s\n', mini_heatmap.output_tag);
  fprintf(fid, 'NG: %d\n', mini_heatmap.NG);
  fprintf(fid, 'NT: %d\n', mini_heatmap.NT);
  fprintf(fid, 'T_max: %d\n', mini_heatmap.T_max);
  fprintf(fid, 'theta: %.6f\n', mini_heatmap.theta);
  fprintf(fid, 'q: %.6f\n', mini_heatmap.q);
  fprintf(fid, 'pi_out: %.6f\n', mini_heatmap.pi_out);
  fprintf(fid, 'seed_base: %d\n', mini_heatmap.seed_base);
  fprintf(fid, 'elapsed_seconds: %.6f\n', mini_heatmap.elapsed_seconds);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  condition_names = fieldnames(mini_heatmap.estimands);
  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = mini_heatmap.estimands.(cname);
    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fprintf(fid, '\ntranslation_monotone_all_b: %d\n', mini_heatmap.diagnostic.translation_monotone_all_b);
  fprintf(fid, 'workload_monotone_all_pi: %d\n', mini_heatmap.diagnostic.workload_monotone_all_pi);
  fprintf(fid, 'alerts: %d\n', mini_heatmap.n_alerts);
  for i = 1:length(mini_heatmap.alerts)
    fprintf(fid, '  - %s\n', mini_heatmap.alerts{i});
  end

  fclose(fid);
end
