function test_final_core_exports()
  % TEST_FINAL_CORE_EXPORTS
  % Tests Step 13 final-core export logic using a synthetic final_core
  % structure. This test does not run production simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  synthetic_tag = 'final_core_synthetic_export_test';
  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', synthetic_tag);
  ensure_dir(processed_dir);

  final_core = build_synthetic_final_core(synthetic_tag);
  estimands = final_core.estimands;
  bootstraps = final_core.bootstraps;
  config = struct();

  synthetic_file = fullfile(processed_dir, 'final_core_processed_synthetic_export_test.mat');
  save(synthetic_file, 'final_core', 'estimands', 'bootstraps', 'config');

  exports = analyze_final_core_results(synthetic_file, synthetic_tag);

  assert(isstruct(exports), 'Exports must be a structure.');
  assert(exist(exports.condition_csv_processed, 'file') == 2, ...
    'Condition processed CSV was not created.');
  assert(exist(exports.contrast_csv_processed, 'file') == 2, ...
    'Contrast processed CSV was not created.');
  assert(exist(exports.condition_csv_figure, 'file') == 2, ...
    'Condition figure-data CSV was not created.');
  assert(exist(exports.contrast_csv_figure, 'file') == 2, ...
    'Contrast figure-data CSV was not created.');
  assert(exist(exports.handover_file, 'file') == 2, ...
    'Manuscript handover file was not created.');

  assert(length(exports.condition_rows) == 3, ...
    'Expected three condition rows.');
  assert(length(exports.contrast_rows) == 3, ...
    'Expected three contrast rows.');

  assert(strcmp(exports.contrast_rows(2).contrast_id, 'BS_low_minus_BS_high'), ...
    'Contrast ordering mismatch.');

  assert(exports.contrast_rows(2).rmst_difference > 0, ...
    'Synthetic translation contrast should have positive RMST difference.');

  fprintf('test_final_core_exports passed.\n');
end


function final_core = build_synthetic_final_core(output_tag)
  RB = synthetic_results([300; 320; 340; 360; 380; 400], [1; 1; 1; 1; 1; 1]);
  BS_low = synthetic_results([330; 350; 370; 390; 410; 430], [1; 1; 1; 1; 1; 1]);
  BS_high = synthetic_results([180; 200; 220; 240; 260; 280], [1; 1; 1; 1; 1; 1]);

  estimands = struct();
  estimands.RB_low = compute_event_time_estimands(RB);
  estimands.BS_low = compute_event_time_estimands(BS_low);
  estimands.BS_high = compute_event_time_estimands(BS_high);

  bootstraps = struct();
  bootstraps.RB_low_minus_BS_low = hierarchical_paired_bootstrap(RB, BS_low, 20, 92001);
  bootstraps.BS_low_minus_BS_high = hierarchical_paired_bootstrap(BS_low, BS_high, 20, 92002);
  bootstraps.RB_low_minus_BS_high = hierarchical_paired_bootstrap(RB, BS_high, 20, 92003);

  P = baseline_params();

  C1 = struct();
  C1.condition_id = 'RB_low';
  C1.architecture = 'random_bridging';
  C1.P = P;
  C1.P.pi_out = 0.55;
  C1.P.pi_BS = 0.55;

  C2 = struct();
  C2.condition_id = 'BS_low';
  C2.architecture = 'boundary_spanning';
  C2.P = P;
  C2.P.pi_out = 0.55;
  C2.P.pi_BS = 0.55;

  C3 = struct();
  C3.condition_id = 'BS_high';
  C3.architecture = 'boundary_spanning';
  C3.P = P;
  C3.P.pi_out = 0.55;
  C3.P.pi_BS = 0.65;

  final_core = struct();
  final_core.run_type = 'final_core_synthetic';
  final_core.output_tag = output_tag;
  final_core.timestamp = 'synthetic_export_test';
  final_core.NG = 3;
  final_core.NT = 2;
  final_core.T_max = 50000;
  final_core.n_boot = 20;
  final_core.seed_base = 92000;
  final_core.bootstrap_seed = 93000;
  final_core.theta = 0.80;
  final_core.q = 0.80;
  final_core.conditions = [C1, C2, C3];
  final_core.estimands = estimands;
  final_core.bootstraps = bootstraps;
  final_core.alerts = {};
  final_core.n_alerts = 0;
  final_core.elapsed_seconds = 1.0;
  final_core.bootstrap_elapsed_seconds = 0.1;
end


function R = synthetic_results(T_tilde, delta)
  n = length(T_tilde);

  R.graph_id = [1; 1; 2; 2; 3; 3];
  R.trajectory_id = [1; 2; 1; 2; 1; 2];
  R.T_tilde = T_tilde(:);
  R.delta = delta(:);
  R.T = T_tilde(:);
  R.T(delta(:) == 0) = NaN;
  R.converged = delta(:);

  assert(length(R.graph_id) == n, 'Synthetic graph_id length mismatch.');
end
