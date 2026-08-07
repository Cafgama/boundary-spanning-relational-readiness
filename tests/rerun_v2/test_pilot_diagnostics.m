function test_pilot_diagnostics()
  % TEST_PILOT_DIAGNOSTICS
  % Tests the Step 10 diagnostic script using a synthetic processed pilot
  % file. This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  pilot_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'pilot');
  ensure_dir(pilot_dir);

  pilot = build_synthetic_pilot();

  synthetic_file = fullfile(pilot_dir, 'synthetic_production_pilot_processed_for_diagnostics.mat');
  save(synthetic_file, 'pilot');

  diagnostics = analyze_production_pilot(synthetic_file);

  assert(isstruct(diagnostics), 'Diagnostics output must be a structure.');
  assert(strcmp(diagnostics.run_type, 'production_pilot'), ...
    'Diagnostics run_type mismatch.');
  assert(isfield(diagnostics, 'conditions'), ...
    'Diagnostics must contain condition summaries.');
  assert(isfield(diagnostics.conditions, 'RB_low'), ...
    'Diagnostics missing RB_low condition.');
  assert(isfield(diagnostics.conditions, 'BS_high'), ...
    'Diagnostics missing BS_high condition.');
  assert(isfield(diagnostics, 'bootstraps'), ...
    'Diagnostics must contain bootstrap summaries.');
  assert(isfield(diagnostics.bootstraps, 'RB_low_minus_BS_high'), ...
    'Diagnostics missing RB_low_minus_BS_high contrast.');
  assert(isfield(diagnostics, 'alerts'), ...
    'Diagnostics must contain alerts field.');
  assert(exist(diagnostics.report_file, 'file') == 2, ...
    'Diagnostic report file was not created.');

  fprintf('test_pilot_diagnostics passed.\n');
end


function pilot = build_synthetic_pilot()
  % BUILD_SYNTHETIC_PILOT
  % Creates a small internally consistent production-pilot-like structure.

  RB = synthetic_results([100; 120; 140; 160; 180; 200], [1; 1; 1; 1; 1; 1]);
  BS_low = synthetic_results([110; 130; 150; 170; 190; 210], [1; 1; 1; 1; 1; 1]);
  BS_high = synthetic_results([80; 90; 100; 110; 120; 130], [1; 1; 1; 1; 1; 1]);

  estimands = struct();
  estimands.RB_low = compute_event_time_estimands(RB);
  estimands.BS_low = compute_event_time_estimands(BS_low);
  estimands.BS_high = compute_event_time_estimands(BS_high);

  bootstraps = struct();
  bootstraps.RB_low_minus_BS_low = hierarchical_paired_bootstrap(RB, BS_low, 20, 91001);
  bootstraps.BS_low_minus_BS_high = hierarchical_paired_bootstrap(BS_low, BS_high, 20, 91002);
  bootstraps.RB_low_minus_BS_high = hierarchical_paired_bootstrap(RB, BS_high, 20, 91003);

  pilot = struct();
  pilot.run_type = 'production_pilot';
  pilot.timestamp = 'synthetic_for_diagnostics';
  pilot.NG = 3;
  pilot.NT = 2;
  pilot.T_max = 1000;
  pilot.n_boot = 20;
  pilot.seed_base = 90000;
  pilot.bootstrap_seed = 91000;
  pilot.estimands = estimands;
  pilot.bootstraps = bootstraps;
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
end
