function final_core = run_final_core_production(config)
  % RUN_FINAL_CORE_PRODUCTION
  % Runs the rerun_v2 final core production experiment.
  %
  % Default final-core design:
  %   - NG = 50 graph realizations
  %   - NT = 50 trajectories per graph
  %   - T_max = 50000
  %   - n_boot = 10000
  %
  % Core conditions:
  %   RB_low  : random bridging, ordinary cross-boundary success
  %   BS_low  : boundary spanning without translation advantage
  %   BS_high : boundary spanning with translation advantage
  %
  % Core contrasts:
  %   RB_low_minus_BS_low
  %   BS_low_minus_BS_high
  %   RB_low_minus_BS_high
  %
  % Usage:
  %   final_core = run_final_core_production()
  %
  % Test/small-run usage:
  %   config = struct();
  %   config.run_type = 'final_core_test';
  %   config.output_tag = 'final_core_test';
  %   config.NG = 2;
  %   config.NT = 3;
  %   config.T_max = 2000;
  %   config.n_boot = 20;
  %   final_core = run_final_core_production(config);
  %
  % Outputs are written only under:
  %   results/raw/rerun_v2/<output_tag>/
  %   results/processed/rerun_v2/<output_tag>/

  if nargin < 1
    config = struct();
  end

  config = fill_final_core_config(config);

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

  conditions = define_final_core_conditions(P_base, config);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 FINAL CORE PRODUCTION\n');
  fprintf('============================================\n');
  fprintf('run_type: %s | output_tag: %s\n', config.run_type, config.output_tag);
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    config.NG, config.NT, config.T_max, config.n_boot);
  fprintf('theta: %.2f | q: %.2f\n', config.theta, config.q);
  fprintf('seed_base: %d | bootstrap_seed: %d\n', ...
    config.seed_base, config.bootstrap_seed);

  if strcmp(config.run_type, 'final_core')
    fprintf('\nThis is the final core production run. It may take a long time.\n');
  else
    fprintf('\nThis is a non-final/test run using the final-core pipeline.\n');
  end

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCondition: %s | architecture: %s | pi_out: %.2f | pi_BS: %.2f\n', ...
      C.condition_id, C.architecture, C.P.pi_out, C.P.pi_BS);

    condition_tic = tic();
    R = run_final_core_condition(C.P, C.condition_id, C.architecture, ...
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

  fprintf('\nRunning hierarchical paired bootstraps...\n');

  bootstrap_tic = tic();

  bootstraps = struct();

  bootstraps.RB_low_minus_BS_low = hierarchical_paired_bootstrap(
    results.RB_low, results.BS_low, config.n_boot, config.bootstrap_seed + 1);

  bootstraps.BS_low_minus_BS_high = hierarchical_paired_bootstrap(
    results.BS_low, results.BS_high, config.n_boot, config.bootstrap_seed + 2);

  bootstraps.RB_low_minus_BS_high = hierarchical_paired_bootstrap(
    results.RB_low, results.BS_high, config.n_boot, config.bootstrap_seed + 3);

  bootstrap_elapsed = toc(bootstrap_tic);

  print_bootstrap_summary('RB_low_minus_BS_low', bootstraps.RB_low_minus_BS_low);
  print_bootstrap_summary('BS_low_minus_BS_high', bootstraps.BS_low_minus_BS_high);
  print_bootstrap_summary('RB_low_minus_BS_high', bootstraps.RB_low_minus_BS_high);

  alerts = collect_final_core_alerts(estimands, bootstraps);

  fprintf('\nFinal-core diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No final-core diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  elapsed_seconds = toc(wall_clock_tic);

  final_core = struct();
  final_core.run_type = config.run_type;
  final_core.output_tag = config.output_tag;
  final_core.timestamp = timestamp;
  final_core.NG = config.NG;
  final_core.NT = config.NT;
  final_core.T_max = config.T_max;
  final_core.n_boot = config.n_boot;
  final_core.seed_base = config.seed_base;
  final_core.bootstrap_seed = config.bootstrap_seed;
  final_core.theta = config.theta;
  final_core.q = config.q;
  final_core.conditions = conditions;
  final_core.results = results;
  final_core.estimands = estimands;
  final_core.bootstraps = bootstraps;
  final_core.alerts = alerts(:);
  final_core.n_alerts = length(alerts);
  final_core.elapsed_seconds = elapsed_seconds;
  final_core.bootstrap_elapsed_seconds = bootstrap_elapsed;

  raw_file = fullfile(raw_dir, ['final_core_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['final_core_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['final_core_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'P_base', 'config');

  save(processed_file, 'final_core', 'estimands', 'bootstraps', 'config');

  write_final_core_manifest(manifest_file, final_core, raw_file, processed_file);

  final_core.raw_file = raw_file;
  final_core.processed_file = processed_file;
  final_core.manifest_file = manifest_file;

  fprintf('\nFinal-core raw file:\n%s\n', raw_file);
  fprintf('\nFinal-core processed file:\n%s\n', processed_file);
  fprintf('\nFinal-core manifest file:\n%s\n', manifest_file);

  fprintf('\nElapsed wall-clock time: %.1f seconds\n', elapsed_seconds);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 FINAL CORE PRODUCTION PASSED\n');
  fprintf('============================================\n');
end


function config = fill_final_core_config(config)
  % FILL_FINAL_CORE_CONFIG
  % Applies default final-core parameters while allowing small test configs.

  if ~isfield(config, 'run_type')
    config.run_type = 'final_core';
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

  if ~isfield(config, 'pi_BS_low')
    config.pi_BS_low = 0.55;
  end

  if ~isfield(config, 'pi_BS_high')
    config.pi_BS_high = 0.65;
  end

  if ~isfield(config, 'seed_base')
    config.seed_base = 404000;
  end

  if ~isfield(config, 'bootstrap_seed')
    config.bootstrap_seed = 505000;
  end

  validate_final_core_config(config);
end


function validate_final_core_config(config)
  assert(ischar(config.run_type), 'config.run_type must be a character string.');
  assert(ischar(config.output_tag), 'config.output_tag must be a character string.');

  assert(config.NG > 0 && config.NG == floor(config.NG), ...
    'config.NG must be a positive integer.');

  assert(config.NT > 0 && config.NT == floor(config.NT), ...
    'config.NT must be a positive integer.');

  assert(config.T_max > 0 && config.T_max == floor(config.T_max), ...
    'config.T_max must be a positive integer.');

  assert(config.n_boot > 0 && config.n_boot == floor(config.n_boot), ...
    'config.n_boot must be a positive integer.');

  assert(config.theta > 0 && config.theta < 1, 'config.theta must be inside (0,1).');
  assert(config.q > 0 && config.q <= 1, 'config.q must be inside (0,1].');
  assert(config.pi_out > 0 && config.pi_out < 1, 'config.pi_out must be inside (0,1).');
  assert(config.pi_BS_low > 0 && config.pi_BS_low < 1, 'config.pi_BS_low must be inside (0,1).');
  assert(config.pi_BS_high > 0 && config.pi_BS_high < 1, 'config.pi_BS_high must be inside (0,1).');

  assert(config.seed_base > 0 && config.seed_base == floor(config.seed_base), ...
    'config.seed_base must be a positive integer.');

  assert(config.bootstrap_seed > 0 && config.bootstrap_seed == floor(config.bootstrap_seed), ...
    'config.bootstrap_seed must be a positive integer.');
end


function conditions = define_final_core_conditions(P_base, config)
  C1 = struct();
  C1.condition_id = 'RB_low';
  C1.architecture = 'random_bridging';
  C1.P = P_base;
  C1.P.pi_out = config.pi_out;
  C1.P.pi_BS = config.pi_BS_low;

  C2 = struct();
  C2.condition_id = 'BS_low';
  C2.architecture = 'boundary_spanning';
  C2.P = P_base;
  C2.P.pi_out = config.pi_out;
  C2.P.pi_BS = config.pi_BS_low;

  C3 = struct();
  C3.condition_id = 'BS_high';
  C3.architecture = 'boundary_spanning';
  C3.P = P_base;
  C3.P.pi_out = config.pi_out;
  C3.P.pi_BS = config.pi_BS_high;

  conditions = [C1, C2, C3];
end


function R = run_final_core_condition(P, condition_id, architecture, NG, NT, seed_base)
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

      if strcmp(architecture, 'boundary_spanning')
        R.workload_mean(row) = G.BS_workload_mean;
        R.workload_min(row) = G.BS_workload_min;
        R.workload_max(row) = G.BS_workload_max;
        R.workload_sd(row) = G.BS_workload_sd;
      end
    end

    if mod(g, 10) == 0 || g == NG
      fprintf('  completed graph %d/%d for %s\n', g, NG, condition_id);
    end
  end

  assert(row == n, 'Internal row counter mismatch.');
  validate_final_core_condition_results(R, n);
end


function validate_final_core_condition_results(R, n)
  assert(length(R.graph_id) == n, 'graph_id length mismatch.');
  assert(length(R.trajectory_id) == n, 'trajectory_id length mismatch.');
  assert(length(R.T_tilde) == n, 'T_tilde length mismatch.');
  assert(length(R.delta) == n, 'delta length mismatch.');

  assert(all(~isnan(R.T_tilde)), 'T_tilde cannot contain NaN.');
  assert(all(isfinite(R.T_tilde)), 'T_tilde must be finite.');
  assert(all(R.T_tilde >= 0), 'T_tilde must be non-negative.');
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


function alerts = collect_final_core_alerts(estimands, bootstraps)
  alerts = {};

  condition_names = fieldnames(estimands);

  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = estimands.(cname);

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


function write_final_core_manifest(manifest_file, final_core, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open final-core manifest file for writing.');

  fprintf(fid, 'RERUN V2 FINAL CORE PRODUCTION MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', final_core.timestamp);
  fprintf(fid, 'run_type: %s\n', final_core.run_type);
  fprintf(fid, 'output_tag: %s\n', final_core.output_tag);
  fprintf(fid, 'NG: %d\n', final_core.NG);
  fprintf(fid, 'NT: %d\n', final_core.NT);
  fprintf(fid, 'T_max: %d\n', final_core.T_max);
  fprintf(fid, 'n_boot: %d\n', final_core.n_boot);
  fprintf(fid, 'theta: %.6f\n', final_core.theta);
  fprintf(fid, 'q: %.6f\n', final_core.q);
  fprintf(fid, 'seed_base: %d\n', final_core.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', final_core.bootstrap_seed);
  fprintf(fid, 'elapsed_seconds: %.6f\n', final_core.elapsed_seconds);
  fprintf(fid, 'bootstrap_elapsed_seconds: %.6f\n', final_core.bootstrap_elapsed_seconds);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  condition_names = fieldnames(final_core.estimands);

  fprintf(fid, '\nCONDITIONS\n');
  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = final_core.estimands.(cname);

    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  bootstrap_names = fieldnames(final_core.bootstraps);

  fprintf(fid, '\nCONTRASTS\n');
  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    B = final_core.bootstraps.(bname);

    fprintf(fid, '\ncontrast: %s\n', bname);
    fprintf(fid, '  rmst_difference: %.6f | CI [%.6f, %.6f]\n', ...
      B.observed_difference.rmst, B.ci_low.rmst, B.ci_high.rmst);
    fprintf(fid, '  readiness_probability_difference: %.6f | CI [%.6f, %.6f]\n', ...
      B.observed_difference.readiness_probability, ...
      B.ci_low.readiness_probability, B.ci_high.readiness_probability);
    fprintf(fid, '  T50_difference: %.6f | valid_share %.6f\n', ...
      B.observed_difference.T50, B.bootstrap_valid_share.T50);
    fprintf(fid, '  T90_difference: %.6f | valid_share %.6f\n', ...
      B.observed_difference.T90, B.bootstrap_valid_share.T90);
    fprintf(fid, '  T95_difference: %.6f | CI [%.6f, %.6f] | valid_share %.6f\n', ...
      B.observed_difference.T95, B.ci_low.T95, B.ci_high.T95, ...
      B.bootstrap_valid_share.T95);
  end

  fprintf(fid, '\nALERTS\n');
  if isempty(final_core.alerts)
    fprintf(fid, 'No final-core diagnostic alerts.\n');
  else
    for i = 1:length(final_core.alerts)
      fprintf(fid, '- %s\n', final_core.alerts{i});
    end
  end

  fclose(fid);
end
