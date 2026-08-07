function translation_grid = run_translation_grid_production(config)
  % RUN_TRANSLATION_GRID_PRODUCTION
  % Runs the rerun_v2 translation-capability grid.
  %
  % Purpose:
  %   Test whether readiness delay decreases monotonically as boundary-spanning
  %   translation capability increases.
  %
  % Default production design:
  %   - architecture = boundary_spanning
  %   - pi_out fixed at 0.55
  %   - pi_BS grid = [0.55, 0.60, 0.65, 0.70]
  %   - NG = 50 graph realizations
  %   - NT = 50 trajectories per graph
  %   - T_max = 50000
  %   - n_boot = 10000
  %
  % Usage:
  %   translation_grid = run_translation_grid_production()
  %
  % Test/small-run usage:
  %   config = struct();
  %   config.run_type = 'translation_grid_test';
  %   config.output_tag = 'translation_grid_test';
  %   config.NG = 2;
  %   config.NT = 3;
  %   config.T_max = 2000;
  %   config.n_boot = 20;
  %   translation_grid = run_translation_grid_production(config);
  %
  % Outputs are written only under:
  %   results/raw/rerun_v2/<output_tag>/
  %   results/processed/rerun_v2/<output_tag>/

  if nargin < 1
    config = struct();
  end

  config = fill_translation_grid_config(config);

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

  conditions = define_translation_grid_conditions(P_base, config);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 TRANSLATION-GRID PRODUCTION\n');
  fprintf('============================================\n');
  fprintf('run_type: %s | output_tag: %s\n', config.run_type, config.output_tag);
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    config.NG, config.NT, config.T_max, config.n_boot);
  fprintf('theta: %.2f | q: %.2f | pi_out: %.2f\n', ...
    config.theta, config.q, config.pi_out);
  fprintf('pi_BS grid: ');
  fprintf('%.2f ', config.pi_BS_grid);
  fprintf('\n');
  fprintf('seed_base: %d | bootstrap_seed: %d\n', ...
    config.seed_base, config.bootstrap_seed);

  if strcmp(config.run_type, 'translation_grid')
    fprintf('\nThis is the final translation-grid production run. It may take a long time.\n');
  else
    fprintf('\nThis is a non-final/test run using the translation-grid pipeline.\n');
  end

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCondition: %s | architecture: %s | pi_out: %.2f | pi_BS: %.2f\n', ...
      C.condition_id, C.architecture, C.P.pi_out, C.P.pi_BS);

    condition_tic = tic();
    R = run_translation_grid_condition(C.P, C.condition_id, C.architecture, ...
      config.NG, config.NT, config.seed_base);
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

  fprintf('\nRunning hierarchical paired bootstraps for adjacent grid contrasts...\n');

  bootstrap_tic = tic();
  bootstraps = struct();

  for c = 1:(length(conditions) - 1)
    Cx = conditions(c);
    Cy = conditions(c + 1);
    contrast_id = [Cx.condition_id, '_minus_', Cy.condition_id];

    bootstraps.(contrast_id) = hierarchical_paired_bootstrap(
      results.(Cx.condition_id), results.(Cy.condition_id), ...
      config.n_boot, config.bootstrap_seed + c);
  end

  first_condition = conditions(1);
  for c = 2:length(conditions)
    Cy = conditions(c);
    contrast_id = [first_condition.condition_id, '_minus_', Cy.condition_id];

    if ~isfield(bootstraps, contrast_id)
      bootstraps.(contrast_id) = hierarchical_paired_bootstrap(
        results.(first_condition.condition_id), results.(Cy.condition_id), ...
        config.n_boot, config.bootstrap_seed + 100 + c);
    end
  end

  bootstrap_elapsed = toc(bootstrap_tic);

  bootstrap_names = fieldnames(bootstraps);
  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    print_bootstrap_summary(bname, bootstraps.(bname));
  end

  alerts = collect_translation_grid_alerts(conditions, estimands, bootstraps);

  fprintf('\nTranslation-grid diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No translation-grid diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  elapsed_seconds = toc(wall_clock_tic);

  translation_grid = struct();
  translation_grid.run_type = config.run_type;
  translation_grid.output_tag = config.output_tag;
  translation_grid.timestamp = timestamp;
  translation_grid.NG = config.NG;
  translation_grid.NT = config.NT;
  translation_grid.T_max = config.T_max;
  translation_grid.n_boot = config.n_boot;
  translation_grid.seed_base = config.seed_base;
  translation_grid.bootstrap_seed = config.bootstrap_seed;
  translation_grid.theta = config.theta;
  translation_grid.q = config.q;
  translation_grid.pi_out = config.pi_out;
  translation_grid.pi_BS_grid = config.pi_BS_grid;
  translation_grid.conditions = conditions;
  translation_grid.results = results;
  translation_grid.estimands = estimands;
  translation_grid.bootstraps = bootstraps;
  translation_grid.alerts = alerts(:);
  translation_grid.n_alerts = length(alerts);
  translation_grid.elapsed_seconds = elapsed_seconds;
  translation_grid.bootstrap_elapsed_seconds = bootstrap_elapsed;

  raw_file = fullfile(raw_dir, ['translation_grid_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['translation_grid_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['translation_grid_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'P_base', 'config');

  save(processed_file, 'translation_grid', 'estimands', 'bootstraps', 'config');

  write_translation_grid_manifest(manifest_file, translation_grid, raw_file, processed_file);

  translation_grid.raw_file = raw_file;
  translation_grid.processed_file = processed_file;
  translation_grid.manifest_file = manifest_file;

  fprintf('\nTranslation-grid raw file:\n%s\n', raw_file);
  fprintf('\nTranslation-grid processed file:\n%s\n', processed_file);
  fprintf('\nTranslation-grid manifest file:\n%s\n', manifest_file);

  fprintf('\nElapsed wall-clock time: %.1f seconds\n', elapsed_seconds);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 TRANSLATION-GRID PRODUCTION PASSED\n');
  fprintf('============================================\n');
end


function config = fill_translation_grid_config(config)
  if ~isfield(config, 'run_type')
    config.run_type = 'translation_grid';
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

  if ~isfield(config, 'n_boot')
    config.n_boot = 10000;
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
    config.pi_BS_grid = [0.55, 0.60, 0.65, 0.70];
  end

  if ~isfield(config, 'seed_base')
    config.seed_base = 606000;
  end

  if ~isfield(config, 'bootstrap_seed')
    config.bootstrap_seed = 707000;
  end

  assert(config.NG > 0, 'NG must be positive.');
  assert(config.NT > 0, 'NT must be positive.');
  assert(config.T_max > 0, 'T_max must be positive.');
  assert(config.n_boot > 0, 'n_boot must be positive.');
  assert(length(config.pi_BS_grid) >= 2, 'pi_BS_grid must contain at least two values.');
  assert(all(diff(config.pi_BS_grid) > 0), 'pi_BS_grid must be strictly increasing.');
end


function conditions = define_translation_grid_conditions(P_base, config)
  conditions = [];

  for i = 1:length(config.pi_BS_grid)
    C = struct();
    C.condition_id = condition_id_from_pi(config.pi_BS_grid(i));
    C.architecture = 'boundary_spanning';
    C.P = P_base;
    C.P.pi_out = config.pi_out;
    C.P.pi_BS = config.pi_BS_grid(i);

    if isempty(conditions)
      conditions = C;
    else
      conditions(end + 1) = C;
    end
  end
end


function condition_id = condition_id_from_pi(pi_value)
  code = round(pi_value * 100);
  condition_id = sprintf('BS_pi_%03d', code);
end


function R = run_translation_grid_condition(P, condition_id, architecture, NG, NT, seed_base)
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
  R.theta = P.theta * ones(n, 1);
  R.q = P.q * ones(n, 1);
  R.T_max = P.T_max * ones(n, 1);

  R.workload_mean = NaN(n, 1);
  R.workload_min = NaN(n, 1);
  R.workload_max = NaN(n, 1);
  R.workload_sd = NaN(n, 1);

  R.condition_id = condition_id;
  R.architecture = architecture;
  R.selection_rule = 'agent_first';

  row = 0;

  for g = 1:NG
    network_seed = seed_base + g;

    rand('seed', network_seed);
    G = safe_generate_network(P, architecture);

    for tr = 1:NT
      row = row + 1;

      trajectory_seed = seed_base + 100000 * g + tr;
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
  validate_translation_grid_condition_results(R, n);
end


function validate_translation_grid_condition_results(R, n)
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


function alerts = collect_translation_grid_alerts(conditions, estimands, bootstraps)
  alerts = {};

  rmst_values = zeros(length(conditions), 1);
  t95_values = zeros(length(conditions), 1);

  for i = 1:length(conditions)
    cname = conditions(i).condition_id;
    S = estimands.(cname);

    rmst_values(i) = S.RMST;
    t95_values(i) = S.T95;

    if S.readiness_probability < 0.95
      alerts{end + 1} = ['LOW_READINESS_PROBABILITY: ', cname];
    end

    if S.T50_estimable == 0
      alerts{end + 1} = ['T50_NOT_ESTIMABLE: ', cname];
    end

    if S.T90_estimable == 0
      alerts{end + 1} = ['T90_NOT_ESTIMABLE: ', cname];
    end

    if S.T95_estimable == 0
      alerts{end + 1} = ['T95_NOT_ESTIMABLE: ', cname];
    end
  end

  if any(diff(rmst_values) > 0)
    alerts{end + 1} = 'RMST_NOT_MONOTONIC_DECREASING_IN_PI_BS';
  end

  if any(diff(t95_values) > 0)
    alerts{end + 1} = 'T95_NOT_MONOTONIC_DECREASING_IN_PI_BS';
  end

  bootstrap_names = fieldnames(bootstraps);
  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    B = bootstraps.(bname);

    if B.bootstrap_valid_share.T50 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T50: ', bname];
    end

    if B.bootstrap_valid_share.T90 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T90: ', bname];
    end

    if B.bootstrap_valid_share.T95 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T95: ', bname];
    end
  end
end


function print_estimable_value(value, flag)
  if flag == 1
    fprintf('%.2f', value);
  else
    fprintf('not estimable');
  end
end


function print_bootstrap_summary(label, B)
  fprintf('\nContrast: %s\n', label);
  fprintf('  RMST difference: %.2f | CI [%.2f, %.2f]\n', ...
    B.observed_difference.rmst, B.ci_low.rmst, B.ci_high.rmst);
  fprintf('  readiness probability difference: %.3f | CI [%.3f, %.3f]\n', ...
    B.observed_difference.readiness_probability, ...
    B.ci_low.readiness_probability, B.ci_high.readiness_probability);
  fprintf('  T95 difference: %.2f | CI [%.2f, %.2f] | valid share %.3f\n', ...
    B.observed_difference.T95, B.ci_low.T95, B.ci_high.T95, ...
    B.bootstrap_valid_share.T95);
end


function write_translation_grid_manifest(manifest_file, translation_grid, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open translation-grid manifest file for writing.');

  fprintf(fid, 'RERUN V2 TRANSLATION-GRID MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', translation_grid.timestamp);
  fprintf(fid, 'run_type: %s\n', translation_grid.run_type);
  fprintf(fid, 'output_tag: %s\n', translation_grid.output_tag);
  fprintf(fid, 'NG: %d\n', translation_grid.NG);
  fprintf(fid, 'NT: %d\n', translation_grid.NT);
  fprintf(fid, 'T_max: %d\n', translation_grid.T_max);
  fprintf(fid, 'n_boot: %d\n', translation_grid.n_boot);
  fprintf(fid, 'theta: %.6f\n', translation_grid.theta);
  fprintf(fid, 'q: %.6f\n', translation_grid.q);
  fprintf(fid, 'pi_out: %.6f\n', translation_grid.pi_out);
  fprintf(fid, 'seed_base: %d\n', translation_grid.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', translation_grid.bootstrap_seed);
  fprintf(fid, 'elapsed_seconds: %.6f\n', translation_grid.elapsed_seconds);
  fprintf(fid, 'bootstrap_elapsed_seconds: %.6f\n', translation_grid.bootstrap_elapsed_seconds);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  condition_names = fieldnames(translation_grid.estimands);

  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = translation_grid.estimands.(cname);

    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fprintf(fid, '\nalerts: %d\n', translation_grid.n_alerts);
  for i = 1:length(translation_grid.alerts)
    fprintf(fid, '  - %s\n', translation_grid.alerts{i});
  end

  fclose(fid);
end
