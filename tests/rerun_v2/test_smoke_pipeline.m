function test_smoke_pipeline()
  % TEST_SMOKE_PIPELINE
  % Runs the small rerun_v2 end-to-end smoke pipeline and validates outputs.

  setup_rerun_v2_tests();

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  smoke = run_smoke_pipeline();

  assert(isstruct(smoke), 'Smoke output must be a structure.');

  assert(isfield(smoke, 'raw_file'), 'Smoke output must contain raw_file.');
  assert(isfield(smoke, 'processed_file'), 'Smoke output must contain processed_file.');
  assert(isfield(smoke, 'manifest_file'), 'Smoke output must contain manifest_file.');

  assert(exist(smoke.raw_file, 'file') == 2, ...
    'Smoke raw output file was not created.');

  assert(exist(smoke.processed_file, 'file') == 2, ...
    'Smoke processed output file was not created.');

  assert(exist(smoke.manifest_file, 'file') == 2, ...
    'Smoke manifest file was not created.');

  assert(~isempty(strfind(smoke.raw_file, fullfile('results', 'raw', 'rerun_v2'))), ...
    'Smoke raw output must be inside results/raw/rerun_v2.');

  assert(~isempty(strfind(smoke.processed_file, fullfile('results', 'processed', 'rerun_v2'))), ...
    'Smoke processed output must be inside results/processed/rerun_v2.');

  validate_smoke_result_structure(smoke.results_RB, 'RB_low');
  validate_smoke_result_structure(smoke.results_BS, 'BS_high');

  assert(isfield(smoke.S_RB, 'rmst'), 'S_RB must contain rmst.');
  assert(isfield(smoke.S_BS, 'rmst'), 'S_BS must contain rmst.');

  assert(isfield(smoke.bootstrap, 'observed_difference'), ...
    'Bootstrap output must contain observed_difference.');

  assert(smoke.bootstrap.n_boot == 50, ...
    'Smoke bootstrap should use 50 replications.');

  assert(smoke.bootstrap.n_graphs == 3, ...
    'Smoke bootstrap should use 3 matched graphs.');

  assert(smoke.bootstrap.n_matched_trajectories == 12, ...
    'Smoke bootstrap should use 12 matched trajectories.');

  fprintf('test_smoke_pipeline passed.\n');
end


function validate_smoke_result_structure(R, condition_id)
  required_fields = {
    'graph_id',
    'trajectory_id',
    'network_seed',
    'trajectory_seed',
    'T',
    'T_tilde',
    'delta',
    'converged',
    'final_RB',
    'final_ready',
    'total_boundary_edges'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(R, fname), ['Missing smoke result field: ', fname]);
  end

  assert(strcmp(R.condition_id, condition_id), ...
    'Unexpected smoke result condition_id.');

  assert(length(R.T_tilde) == 12, ...
    'Smoke condition should contain 12 trajectories.');

  assert(all(~isnan(R.T_tilde)), ...
    'T_tilde cannot contain NaN.');

  assert(all(isfinite(R.T_tilde)), ...
    'T_tilde must be finite.');

  assert(all(R.delta == 0 | R.delta == 1), ...
    'delta must contain only 0 or 1.');

  assert(all(R.converged == R.delta), ...
    'converged must equal delta.');
end
