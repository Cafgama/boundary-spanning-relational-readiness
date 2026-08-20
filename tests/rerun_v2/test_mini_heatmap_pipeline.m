function test_mini_heatmap_pipeline()
  % TEST_MINI_HEATMAP_PIPELINE
  % Runs a very small 2x2 mini-heatmap pipeline to validate production,
  % analysis, CSV export, and handover creation. This is not a scientific run.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'mini_heatmap_test';
  config.output_tag = 'mini_heatmap_test';
  config.NG = 2;
  config.NT = 2;
  config.T_max = 2000;
  config.pi_BS_grid = [0.55, 0.70];
  config.b_grid = [1, 2];
  config.seed_base = 1411000;

  mini_heatmap = run_mini_heatmap_production(config);

  assert(isstruct(mini_heatmap), 'mini_heatmap output must be a structure.');
  assert(length(mini_heatmap.conditions) == 4, 'Test mini heatmap should have four cells.');
  assert(exist(mini_heatmap.processed_file, 'file') == 2, ...
    'Mini heatmap processed file was not created.');
  assert(exist(mini_heatmap.raw_file, 'file') == 2, ...
    'Mini heatmap raw file was not created.');
  assert(exist(mini_heatmap.manifest_file, 'file') == 2, ...
    'Mini heatmap manifest file was not created.');

  exports = analyze_mini_heatmap_results(mini_heatmap.processed_file);

  assert(isstruct(exports), 'Mini heatmap exports must be a structure.');
  assert(length(exports.condition_rows) == 4, 'Export should contain four condition rows.');
  assert(all(size(exports.matrices.RMST_matrix) == [2, 2]), ...
    'RMST matrix should be 2x2 in the test run.');
  assert(exist(exports.condition_csv_processed, 'file') == 2, ...
    'Condition estimates CSV was not created.');
  assert(exist(exports.rmst_matrix_csv_processed, 'file') == 2, ...
    'RMST matrix CSV was not created.');
  assert(exist(exports.t95_matrix_csv_processed, 'file') == 2, ...
    'T95 matrix CSV was not created.');
  assert(exist(exports.readiness_matrix_csv_processed, 'file') == 2, ...
    'Readiness matrix CSV was not created.');
  assert(exist(exports.handover_file, 'file') == 2, ...
    'Mini heatmap handover file was not created.');

  assert_no_duplicate_rows({exports.condition_rows.condition_id});

  expected_load_b1 = 6.0;
  expected_load_b2 = 3.0;
  loads = [exports.condition_rows.load_per_spanner];
  assert(any(abs(loads - expected_load_b1) < 1e-9), 'Missing expected b=1 load.');
  assert(any(abs(loads - expected_load_b2) < 1e-9), 'Missing expected b=2 load.');

  fprintf('test_mini_heatmap_pipeline passed.\n');
end
