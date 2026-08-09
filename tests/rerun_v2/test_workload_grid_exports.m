function test_workload_grid_exports()
  % TEST_WORKLOAD_GRID_EXPORTS
  % Tests Step 19 workload-grid export script using a synthetic processed file.
  % This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'workload_grid');
  ensure_dir(processed_dir);

  workload_grid = build_synthetic_workload_grid();

  synthetic_file = fullfile(processed_dir, 'synthetic_workload_grid_processed_for_exports.mat');
  save(synthetic_file, 'workload_grid');

  exports = analyze_workload_grid_results(synthetic_file);

  assert(isstruct(exports), 'Exports output must be a structure.');
  assert(exist(exports.condition_csv_processed, 'file') == 2, ...
    'Condition CSV was not created.');
  assert(exist(exports.contrast_csv_processed, 'file') == 2, ...
    'Contrast CSV was not created.');
  assert(exist(exports.condition_csv_figure, 'file') == 2, ...
    'Figure-data condition CSV was not created.');
  assert(exist(exports.contrast_csv_figure, 'file') == 2, ...
    'Figure-data contrast CSV was not created.');
  assert(exist(exports.handover_file, 'file') == 2, ...
    'Workload-grid handover file was not created.');

  assert(isfield(exports, 'monotonic'), 'Exports missing monotonic field.');
  assert(exports.monotonic.RMST_monotonic_decreasing == 1, ...
    'Synthetic workload RMST should be monotonic decreasing.');
  assert(exports.monotonic.T95_monotonic_decreasing == 1, ...
    'Synthetic workload T95 should be monotonic decreasing.');
  assert(exports.n_alerts == 0, 'Synthetic workload export should not have alerts.');

  assert(length(exports.condition_rows) == 4, ...
    'Expected four synthetic workload condition rows.');
  assert(length(exports.contrast_rows) == 5, ...
    'Expected five synthetic workload contrast rows.');

  fprintf('test_workload_grid_exports passed.\n');
end


function workload_grid = build_synthetic_workload_grid()
  b_grid = [1, 2, 4, 6];
  ids = {'BS_b_01', 'BS_b_02', 'BS_b_04', 'BS_b_06'};

  base_times = {
    [100; 110; 120; 130; 140; 150],
    [90; 100; 110; 120; 130; 140],
    [80; 90; 100; 110; 120; 130],
    [70; 80; 90; 100; 110; 120]
  };

  conditions = [];
  results = struct();
  estimands = struct();

  for i = 1:length(b_grid)
    C = struct();
    C.condition_id = ids{i};
    C.architecture = 'boundary_spanning';
    C.P = struct();
    C.P.b = b_grid(i);
    C.P.k = 12;
    C.P.pi_out = 0.55;
    C.P.pi_BS = 0.65;
    C.load_per_spanner = C.P.k / (2 * C.P.b);

    if isempty(conditions)
      conditions = C;
    else
      conditions(end + 1) = C;
    end

    R = synthetic_workload_results(base_times{i}, b_grid(i), C.load_per_spanner);
    results.(ids{i}) = R;
    estimands.(ids{i}) = compute_event_time_estimands(R);
  end

  bootstraps = struct();
  bootstraps.BS_b_01_minus_BS_b_02 = hierarchical_paired_bootstrap(
    results.BS_b_01, results.BS_b_02, 20, 111001);
  bootstraps.BS_b_02_minus_BS_b_04 = hierarchical_paired_bootstrap(
    results.BS_b_02, results.BS_b_04, 20, 111002);
  bootstraps.BS_b_04_minus_BS_b_06 = hierarchical_paired_bootstrap(
    results.BS_b_04, results.BS_b_06, 20, 111003);
  bootstraps.BS_b_01_minus_BS_b_04 = hierarchical_paired_bootstrap(
    results.BS_b_01, results.BS_b_04, 20, 111004);
  bootstraps.BS_b_01_minus_BS_b_06 = hierarchical_paired_bootstrap(
    results.BS_b_01, results.BS_b_06, 20, 111005);

  workload_grid = struct();
  workload_grid.run_type = 'workload_grid';
  workload_grid.output_tag = 'workload_grid';
  workload_grid.timestamp = 'synthetic_for_exports';
  workload_grid.NG = 3;
  workload_grid.NT = 2;
  workload_grid.T_max = 1000;
  workload_grid.n_boot = 20;
  workload_grid.seed_base = 808000;
  workload_grid.bootstrap_seed = 909000;
  workload_grid.theta = 0.80;
  workload_grid.q = 0.80;
  workload_grid.pi_out = 0.55;
  workload_grid.pi_BS = 0.65;
  workload_grid.b_grid = b_grid;
  workload_grid.conditions = conditions;
  workload_grid.results = results;
  workload_grid.estimands = estimands;
  workload_grid.bootstraps = bootstraps;
  workload_grid.alerts = {};
  workload_grid.n_alerts = 0;
  workload_grid.elapsed_seconds = 1.0;
  workload_grid.bootstrap_elapsed_seconds = 1.0;
end


function R = synthetic_workload_results(T_tilde, b, load_per_spanner)
  n = length(T_tilde);

  R.graph_id = [1; 1; 2; 2; 3; 3];
  R.trajectory_id = [1; 2; 1; 2; 1; 2];
  R.network_seed = (1:n)';
  R.trajectory_seed = (101:(100 + n))';
  R.T_tilde = T_tilde(:);
  R.delta = ones(n, 1);
  R.T = T_tilde(:);
  R.converged = ones(n, 1);
  R.final_RB = ones(n, 1);
  R.final_ready = ones(n, 1);
  R.total_boundary_edges = 12 * ones(n, 1);
  R.pi_BS = 0.65 * ones(n, 1);
  R.pi_out = 0.55 * ones(n, 1);
  R.b = b * ones(n, 1);
  R.load_per_spanner = load_per_spanner * ones(n, 1);
  R.theta = 0.80 * ones(n, 1);
  R.q = 0.80 * ones(n, 1);
  R.T_max = 1000 * ones(n, 1);
  R.workload_mean = load_per_spanner * ones(n, 1);
  R.workload_min = floor(load_per_spanner) * ones(n, 1);
  R.workload_max = ceil(load_per_spanner) * ones(n, 1);
  R.workload_sd = zeros(n, 1);
  R.condition_id = 'synthetic';
  R.architecture = 'boundary_spanning';
  R.selection_rule = 'agent_first';
end
