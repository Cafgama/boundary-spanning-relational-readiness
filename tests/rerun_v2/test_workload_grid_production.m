function test_workload_grid_production()
  % TEST_WORKLOAD_GRID_PRODUCTION
  % Smoke-tests the Step 18 workload-grid production pipeline using a tiny
  % configuration. This test is not a manuscript result.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'workload_grid_test';
  config.output_tag = 'workload_grid_test';
  config.NG = 2;
  config.NT = 3;
  config.T_max = 2000;
  config.n_boot = 20;
  config.b_grid = [1, 2, 4];
  config.seed_base = 808;
  config.bootstrap_seed = 909;

  workload_grid = run_workload_grid_production(config);

  assert(isstruct(workload_grid), 'workload_grid output must be a structure.');
  assert(strcmp(workload_grid.run_type, 'workload_grid_test'), ...
    'Unexpected workload_grid.run_type.');
  assert(strcmp(workload_grid.output_tag, 'workload_grid_test'), ...
    'Unexpected workload_grid.output_tag.');
  assert(workload_grid.NG == config.NG, 'NG mismatch.');
  assert(workload_grid.NT == config.NT, 'NT mismatch.');
  assert(workload_grid.n_boot == config.n_boot, 'n_boot mismatch.');
  assert(length(workload_grid.conditions) == length(config.b_grid), ...
    'Unexpected number of workload-grid conditions.');

  expected_conditions = {'BS_b_01', 'BS_b_02', 'BS_b_04'};
  for i = 1:length(expected_conditions)
    cname = expected_conditions{i};
    assert(isfield(workload_grid.results, cname), ['Missing results for ', cname]);
    assert(isfield(workload_grid.estimands, cname), ['Missing estimands for ', cname]);

    R = workload_grid.results.(cname);
    expected_n = config.NG * config.NT;

    assert(length(R.T_tilde) == expected_n, ['Unexpected T_tilde length for ', cname]);
    assert(length(R.delta) == expected_n, ['Unexpected delta length for ', cname]);
    assert(all(R.delta == 0 | R.delta == 1), ['delta must be 0/1 for ', cname]);
    assert(all(R.converged == R.delta), ['converged must equal delta for ', cname]);
    assert(all(R.b == config.b_grid(i)), ['b value mismatch for ', cname]);
  end

  assert(isfield(workload_grid.bootstraps, 'BS_b_01_minus_BS_b_02'), ...
    'Missing adjacent contrast BS_b_01_minus_BS_b_02.');
  assert(isfield(workload_grid.bootstraps, 'BS_b_02_minus_BS_b_04'), ...
    'Missing adjacent contrast BS_b_02_minus_BS_b_04.');
  assert(isfield(workload_grid.bootstraps, 'BS_b_01_minus_BS_b_04'), ...
    'Missing first-to-later contrast BS_b_01_minus_BS_b_04.');

  assert(exist(workload_grid.raw_file, 'file') == 2, 'Raw file was not created.');
  assert(exist(workload_grid.processed_file, 'file') == 2, 'Processed file was not created.');
  assert(exist(workload_grid.manifest_file, 'file') == 2, 'Manifest file was not created.');

  fprintf('test_workload_grid_production passed.\n');
end
