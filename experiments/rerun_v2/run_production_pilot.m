function pilot = run_production_pilot()
  % RUN_PRODUCTION_PILOT
  % Runs the rerun_v2 production pilot.
  %
  % Purpose:
  %   This is not the final production simulation. It is a medium-small
  %   validation run after the smoke pipeline. It checks whether the full
  %   comparison structure works for the three central conditions:
  %
  %     RB_low  : random bridging, ordinary cross-boundary success
  %     BS_low  : boundary spanning without translation advantage
  %     BS_high : boundary spanning with translation advantage
  %
  % Design:
  %   - NG = 10 graph realizations
  %   - NT = 20 trajectories per graph
  %   - T_max = 10000
  %   - n_boot = 500
  %
  % Outputs are written only under rerun_v2 pilot folders.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  raw_dir = fullfile(repo_root, 'results', 'raw', 'rerun_v2', 'pilot');
  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'pilot');

  ensure_dir(raw_dir);
  ensure_dir(processed_dir);

  timestamp = datestr(now, 'yyyymmdd_HHMMSS');

  P_base = baseline_params();
  P_base.NG_pilot = 10;
  P_base.NT_pilot = 20;
  P_base.T_max = 10000;
  P_base.theta = 0.80;
  P_base.q = 0.80;

  NG = P_base.NG_pilot;
  NT = P_base.NT_pilot;
  n_boot = 500;

  seed_base = 202000;
  bootstrap_seed = 303000;

  conditions = define_pilot_conditions(P_base);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 PRODUCTION PILOT\n');
  fprintf('============================================\n');
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    NG, NT, P_base.T_max, n_boot);
  fprintf('theta: %.2f | q: %.2f\n', P_base.theta, P_base.q);
  fprintf('seed_base: %d | bootstrap_seed: %d\n', seed_base, bootstrap_seed);

  results = struct();
  estimands = struct();

  for c = 1:length(conditions)
    C = conditions(c);

    fprintf('\nCondition: %s | architecture: %s | pi_BS: %.2f\n', ...
      C.condition_id, C.architecture, C.P.pi_BS);

    R = run_condition(C.P, C.condition_id, C.architecture, NG, NT, seed_base);
    S = compute_event_time_estimands(R);

    results.(C.condition_id) = R;
    estimands.(C.condition_id) = S;

    fprintf('%s readiness probability: %.3f | RMST: %.2f', ...
      C.condition_id, S.readiness_probability, S.RMST);

    fprintf(' | T50: ');
    print_estimable_value(S.T50, S.T50_estimable);
    fprintf(' | T90: ');
    print_estimable_value(S.T90, S.T90_estimable);
    fprintf(' | T95: ');
    print_estimable_value(S.T95, S.T95_estimable);
    fprintf('\n');
  end

  fprintf('\nRunning hierarchical paired bootstraps...\n');

  bootstraps = struct();

  bootstraps.RB_low_minus_BS_low = hierarchical_paired_bootstrap(
    results.RB_low, results.BS_low, n_boot, bootstrap_seed + 1);

  bootstraps.BS_low_minus_BS_high = hierarchical_paired_bootstrap(
    results.BS_low, results.BS_high, n_boot, bootstrap_seed + 2);

  bootstraps.RB_low_minus_BS_high = hierarchical_paired_bootstrap(
    results.RB_low, results.BS_high, n_boot, bootstrap_seed + 3);

  print_bootstrap_summary('RB_low_minus_BS_low', bootstraps.RB_low_minus_BS_low);
  print_bootstrap_summary('BS_low_minus_BS_high', bootstraps.BS_low_minus_BS_high);
  print_bootstrap_summary('RB_low_minus_BS_high', bootstraps.RB_low_minus_BS_high);

  pilot = struct();
  pilot.run_type = 'production_pilot';
  pilot.timestamp = timestamp;
  pilot.NG = NG;
  pilot.NT = NT;
  pilot.T_max = P_base.T_max;
  pilot.n_boot = n_boot;
  pilot.seed_base = seed_base;
  pilot.bootstrap_seed = bootstrap_seed;
  pilot.conditions = conditions;
  pilot.results = results;
  pilot.estimands = estimands;
  pilot.bootstraps = bootstraps;

  raw_file = fullfile(raw_dir, ['production_pilot_raw_', timestamp, '.mat']);
  processed_file = fullfile(processed_dir, ['production_pilot_processed_', timestamp, '.mat']);
  manifest_file = fullfile(processed_dir, ['production_pilot_manifest_', timestamp, '.txt']);

  raw_results = results;
  save(raw_file, 'raw_results', 'conditions', 'P_base', 'NG', 'NT', 'seed_base');

  save(processed_file, 'pilot', 'estimands', 'bootstraps');

  write_pilot_manifest(manifest_file, pilot, raw_file, processed_file);

  pilot.raw_file = raw_file;
  pilot.processed_file = processed_file;
  pilot.manifest_file = manifest_file;

  fprintf('\nPilot raw file:\n%s\n', raw_file);
  fprintf('\nPilot processed file:\n%s\n', processed_file);
  fprintf('\nPilot manifest file:\n%s\n', manifest_file);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 PRODUCTION PILOT PASSED\n');
  fprintf('============================================\n');
