function test_production_pilot()
  % TEST_PRODUCTION_PILOT
  % Runs and validates the rerun_v2 production pilot pipeline.

  setup_rerun_v2_tests();

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  pilot = run_production_pilot();

  assert(isstruct(pilot), 'pilot must be a structure.');
  assert(strcmp(pilot.run_type, 'production_pilot'), 'Unexpected run_type.');

  assert(pilot.NG == 10, 'Pilot NG must be 10.');
  assert(pilot.NT == 20, 'Pilot NT must be 20.');
  assert(pilot.T_max == 10000, 'Pilot T_max must be 10000.');
  assert(pilot.n_boot == 500, 'Pilot n_boot must be 500.');

  assert(isfield(pilot.results, 'RB_low'), 'Missing RB_low results.');
  assert(isfield(pilot.results, 'BS_low'), 'Missing BS_low results.');
  assert(isfield(pilot.results, 'BS_high'), 'Missing BS_high results.');

  validate_pilot_condition(pilot.results.RB_low, pilot.NG, pilot.NT);
  validate_pilot_condition(pilot.results.BS_low, pilot.NG, pilot.NT);
  validate_pilot_condition(pilot.results.BS_high, pilot.NG, pilot.NT);

  assert(isfield(pilot.estimands, 'RB_low'), 'Missing RB_low estimands.');
  assert(isfield(pilot.estimands, 'BS_low'), 'Missing BS_low estimands.');
  assert(isfield(pilot.estimands, 'BS_high'), 'Missing BS_high estimands.');

  assert(isfield(pilot.bootstraps, 'RB_low_minus_BS_low'), ...
    'Missing RB_low_minus_BS_low bootstrap.');
  assert(isfield(pilot.bootstraps, 'BS_low_minus_BS_high'), ...
    'Missing BS_low_minus_BS_high bootstrap.');
  assert(isfield(pilot.bootstraps, 'RB_low_minus_BS_high'), ...
    'Missing RB_low_minus_BS_high bootstrap.');

  assert(exist(pilot.raw_file, 'file') == 2, 'Pilot raw file was not created.');
  assert(exist(pilot.processed_file, 'file') == 2, 'Pilot processed file was not created.');
  assert(exist(pilot.manifest_file, 'file') == 2, 'Pilot manifest file was not created.');

  assert(~isempty(strfind(pilot.raw_file, fullfile('results', 'raw', 'rerun_v2', 'pilot'))), ...
    'Pilot raw file must be under results/raw/rerun_v2/pilot.');

  assert(~isempty(strfind(pilot.processed_file, fullfile('results', 'processed', 'rerun_v2', 'pilot'))), ...
    'Pilot processed file must be under results/processed/rerun_v2/pilot.');

  fprintf('test_production_pilot passed.\n');
end


function validate_pilot_condition(R, NG, NT)
  n = NG * NT;

  assert(length(R.graph_id) == n, 'graph_id length mismatch.');
  assert(length(R.trajectory_id) == n, 'trajectory_id length mismatch.');
  assert(length(R.T_tilde) == n, 'T_tilde length mismatch.');
  assert(length(R.delta) == n, 'delta length mismatch.');

  assert(all(~isnan(R.T_tilde)), 'T_tilde cannot contain NaN.');
  assert(all(R.T_tilde >= 0), 'T_tilde must be non-negative.');
  assert(all(R.delta == 0 | R.delta == 1), 'delta must contain only 0 or 1.');
  assert(all(R.converged == R.delta), 'converged must equal delta.');

  for g = 1:NG
    assert(sum(R.graph_id == g) == NT, 'Each graph must contain NT trajectories.');
  end

  for tr = 1:NT
    assert(sum(R.trajectory_id == tr) == NG, ...
      'Each trajectory id must appear once per graph.');
  end
end
