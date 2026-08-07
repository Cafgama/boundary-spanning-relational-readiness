function smoke = run_smoke_pipeline()
  % RUN_SMOKE_PIPELINE
  % Small end-to-end rerun_v2 smoke simulation.
  %
  % Purpose:
  %   This is not a scientific production run. It verifies that the current
  %   computational pipeline connects correctly:
  %
  %     network generator -> dynamics -> raw result structure -> estimands
  %     -> hierarchical paired bootstrap -> versioned output files
  %
  % The script intentionally uses very small NG and NT values.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  raw_dir = fullfile(repo_root, 'results', 'raw', 'rerun_v2', 'smoke');
  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'smoke');

  ensure_dir(raw_dir);
  ensure_dir(processed_dir);

  % ------------------------------------------------------------
  % Smoke configuration
  % ------------------------------------------------------------
  P = baseline_params();

  % These are smoke-test settings only. They are deliberately small and
  % easier than the production baseline so the test can run quickly.
  NG = 3;
  NT = 4;
  P.T_max = 2000;
  P.theta = 0.60;
  P.q = 0.50;
  P.pi_out = 0.55;
  P.pi_BS = 0.65;

  seed_base = P.seed + 90000;
  bootstrap_seed = seed_base + 999;
  n_boot = 50;

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SMOKE PIPELINE\n');
  fprintf('============================================\n');
  fprintf('NG: %d | NT: %d | T_max: %d\n', NG, NT, P.T_max);
  fprintf('theta: %.2f | q: %.2f\n', P.theta, P.q);
  fprintf('seed_base: %d | bootstrap_seed: %d\n', seed_base, bootstrap_seed);

  % ------------------------------------------------------------
  % Conditions
  % ------------------------------------------------------------
  P_RB = P;
  P_RB.pi_BS = P_RB.pi_out;  % irrelevant for RB, explicit for clarity

  P_BS = P;
  P_BS.pi_BS = 0.65;

  results_RB = run_smoke_condition( ...
    P_RB, 'RB_low', 'random_bridging', NG, NT, seed_base);

  results_BS = run_smoke_condition( ...
    P_BS, 'BS_high', 'boundary_spanning', NG, NT, seed_base);

  % ------------------------------------------------------------
  % Manuscript-facing estimands
  % ------------------------------------------------------------
  S_RB = compute_event_time_estimands(results_RB);
  S_BS = compute_event_time_estimands(results_BS);

  B_RB_minus_BS = hierarchical_paired_bootstrap( ...
    results_RB, results_BS, n_boot, bootstrap_seed);

  % ------------------------------------------------------------
  % Defensive diagnostics
  % ------------------------------------------------------------
  validate_smoke_results(results_RB, NG, NT, 'RB_low');
  validate_smoke_results(results_BS, NG, NT, 'BS_high');

  assert(B_RB_minus_BS.n_boot == n_boot, ...
    'Bootstrap replication count mismatch.');

  assert(B_RB_minus_BS.n_graphs == NG, ...
    'Bootstrap graph count mismatch.');

  assert(B_RB_minus_BS.n_matched_trajectories == NG * NT, ...
    'Bootstrap matched trajectory count mismatch.');

  % ------------------------------------------------------------
  % Save versioned outputs
  % ------------------------------------------------------------
  timestamp = datestr(now(), 'yyyymmdd_HHMMSS');

  raw_file = fullfile(raw_dir, ...
    ['smoke_pipeline_raw_', timestamp, '.mat']);

  processed_file = fullfile(processed_dir, ...
    ['smoke_pipeline_processed_', timestamp, '.mat']);

  manifest_file = fullfile(processed_dir, ...
    ['smoke_pipeline_manifest_', timestamp, '.txt']);

  save(raw_file, 'results_RB', 'results_BS', 'P_RB', 'P_BS', ...
    'NG', 'NT', 'seed_base', 'bootstrap_seed');

  save(processed_file, 'S_RB', 'S_BS', 'B_RB_minus_BS', ...
    'NG', 'NT', 'seed_base', 'bootstrap_seed');

  write_smoke_manifest(manifest_file, raw_file, processed_file, ...
    NG, NT, P, seed_base, bootstrap_seed, n_boot, S_RB, S_BS, B_RB_minus_BS);

  % ------------------------------------------------------------
  % Return compact output
  % ------------------------------------------------------------
  smoke.raw_file = raw_file;
  smoke.processed_file = processed_file;
  smoke.manifest_file = manifest_file;

  smoke.results_RB = results_RB;
  smoke.results_BS = results_BS;
  smoke.S_RB = S_RB;
  smoke.S_BS = S_BS;
  smoke.bootstrap = B_RB_minus_BS;

  fprintf('\nSmoke raw file:\n%s\n', raw_file);
  fprintf('\nSmoke processed file:\n%s\n', processed_file);
  fprintf('\nSmoke manifest file:\n%s\n', manifest_file);

  fprintf('\nRB readiness probability: %.3f | RMST: %.2f\n', ...
    S_RB.readiness_probability, S_RB.rmst);

  fprintf('BS readiness probability: %.3f | RMST: %.2f\n', ...
    S_BS.readiness_probability, S_BS.rmst);

  fprintf('\nObserved RMST difference RB_minus_BS: %.2f\n', ...
    B_RB_minus_BS.observed_difference.rmst);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SMOKE PIPELINE PASSED\n');
  fprintf('============================================\n');