end


function conditions = define_pilot_conditions(P_base)
  % DEFINE_PILOT_CONDITIONS
  % Returns the three central pilot conditions.

  C1 = struct();
  C1.condition_id = 'RB_low';
  C1.architecture = 'random_bridging';
  C1.P = P_base;
  C1.P.pi_BS = 0.55;
  C1.P.pi_out = 0.55;

  C2 = struct();
  C2.condition_id = 'BS_low';
  C2.architecture = 'boundary_spanning';
  C2.P = P_base;
  C2.P.pi_BS = 0.55;
  C2.P.pi_out = 0.55;

  C3 = struct();
  C3.condition_id = 'BS_high';
  C3.architecture = 'boundary_spanning';
  C3.P = P_base;
  C3.P.pi_BS = 0.65;
  C3.P.pi_out = 0.55;

  conditions = [C1, C2, C3];
end


function R = run_condition(P, condition_id, architecture, NG, NT, seed_base)
  % RUN_CONDITION
  % Runs one pilot condition and returns flat trajectory-level results.

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
  end

  assert(row == n, 'Internal row counter mismatch.');
  validate_condition_results(R, n);
end


function validate_condition_results(R, n)
  % VALIDATE_CONDITION_RESULTS
  % Defensive checks for flat trajectory-level pilot results.

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


function write_pilot_manifest(manifest_file, pilot, raw_file, processed_file)
  fid = fopen(manifest_file, 'w');
  assert(fid > 0, 'Could not open pilot manifest file for writing.');

  fprintf(fid, 'RERUN V2 PRODUCTION PILOT MANIFEST\n');
  fprintf(fid, 'timestamp: %s\n', pilot.timestamp);
  fprintf(fid, 'run_type: %s\n', pilot.run_type);
  fprintf(fid, 'NG: %d\n', pilot.NG);
  fprintf(fid, 'NT: %d\n', pilot.NT);
  fprintf(fid, 'T_max: %d\n', pilot.T_max);
  fprintf(fid, 'n_boot: %d\n', pilot.n_boot);
  fprintf(fid, 'seed_base: %d\n', pilot.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', pilot.bootstrap_seed);
  fprintf(fid, 'raw_file: %s\n', raw_file);
  fprintf(fid, 'processed_file: %s\n', processed_file);

  condition_names = fieldnames(pilot.estimands);

  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = pilot.estimands.(cname);

    fprintf(fid, '\ncondition: %s\n', cname);
    fprintf(fid, '  readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, '  censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, '  RMST: %.6f\n', S.RMST);
    fprintf(fid, '  T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, '  T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, '  T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fclose(fid);
end
