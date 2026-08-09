function selection_rule = run_selection_rule_robustness(config)
  % RUN_SELECTION_RULE_ROBUSTNESS
  % Runs the rerun_v2 selection-rule robustness experiment.
  %
  % Purpose:
  %   Compare the baseline agent-first interaction-selection rule with an
  %   edge-uniform robustness rule. Agent-first preserves actor-level scarcity
  %   and therefore can expose boundary-spanner overload. Edge-uniform removes
  %   most of that actor-level overload mechanism by giving every edge the same
  %   activation probability.
  %
  % Default production design:
  %   - conditions: RB_low, BS_low, BS_high
  %   - selection rules: agent_first and edge_uniform
  %   - NG = 50 graph realizations
  %   - NT = 50 trajectories per graph
  %   - T_max = 50000
  %   - n_boot = 10000
  %
  % Usage:
  %   selection_rule = run_selection_rule_robustness()
  %
  % Test/small-run usage:
  %   config = struct();
  %   config.run_type = 'selection_rule_test';
  %   config.output_tag = 'selection_rule_test';
  %   config.NG = 2;
  %   config.NT = 3;
  %   config.T_max = 2000;
  %   config.n_boot = 20;
  %   selection_rule = run_selection_rule_robustness(config);
  %
  % Outputs are written only under:
  %   results/raw/rerun_v2/<output_tag>/
  %   results/processed/rerun_v2/<output_tag>/

  if nargin < 1
    config = struct();
  end

  config = fill_selection_rule_config(config);

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

  conditions = define_selection_rule_conditions(P_base, config);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SELECTION-RULE ROBUSTNESS\n');
  fprintf('============================================\n');
  fprintf('run_type: %s | output_tag: %s\n', config.run_type, config.output_tag);
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    config.NG, config.NT, config.T_max, config.n_boot);
  fprintf('theta: %.2f | q: %.2f | pi_out: %.2f\n', ...
    config.theta, config.q, config.pi_out);
  fprintf('pi_BS_low: %.2f | pi_BS_high: %.2f\n', ...
    config.pi_BS_low, config.pi_BS_high);
  fprintf('seed_base: %d | bootstrap_seed: %d\n', ...
    config.seed_base, config.bootstrap_seed);

  if strcmp(config.run_type, 'selection_rule_robustness')
    fprintf('\nThis is the final selection-rule robustness run. It may take a long time.\n');
  else
    fprintf('\nThis is a non-final/test run using the selection-rule pipeline.\n');
  end

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCondition: %s | architecture: %s | selection: %s | pi_BS: %.2f\n', ...
      C.condition_id, C.architecture, C.selection_rule, C.P.pi_BS);

    condition_tic = tic();
    R = run_selection_rule_condition(C.P, C.condition_id, C.architecture, ...
      C.selection_rule, config.NG, config.NT, config.seed_base);
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

  fprintf('\nRunning hierarchical paired bootstraps for selection-rule contrasts...\n');

  bootstrap_tic = tic();
  bootstraps = struct();

  contrast_pairs = define_selection_rule_contrasts();
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

  alerts = collect_selection_rule_alerts(conditions, estimands, bootstraps);

  fprintf('\nSelection-rule diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No selection-rule diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  elapsed_seconds = toc(wall_clock_tic);

  selection_rule = struct();
  selection_rule.run_type = config.run_type;
  selection_rule.output_tag = config.output_tag;
  selection_rule.timestamp = timestamp;
  selection_rule.NG = config.NG;
  selection_rule.NT = config.NT;
  selection_rule.T_max = config.T_max;
  selection_rule.n_boot = config.n_boot;
  selection_rule.seed_base = config.seed_base;
  selection_rule.bootstrap_seed = config.bootstrap_seed;
  selection_rule.theta = config.theta;
  selection_rule.q = config.q;
  selection_rule.pi_out = config.pi_out;
  selection_rule.pi_BS_low = config.pi_BS_low;
  selection_rule.pi_BS_high = config.pi_BS_high;
  selection_rule.conditions = conditions;
  selection_rule.results = results;
  selection_rule.estimands = estimands;
  selection_rule.bootstraps = bootstraps;
  selection_rule.alerts = alerts(:);
  selection_rule.n_alerts = length(alerts);
  selection_rule.elapsed_seconds = elapsed_seconds;
  selection_rule.bootstrap_elapsed_seconds = bootstrap_elapsed;

  raw_file = fullfile(raw_dir, ['selection_rule_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['selection_rule_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['selection_rule_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'P_base', 'config');

  save(processed_file, 'selection_rule', 'estimands', 'bootstraps', 'config');

  write_selection_rule_manifest(manifest_file, selection_rule, raw_file, processed_file);

  selection_rule.raw_file = raw_file;
  selection_rule.processed_file = processed_file;
  selection_rule.manifest_file = manifest_file;

  fprintf('\nSelection-rule raw file:\n%s\n', raw_file);
  fprintf('\nSelection-rule processed file:\n%s\n', processed_file);
  fprintf('\nSelection-rule manifest file:\n%s\n', manifest_file);

  fprintf('\nElapsed wall-clock time: %.1f seconds\n', elapsed_seconds);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SELECTION-RULE ROBUSTNESS PASSED\n');
  fprintf('============================================\n');
end


function config = fill_selection_rule_config(config)
  if ~isfield(config, 'run_type')
    config.run_type = 'selection_rule_robustness';
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
    config.seed_base = 1001000;
  end

  if ~isfield(config, 'bootstrap_seed')
    config.bootstrap_seed = 1101000;
  end

  assert(config.NG > 0, 'NG must be positive.');
  assert(config.NT > 0, 'NT must be positive.');
  assert(config.T_max > 0, 'T_max must be positive.');
  assert(config.n_boot > 0, 'n_boot must be positive.');
  assert(config.pi_BS_high >= config.pi_BS_low, ...
    'pi_BS_high must be greater than or equal to pi_BS_low.');
end


function conditions = define_selection_rule_conditions(P_base, config)
  specs = {
    'RB_low_agent_first', 'random_bridging', 'agent_first', config.pi_BS_low;
    'RB_low_edge_uniform', 'random_bridging', 'edge_uniform', config.pi_BS_low;
    'BS_low_agent_first', 'boundary_spanning', 'agent_first', config.pi_BS_low;
    'BS_low_edge_uniform', 'boundary_spanning', 'edge_uniform', config.pi_BS_low;
    'BS_high_agent_first', 'boundary_spanning', 'agent_first', config.pi_BS_high;
    'BS_high_edge_uniform', 'boundary_spanning', 'edge_uniform', config.pi_BS_high
  };

  conditions = [];

  for i = 1:size(specs, 1)
    C = struct();
    C.condition_id = specs{i, 1};
    C.architecture = specs{i, 2};
    C.selection_rule = specs{i, 3};
    C.P = P_base;
    C.P.pi_out = config.pi_out;
    C.P.pi_BS = specs{i, 4};

    if isempty(conditions)
      conditions = C;
    else
      conditions(end + 1) = C;
    end
  end
end


function contrast_pairs = define_selection_rule_contrasts()
  pairs = {
    'RB_low_agent_first', 'RB_low_edge_uniform';
    'BS_low_agent_first', 'BS_low_edge_uniform';
    'BS_high_agent_first', 'BS_high_edge_uniform';
    'RB_low_edge_uniform', 'BS_low_edge_uniform';
    'BS_low_edge_uniform', 'BS_high_edge_uniform';
    'RB_low_edge_uniform', 'BS_high_edge_uniform'
  };

  contrast_pairs = [];
  for i = 1:size(pairs, 1)
    C = struct();
    C.x = pairs{i, 1};
    C.y = pairs{i, 2};

    if isempty(contrast_pairs)
      contrast_pairs = C;
    else
      contrast_pairs(end + 1) = C;
    end
  end
end


function R = run_selection_rule_condition(P, condition_id, architecture, selection_rule, NG, NT, seed_base)
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
  R.selection_rule = selection_rule;

  row = 0;

  for g = 1:NG
    network_seed = seed_base + g;

    rand('seed', network_seed);
    G = safe_generate_network(P, architecture);

    for tr = 1:NT
      row = row + 1;

      trajectory_seed = seed_base + 100000 * g + tr;
      rand('seed', trajectory_seed);

      if strcmp(selection_rule, 'agent_first')
        out = run_dynamics_fast(G, P, false);
      elseif strcmp(selection_rule, 'edge_uniform')
        out = run_dynamics_fast_edge_uniform(G, P, false);
      else
        error(['Unknown selection rule: ', selection_rule]);
      end

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
  validate_selection_rule_condition_results(R, n);
end


function validate_selection_rule_condition_results(R, n)
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


function alerts = collect_selection_rule_alerts(conditions, estimands, bootstraps)
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


function write_selection_rule_manifest(manifest_file, selection_rule, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open selection-rule manifest file for writing.');

  fprintf(fid, 'RERUN V2 SELECTION-RULE ROBUSTNESS MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', selection_rule.timestamp);
  fprintf(fid, 'run_type: %s\n', selection_rule.run_type);
  fprintf(fid, 'output_tag: %s\n', selection_rule.output_tag);
  fprintf(fid, 'NG: %d\n', selection_rule.NG);
  fprintf(fid, 'NT: %d\n', selection_rule.NT);
  fprintf(fid, 'T_max: %d\n', selection_rule.T_max);
  fprintf(fid, 'n_boot: %d\n', selection_rule.n_boot);
  fprintf(fid, 'theta: %.6f\n', selection_rule.theta);
  fprintf(fid, 'q: %.6f\n', selection_rule.q);
  fprintf(fid, 'pi_out: %.6f\n', selection_rule.pi_out);
  fprintf(fid, 'pi_BS_low: %.6f\n', selection_rule.pi_BS_low);
  fprintf(fid, 'pi_BS_high: %.6f\n', selection_rule.pi_BS_high);
  fprintf(fid, 'seed_base: %d\n', selection_rule.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', selection_rule.bootstrap_seed);
  fprintf(fid, 'elapsed_seconds: %.6f\n', selection_rule.elapsed_seconds);
  fprintf(fid, 'bootstrap_elapsed_seconds: %.6f\n', selection_rule.bootstrap_elapsed_seconds);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  condition_names = fieldnames(selection_rule.estimands);
  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = selection_rule.estimands.(cname);

    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fprintf(fid, '\nalerts: %d\n', selection_rule.n_alerts);
  for i = 1:length(selection_rule.alerts)
    fprintf(fid, '  - %s\n', selection_rule.alerts{i});
  end

  fclose(fid);
end
