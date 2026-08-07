function test_high_horizon_pilot()
  % TEST_HIGH_HORIZON_PILOT
  % Runs and validates the Step 11 high-horizon pilot.
  %
  % This test executes a medium-small simulation:
  %   3 conditions * 10 graphs * 20 trajectories, T_max = 50000.
  % It can take longer than earlier rerun_v2 tests.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  pilot = run_high_horizon_pilot();

  assert(isstruct(pilot), 'High-horizon pilot output must be a structure.');
  assert(strcmp(pilot.run_type, 'high_horizon_pilot'), ...
    'High-horizon pilot run_type mismatch.');

  assert(pilot.NG == 10, 'High-horizon pilot NG must be 10.');
  assert(pilot.NT == 20, 'High-horizon pilot NT must be 20.');
  assert(pilot.T_max == 50000, 'High-horizon pilot T_max must be 50000.');
  assert(pilot.n_boot == 500, 'High-horizon pilot n_boot must be 500.');

  assert(isfield(pilot.results, 'RB_low'), 'Missing RB_low results.');
  assert(isfield(pilot.results, 'BS_low'), 'Missing BS_low results.');
  assert(isfield(pilot.results, 'BS_high'), 'Missing BS_high results.');

  validate_high_horizon_condition_for_test(pilot.results.RB_low, pilot.NG, pilot.NT);
  validate_high_horizon_condition_for_test(pilot.results.BS_low, pilot.NG, pilot.NT);
  validate_high_horizon_condition_for_test(pilot.results.BS_high, pilot.NG, pilot.NT);

  assert(isfield(pilot.estimands, 'RB_low'), 'Missing RB_low estimands.');
  assert(isfield(pilot.estimands, 'BS_low'), 'Missing BS_low estimands.');
  assert(isfield(pilot.estimands, 'BS_high'), 'Missing BS_high estimands.');

  assert(isfield(pilot.bootstraps, 'RB_low_minus_BS_low'), ...
    'Missing RB_low_minus_BS_low bootstrap.');
  assert(isfield(pilot.bootstraps, 'BS_low_minus_BS_high'), ...
    'Missing BS_low_minus_BS_high bootstrap.');
  assert(isfield(pilot.bootstraps, 'RB_low_minus_BS_high'), ...
    'Missing RB_low_minus_BS_high bootstrap.');

  assert(isfield(pilot, 'alerts'), 'Pilot must contain alerts field.');
  assert(isfield(pilot, 'n_alerts'), 'Pilot must contain n_alerts field.');
  assert(pilot.n_alerts == length(pilot.alerts), ...
    'n_alerts must match alerts length.');

  assert(exist(pilot.raw_file, 'file') == 2, 'High-horizon raw file was not saved.');
  assert(exist(pilot.processed_file, 'file') == 2, ...
    'High-horizon processed file was not saved.');
  assert(exist(pilot.manifest_file, 'file') == 2, ...
    'High-horizon manifest file was not saved.');

  assert(~isempty(strfind(pilot.raw_file, fullfile('results', 'raw', 'rerun_v2', 'high_horizon_pilot'))), ...
    'High-horizon raw file must be saved under results/raw/rerun_v2/high_horizon_pilot.');

  assert(~isempty(strfind(pilot.processed_file, fullfile('results', 'processed', 'rerun_v2', 'high_horizon_pilot'))), ...
    'High-horizon processed file must be saved under results/processed/rerun_v2/high_horizon_pilot.');

  fprintf('test_high_horizon_pilot passed.\n');
end


function validate_high_horizon_condition_for_test(R, NG, NT)
  n = NG * NT;

  assert(length(R.graph_id) == n, 'graph_id length mismatch.');
  assert(length(R.trajectory_id) == n, 'trajectory_id length mismatch.');
  assert(length(R.T_tilde) == n, 'T_tilde length mismatch.');
  assert(length(R.delta) == n, 'delta length mismatch.');
  assert(length(R.converged) == n, 'converged length mismatch.');

  assert(all(~isnan(R.T_tilde)), 'T_tilde cannot contain NaN.');
  assert(all(R.delta == 0 | R.delta == 1), 'delta must contain only zero or one.');
  assert(all(R.converged == R.delta), 'converged must equal delta.');
  assert(all(R.T_max == 50000), 'All trajectories must have T_max = 50000.');
end
