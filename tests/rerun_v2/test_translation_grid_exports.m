function test_translation_grid_exports()
  % TEST_TRANSLATION_GRID_EXPORTS
  % Tests Step 16 export logic with a synthetic processed translation-grid
  % structure. This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'translation_grid');
  ensure_dir(processed_dir);

  translation_grid = build_synthetic_translation_grid();

  synthetic_file = fullfile(processed_dir, 'synthetic_translation_grid_processed_for_exports.mat');
  save(synthetic_file, 'translation_grid');

  export = analyze_translation_grid_results(synthetic_file);

  assert(isstruct(export), 'Export output must be a structure.');
  assert(exist(export.condition_csv_processed, 'file') == 2, ...
    'Condition processed CSV was not created.');
  assert(exist(export.contrast_csv_processed, 'file') == 2, ...
    'Contrast processed CSV was not created.');
  assert(exist(export.condition_csv_figure, 'file') == 2, ...
    'Condition figure-data CSV was not created.');
  assert(exist(export.contrast_csv_figure, 'file') == 2, ...
    'Contrast figure-data CSV was not created.');
  assert(exist(export.handover_file, 'file') == 2, ...
    'Translation-grid handover file was not created.');

  assert(length(export.condition_rows) == 4, ...
    'Expected four condition rows.');
  assert(length(export.contrast_rows) == 5, ...
    'Expected five contrast rows.');
  assert(export.monotonic.RMST_monotonic_decreasing == 1, ...
    'Synthetic RMST should be monotonic decreasing.');
  assert(export.monotonic.T95_monotonic_decreasing == 1, ...
    'Synthetic T95 should be monotonic decreasing.');

  fprintf('test_translation_grid_exports passed.\n');
end


function TG = build_synthetic_translation_grid()
  config = struct();
  config.pi_values = [0.55, 0.60, 0.65, 0.70];
  config.condition_ids = {'BS_pi_055', 'BS_pi_060', 'BS_pi_065', 'BS_pi_070'};

  conditions = [];
  estimands = struct();
  results = struct();

  base_times = {
    [100; 110; 120; 130; 140; 150],
    [90; 100; 110; 120; 130; 140],
    [80; 90; 100; 110; 120; 130],
    [70; 80; 90; 100; 110; 120]
  };

  for i = 1:length(config.pi_values)
    C = struct();
    C.condition_id = config.condition_ids{i};
    C.architecture = 'boundary_spanning';
    C.P = struct();
    C.P.pi_out = 0.55;
    C.P.pi_BS = config.pi_values(i);

    if isempty(conditions)
      conditions = C;
    else
      conditions(end + 1) = C;
    end

    R = synthetic_results(base_times{i}, ones(6, 1), C.condition_id, C.P.pi_BS);
    results.(C.condition_id) = R;
    estimands.(C.condition_id) = compute_event_time_estimands(R);
  end

  bootstraps = struct();
  bootstraps.BS_pi_055_minus_BS_pi_060 = hierarchical_paired_bootstrap(
    results.BS_pi_055, results.BS_pi_060, 20, 81001);
  bootstraps.BS_pi_060_minus_BS_pi_065 = hierarchical_paired_bootstrap(
    results.BS_pi_060, results.BS_pi_065, 20, 81002);
  bootstraps.BS_pi_065_minus_BS_pi_070 = hierarchical_paired_bootstrap(
    results.BS_pi_065, results.BS_pi_070, 20, 81003);
  bootstraps.BS_pi_055_minus_BS_pi_065 = hierarchical_paired_bootstrap(
    results.BS_pi_055, results.BS_pi_065, 20, 81004);
  bootstraps.BS_pi_055_minus_BS_pi_070 = hierarchical_paired_bootstrap(
    results.BS_pi_055, results.BS_pi_070, 20, 81005);

  TG = struct();
  TG.run_type = 'translation_grid';
  TG.output_tag = 'translation_grid';
  TG.timestamp = 'synthetic_for_exports';
  TG.NG = 3;
  TG.NT = 2;
  TG.T_max = 1000;
  TG.n_boot = 20;
  TG.seed_base = 606000;
  TG.bootstrap_seed = 707000;
  TG.theta = 0.80;
  TG.q = 0.80;
  TG.pi_out = 0.55;
  TG.pi_BS_grid = config.pi_values;
  TG.conditions = conditions;
  TG.results = results;
  TG.estimands = estimands;
  TG.bootstraps = bootstraps;
  TG.alerts = {};
  TG.n_alerts = 0;
end


function R = synthetic_results(T_tilde, delta, condition_id, pi_BS)
  R.graph_id = [1; 1; 2; 2; 3; 3];
  R.trajectory_id = [1; 2; 1; 2; 1; 2];
  R.T_tilde = T_tilde(:);
  R.delta = delta(:);
  R.T = T_tilde(:);
  R.T(delta(:) == 0) = NaN;
  R.converged = delta(:);
  R.condition_id = condition_id;
  R.architecture = 'boundary_spanning';
  R.pi_out = 0.55 * ones(length(T_tilde), 1);
  R.pi_BS = pi_BS * ones(length(T_tilde), 1);
end