end


function results = run_smoke_condition(P, condition_id, architecture, NG, NT, seed_base)
  total_runs = NG * NT;

  graph_id = zeros(total_runs, 1);
  trajectory_id = zeros(total_runs, 1);
  network_seed = zeros(total_runs, 1);
  trajectory_seed = zeros(total_runs, 1);

  T = NaN(total_runs, 1);
  T_tilde = NaN(total_runs, 1);
  delta = zeros(total_runs, 1);
  converged = zeros(total_runs, 1);

  final_RB = NaN(total_runs, 1);
  final_ready = NaN(total_runs, 1);
  total_boundary_edges = NaN(total_runs, 1);

  workload_mean = NaN(total_runs, 1);
  workload_min = NaN(total_runs, 1);
  workload_max = NaN(total_runs, 1);
  workload_sd = NaN(total_runs, 1);

  fprintf('\nCondition: %s | architecture: %s\n', condition_id, architecture);

  for g = 1:NG
    current_network_seed = seed_base + g;
    rand('seed', current_network_seed);

    G = safe_generate_network(P, architecture);

    for r = 1:NT
      row = (g - 1) * NT + r;
      current_trajectory_seed = seed_base + 100000 * g + r;
      rand('seed', current_trajectory_seed);

      out = run_dynamics_fast(G, P, false);

      graph_id(row) = g;
      trajectory_id(row) = r;
      network_seed(row) = current_network_seed;
      trajectory_seed(row) = current_trajectory_seed;

      T(row) = out.T;
      T_tilde(row) = out.T_tilde;
      delta(row) = out.delta;
      converged(row) = out.converged;

      final_RB(row) = out.final_RB;
      final_ready(row) = out.final_ready;
      total_boundary_edges(row) = out.total_boundary_edges;

      if strcmp(architecture, 'boundary_spanning')
        workload_mean(row) = G.BS_workload_mean;
        workload_min(row) = G.BS_workload_min;
        workload_max(row) = G.BS_workload_max;
        workload_sd(row) = G.BS_workload_sd;
      end
    end
  end

  results.condition_id = condition_id;
  results.architecture = architecture;
  results.selection_rule = 'agent_first';

  results.NG = NG;
  results.NT = NT;
  results.n_runs = total_runs;

  results.graph_id = graph_id;
  results.trajectory_id = trajectory_id;
  results.network_seed = network_seed;
  results.trajectory_seed = trajectory_seed;

  results.T = T;
  results.T_tilde = T_tilde;
  results.delta = delta;
  results.converged = converged;

  results.final_RB = final_RB;
  results.final_ready = final_ready;
  results.total_boundary_edges = total_boundary_edges;

  results.pi_out = P.pi_out * ones(total_runs, 1);
  results.pi_BS = P.pi_BS * ones(total_runs, 1);
  results.b = P.b * ones(total_runs, 1);
  results.theta = P.theta * ones(total_runs, 1);
  results.q = P.q * ones(total_runs, 1);

  results.workload_mean = workload_mean;
  results.workload_min = workload_min;
  results.workload_max = workload_max;
  results.workload_sd = workload_sd;
