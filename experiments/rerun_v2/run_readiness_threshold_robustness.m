function threshold_robustness = run_readiness_threshold_robustness(config)
  % RUN_READINESS_THRESHOLD_ROBUSTNESS
  % Runs the rerun_v2 readiness-threshold robustness experiment.
  %
  % Purpose:
  %   Test whether the translation-capability mechanism remains directionally
  %   robust when the tie-level readiness threshold theta and the boundary-level
  %   readiness threshold q are varied.
  %
  % Default production design:
  %   - architecture: boundary_spanning
  %   - paired conditions: BS_low and BS_high within each threshold scenario
  %   - scenarios:
  %       easier_tie      theta = 0.75, q = 0.80
  %       baseline        theta = 0.80, q = 0.80
  %       easier_boundary theta = 0.80, q = 0.70
  %       harder_boundary theta = 0.80, q = 0.90
  %       harder_tie      theta = 0.85, q = 0.80
  %   - NG = 50 graph realizations
  %   - NT = 50 trajectories per graph
  %   - T_max = 50000
  %   - n_boot = 10000
  %
  % Usage:
  %   threshold_robustness = run_readiness_threshold_robustness()
  %
  % Test/small-run usage:
  %   config = struct();
  %   config.run_type = 'threshold_robustness_test';
  %   config.output_tag = 'threshold_robustness_test';
  %   config.NG = 2;
  %   config.NT = 3;
  %   config.T_max = 2000;
  %   config.n_boot = 20;
  %   threshold_robustness = run_readiness_threshold_robustness(config);
  %
  % Outputs are written only under:
  %   results/raw/rerun_v2/<output_tag>/
  %   results/processed/rerun_v2/<output_tag>/

  if nargin < 1
    config = struct();
  end

  config = fill_threshold_config(config);

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
  P_base.pi_out = config.pi_out;

  scenarios = define_threshold_scenarios();
  conditions = define_threshold_conditions(P_base, config, scenarios);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 READINESS-THRESHOLD ROBUSTNESS\n');
  fprintf('============================================\n');
  fprintf('run_type: %s | output_tag: %s\n', config.run_type, config.output_tag);
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    config.NG, config.NT, config.T_max, config.n_boot);
  fprintf('pi_out: %.2f | pi_BS_low: %.2f | pi_BS_high: %.2f\n', ...
    config.pi_out, config.pi_BS_low, config.pi_BS_high);
  fprintf('seed_base: %d | bootstrap_seed: %d\n', ...
    config.seed_base, config.bootstrap_seed);

  if strcmp(config.run_type, 'threshold_robustness')
    fprintf('\nThis is the final readiness-threshold robustness run. It may take a long time.\n');
  else
    fprintf('\nThis is a non-final/test run using the threshold-robustness pipeline.\n');
  end

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCondition: %s | scenario: %s | theta %.2f | q %.2f | pi_BS %.2f\n', ...
      C.condition_id, C.scenario_id, C.P.theta, C.P.q, C.P.pi_BS);

    condition_tic = tic();
    R = run_threshold_condition(C.P, C.condition_id, C.scenario_id, ...
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

  fprintf('\nRunning hierarchical paired bootstraps for threshold contrasts...\n');

  bootstrap_tic = tic();
  bootstraps = struct();

  contrast_pairs = define_threshold_contrasts(scenarios);
  for i = 1:length(contrast_pairs)
    x = contrast_pairs(i).x;
    y = contrast_pairs(i).y;
    contrast_id = [x, '_minus_', y];

    bootstraps.(contrast_id) = hierarchical_paired_bootstrap(
      results.(x), results.(y), config.n_boot, config.bootstrap_seed + i);
  end

  bootstrap_elapsed = toc(bootstrap_tic);

  bootstrap_names = fieldnames(bootstraps);
  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    print_bootstrap_summary(bname, bootstraps.(bname));
  end

  alerts = collect_threshold_alerts(conditions, estimands, bootstraps);

  fprintf('\nReadiness-threshold diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No readiness-threshold diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  elapsed_seconds = toc(wall_clock_tic);

  threshold_robustness = struct();
  threshold_robustness.run_type = config.run_type;
  threshold_robustness.output_tag = config.output_tag;
  threshold_robustness.timestamp = timestamp;
  threshold_robustness.NG = config.NG;
  threshold_robustness.NT = config.NT;
  threshold_robustness.T_max = config.T_max;
  threshold_robustness.n_boot = config.n_boot;
  threshold_robustness.seed_base = config.seed_base;
  threshold_robustness.bootstrap_seed = config.bootstrap_seed;
  threshold_robustness.pi_out = config.pi_out;
  threshold_robustness.pi_BS_low = config.pi_BS_low;
  threshold_robustness.pi_BS_high = config.pi_BS_high;
  threshold_robustness.scenarios = scenarios;
  threshold_robustness.conditions = conditions;
  threshold_robustness.results = results;
  threshold_robustness.estimands = estimands;
  threshold_robustness.bootstraps = bootstraps;
  threshold_robustness.alerts = alerts(:);
  threshold_robustness.n_alerts = length(alerts);
  threshold_robustness.elapsed_seconds = elapsed_seconds;
  threshold_robustness.bootstrap_elapsed_seconds = bootstrap_elapsed;

  raw_file = fullfile(raw_dir, ['threshold_robustness_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['threshold_robustness_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['threshold_robustness_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'scenarios', 'P_base', 'config');
  save(processed_file, 'threshold_robustness', 'estimands', 'bootstraps', 'config');

  write_threshold_manifest(manifest_file, threshold_robustness, raw_file, processed_file);

  threshold_robustness.raw_file = raw_file;
  threshold_robustness.processed_file = processed_file;
  threshold_robustness.manifest_file = manifest_file;

  fprintf('\nReadiness-threshold raw file:\n%s\n', raw_file);
  fprintf('\nReadiness-threshold processed file:\n%s\n', processed_file);
  fprintf('\nReadiness-threshold manifest file:\n%s\n', manifest_file);

  fprintf('\nElapsed wall-clock time: %.1f seconds\n', elapsed_seconds);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 READINESS-THRESHOLD ROBUSTNESS PASSED\n');
  fprintf('============================================\n');
end


function config = fill_threshold_config(config)
  if ~isfield(config, 'run_type')
    config.run_type = 'threshold_robustness';
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
    config.seed_base = 1201000;
  end

  if ~isfield(config, 'bootstrap_seed')
    config.bootstrap_seed = 1301000;
  end

  assert(config.NG > 0, 'NG must be positive.');
  assert(config.NT > 0, 'NT must be positive.');
  assert(config.T_max > 0, 'T_max must be positive.');
  assert(config.n_boot > 0, 'n_boot must be positive.');
  assert(config.pi_BS_high >= config.pi_BS_low, ...
    'pi_BS_high must be greater than or equal to pi_BS_low.');
end


function scenarios = define_threshold_scenarios()
  specs = {
    'easier_tie',      'Easier tie readiness',      0.75, 0.80;
    'baseline',        'Baseline',                  0.80, 0.80;
    'easier_boundary', 'Easier boundary readiness', 0.80, 0.70;
    'harder_boundary', 'Harder boundary readiness', 0.80, 0.90;
    'harder_tie',      'Harder tie readiness',      0.85, 0.80
  };

  scenarios = [];
  for i = 1:size(specs, 1)
    S = struct();
    S.scenario_id = specs{i, 1};
    S.scenario_label = specs{i, 2};
    S.theta = specs{i, 3};
    S.q = specs{i, 4};

    if isempty(scenarios)
      scenarios = S;
    else
      scenarios(end + 1) = S;
    end
  end
end


function conditions = define_threshold_conditions(P_base, config, scenarios)
  conditions = [];

  for i = 1:length(scenarios)
    S = scenarios(i);
    levels = {'BS_low', config.pi_BS_low; 'BS_high', config.pi_BS_high};

    for j = 1:size(levels, 1)
      C = struct();
      C.condition_id = [S.scenario_id, '_', levels{j, 1}];
      C.scenario_id = S.scenario_id;
      C.scenario_label = S.scenario_label;
      C.architecture = 'boundary_spanning';
      C.translation_level = levels{j, 1};
      C.P = P_base;
      C.P.theta = S.theta;
      C.P.q = S.q;
      C.P.pi_out = config.pi_out;
      C.P.pi_BS = levels{j, 2};

      if isempty(conditions)
        conditions = C;
      else
        conditions(end + 1) = C;
      end
    end
  end
end


function contrast_pairs = define_threshold_contrasts(scenarios)
  contrast_pairs = [];

  for i = 1:length(scenarios)
    S = scenarios(i);
    C = struct();
    C.x = [S.scenario_id, '_BS_low'];
    C.y = [S.scenario_id, '_BS_high'];

    if isempty(contrast_pairs)
      contrast_pairs = C;
    else
      contrast_pairs(end + 1) = C;
    end
  end
end


function R = run_threshold_condition(P, condition_id, scenario_id, NG, NT, seed_base)
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
  R.scenario_id = scenario_id;
  R.architecture = 'boundary_spanning';
  R.selection_rule = 'agent_first';

  row = 0;

  for g = 1:NG
    network_seed = seed_base + 1000 * scenario_numeric_id(scenario_id) + g;

    rand('seed', network_seed);
    G = safe_generate_network(P, 'boundary_spanning');

    for tr = 1:NT
      row = row + 1;

      trajectory_seed = seed_base + 100000 * scenario_numeric_id(scenario_id) + 1000 * g + tr;
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
  validate_threshold_condition_results(R, n);
end


function sid = scenario_numeric_id(scenario_id)
  if strcmp(scenario_id, 'easier_tie')
    sid = 1;
  elseif strcmp(scenario_id, 'baseline')
    sid = 2;
  elseif strcmp(scenario_id, 'easier_boundary')
    sid = 3;
  elseif strcmp(scenario_id, 'harder_boundary')
    sid = 4;
  elseif strcmp(scenario_id, 'harder_tie')
    sid = 5;
  else
    error(['Unknown scenario_id: ', scenario_id]);
  end
end


function validate_threshold_condition_results(R, n)
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


function alerts = collect_threshold_alerts(conditions, estimands, bootstraps)
  alerts = {};

  for i = 1:length(conditions)
    cname = conditions(i).condition_id;
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


function write_threshold_manifest(manifest_file, threshold_robustness, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open threshold manifest file for writing.');

  fprintf(fid, 'RERUN V2 READINESS-THRESHOLD ROBUSTNESS MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', threshold_robustness.timestamp);
  fprintf(fid, 'run_type: %s\n', threshold_robustness.run_type);
  fprintf(fid, 'output_tag: %s\n', threshold_robustness.output_tag);
  fprintf(fid, 'NG: %d\n', threshold_robustness.NG);
  fprintf(fid, 'NT: %d\n', threshold_robustness.NT);
  fprintf(fid, 'T_max: %d\n', threshold_robustness.T_max);
  fprintf(fid, 'n_boot: %d\n', threshold_robustness.n_boot);
  fprintf(fid, 'pi_out: %.6f\n', threshold_robustness.pi_out);
  fprintf(fid, 'pi_BS_low: %.6f\n', threshold_robustness.pi_BS_low);
  fprintf(fid, 'pi_BS_high: %.6f\n', threshold_robustness.pi_BS_high);
  fprintf(fid, 'seed_base: %d\n', threshold_robustness.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', threshold_robustness.bootstrap_seed);
  fprintf(fid, 'elapsed_seconds: %.6f\n', threshold_robustness.elapsed_seconds);
  fprintf(fid, 'bootstrap_elapsed_seconds: %.6f\n', threshold_robustness.bootstrap_elapsed_seconds);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  scenario_names = fieldnames(threshold_robustness.estimands);
  for i = 1:length(scenario_names)
    cname = scenario_names{i};
    S = threshold_robustness.estimands.(cname);

    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fprintf(fid, '\nalerts: %d\n', threshold_robustness.n_alerts);
  for i = 1:length(threshold_robustness.alerts)
    fprintf(fid, '  - %s\n', threshold_robustness.alerts{i});
  end

  fclose(fid);
end
