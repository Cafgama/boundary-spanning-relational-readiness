function test_final_core_production()
  % TEST_FINAL_CORE_PRODUCTION
  % Runs a tiny final-core pipeline test. This is not the final production
  % run. It validates that the final-core script can run with a small config,
  % save versioned files, and return the expected structures.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'final_core_test';
  config.output_tag = 'final_core_test';
  config.NG = 2;
  config.NT = 3;
  config.T_max = 2000;
  config.n_boot = 20;
  config.seed_base = 606000;
  config.bootstrap_seed = 707000;

  final_core = run_final_core_production(config);

  assert(isstruct(final_core), 'final_core output must be a structure.');
  assert(strcmp(final_core.run_type, 'final_core_test'), 'run_type mismatch.');
  assert(strcmp(final_core.output_tag, 'final_core_test'), 'output_tag mismatch.');
  assert(final_core.NG == 2, 'NG mismatch.');
  assert(final_core.NT == 3, 'NT mismatch.');
  assert(final_core.T_max == 2000, 'T_max mismatch.');
  assert(final_core.n_boot == 20, 'n_boot mismatch.');

  assert(isfield(final_core.results, 'RB_low'), 'Missing RB_low results.');
  assert(isfield(final_core.results, 'BS_low'), 'Missing BS_low results.');
  assert(isfield(final_core.results, 'BS_high'), 'Missing BS_high results.');

  validate_condition(final_core.results.RB_low, 6);
  validate_condition(final_core.results.BS_low, 6);
  validate_condition(final_core.results.BS_high, 6);

  assert(isfield(final_core.estimands, 'RB_low'), 'Missing RB_low estimands.');
  assert(isfield(final_core.bootstraps, 'RB_low_minus_BS_high'), ...
    'Missing RB_low_minus_BS_high bootstrap.');

  assert(exist(final_core.raw_file, 'file') == 2, 'Raw output file was not created.');
  assert(exist(final_core.processed_file, 'file') == 2, ...
    'Processed output file was not created.');
  assert(exist(final_core.manifest_file, 'file') == 2, ...
    'Manifest output file was not created.');

  assert(~isempty(strfind(final_core.raw_file, fullfile('rerun_v2', 'final_core_test'))), ...
    'Raw file must be written under rerun_v2/final_core_test.');
  assert(~isempty(strfind(final_core.processed_file, fullfile('rerun_v2', 'final_core_test'))), ...
    'Processed file must be written under rerun_v2/final_core_test.');

  fprintf('test_final_core_production passed.\n');
end


function validate_condition(R, expected_n)
  assert(length(R.graph_id) == expected_n, 'graph_id length mismatch.');
  assert(length(R.trajectory_id) == expected_n, 'trajectory_id length mismatch.');
  assert(length(R.T_tilde) == expected_n, 'T_tilde length mismatch.');
  assert(length(R.delta) == expected_n, 'delta length mismatch.');
  assert(all(~isnan(R.T_tilde)), 'T_tilde cannot contain NaN.');
  assert(all(R.delta == 0 | R.delta == 1), 'delta must contain only 0 or 1.');
  assert(all(R.converged == R.delta), 'converged must equal delta.');
end