end


function validate_smoke_results(results, NG, NT, condition_id)
  expected_n = NG * NT;

  assert(strcmp(results.condition_id, condition_id), ...
    'Condition identifier mismatch.');

  assert(length(results.T_tilde) == expected_n, ...
    'Unexpected number of T_tilde observations.');

  assert(length(results.delta) == expected_n, ...
    'Unexpected number of delta observations.');

  assert(all(~isnan(results.T_tilde)), ...
    'T_tilde cannot contain NaN in smoke results.');

  assert(all(isfinite(results.T_tilde)), ...
    'T_tilde must be finite in smoke results.');

  assert(all(results.delta == 0 | results.delta == 1), ...
    'delta must contain only 0 or 1 in smoke results.');

  assert(all(results.converged == results.delta), ...
    'converged and delta must match in smoke results.');

  assert(all(results.graph_id >= 1 & results.graph_id <= NG), ...
    'graph_id outside expected range.');

  assert(all(results.trajectory_id >= 1 & results.trajectory_id <= NT), ...
    'trajectory_id outside expected range.');
end


function write_smoke_manifest(manifest_file, raw_file, processed_file, ...
  NG, NT, P, seed_base, bootstrap_seed, n_boot, S_RB, S_BS, B)

  fid = fopen(manifest_file, 'w');
  assert(fid > 0, ['Could not open manifest file: ', manifest_file]);

  fprintf(fid, 'RERUN V2 SMOKE PIPELINE MANIFEST\n');
  fprintf(fid, 'Generated: %s\n', datestr(now()));
  fprintf(fid, '\n');

  fprintf(fid, 'Purpose: end-to-end smoke test only; not production science.\n');
  fprintf(fid, '\n');

  fprintf(fid, 'NG: %d\n', NG);
  fprintf(fid, 'NT: %d\n', NT);
  fprintf(fid, 'T_max: %d\n', P.T_max);
  fprintf(fid, 'theta: %.4f\n', P.theta);
  fprintf(fid, 'q: %.4f\n', P.q);
  fprintf(fid, 'seed_base: %d\n', seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', bootstrap_seed);
  fprintf(fid, 'n_boot: %d\n', n_boot);
  fprintf(fid, '\n');

  fprintf(fid, 'Raw file: %s\n', raw_file);
  fprintf(fid, 'Processed file: %s\n', processed_file);
  fprintf(fid, '\n');

  fprintf(fid, 'RB readiness_probability: %.6f\n', S_RB.readiness_probability);
  fprintf(fid, 'RB RMST: %.6f\n', S_RB.rmst);
  fprintf(fid, 'BS readiness_probability: %.6f\n', S_BS.readiness_probability);
  fprintf(fid, 'BS RMST: %.6f\n', S_BS.rmst);
  fprintf(fid, '\n');

  fprintf(fid, 'Observed difference convention: %s\n', B.difference_convention);
  fprintf(fid, 'Observed RMST difference RB_minus_BS: %.6f\n', B.observed_difference.rmst);
  fprintf(fid, 'RMST CI low: %.6f\n', B.ci_low.rmst);
  fprintf(fid, 'RMST CI high: %.6f\n', B.ci_high.rmst);

  fclose(fid);
end
