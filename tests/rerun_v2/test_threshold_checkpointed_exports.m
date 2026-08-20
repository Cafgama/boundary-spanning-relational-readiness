function test_threshold_checkpointed_exports()
  % TEST_THRESHOLD_CHECKPOINTED_EXPORTS
  % Tests the Step 25 checkpointed-threshold export script using a synthetic
  % processed threshold_robustness file. This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'threshold_checkpoint_export_test');
  ensure_dir(processed_dir);

  threshold_robustness = build_synthetic_threshold_checkpointed();
  synthetic_file = fullfile(processed_dir, 'synthetic_threshold_checkpointed_processed_for_exports.mat');
  save(synthetic_file, 'threshold_robustness');

  exports = analyze_threshold_checkpointed_results(synthetic_file);

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
    'Threshold handover file was not created.');
  assert(length(exports.condition_rows) == 10, ...
    'Synthetic threshold export should contain ten condition rows.');
  assert(length(exports.contrast_rows) == 5, ...
    'Synthetic threshold export should contain five contrast rows.');
  assert(exports.diagnostic.translation_RMST_positive_all_scenarios == 1, ...
    'Synthetic threshold contrasts should all favor BS_high in RMST.');
  assert(exports.diagnostic.translation_T95_positive_estimable_scenarios == 1, ...
    'Synthetic threshold contrasts should all favor BS_high in T95.');

  fprintf('test_threshold_checkpointed_exports passed.\n');
end


function threshold_robustness = build_synthetic_threshold_checkpointed()
  NG = 2;
  NT = 2;
  T_max = 1000;
  pi_out = 0.55;
  pi_low = 0.55;
  pi_high = 0.65;

  scenarios = synthetic_scenarios();
  conditions = [];
  results = struct();
  estimands = struct();

  for s = 1:length(scenarios)
    S = scenarios(s);

    low_T = [500 + 40*s; 520 + 40*s; 540 + 40*s; 560 + 40*s];
    high_T = [300 + 25*s; 320 + 25*s; 340 + 25*s; 360 + 25*s];

    C_low = synthetic_condition(S, 'BS_low', pi_low, pi_out, T_max);
    C_high = synthetic_condition(S, 'BS_high', pi_high, pi_out, T_max);

    if isempty(conditions)
      conditions = C_low;
    else
      conditions(end + 1) = C_low;
    end
    conditions(end + 1) = C_high;

    R_low = synthetic_results(low_T, C_low);
    R_high = synthetic_results(high_T, C_high);

    results.(C_low.condition_id) = R_low;
    results.(C_high.condition_id) = R_high;
    estimands.(C_low.condition_id) = compute_event_time_estimands(R_low);
    estimands.(C_high.condition_id) = compute_event_time_estimands(R_high);
  end

  bootstraps = struct();
  for s = 1:length(scenarios)
    scenario_id = scenarios(s).scenario_id;
    x = [scenario_id, '_BS_low'];
    y = [scenario_id, '_BS_high'];
    contrast_id = [x, '_minus_', y];
    bootstraps.(contrast_id) = hierarchical_paired_bootstrap(results.(x), results.(y), 20, 140000 + s);
  end

  threshold_robustness = struct();
  threshold_robustness.run_type = 'threshold_robustness_checkpointed';
  threshold_robustness.output_tag = 'threshold_robustness_checkpointed';
  threshold_robustness.timestamp = 'synthetic_for_exports';
  threshold_robustness.NG = NG;
  threshold_robustness.NT = NT;
  threshold_robustness.T_max = T_max;
  threshold_robustness.n_boot = 20;
  threshold_robustness.seed_base = 1201000;
  threshold_robustness.bootstrap_seed = 1301000;
  threshold_robustness.pi_out = pi_out;
  threshold_robustness.pi_BS_low = pi_low;
  threshold_robustness.pi_BS_high = pi_high;
  threshold_robustness.scenarios = scenarios;
  threshold_robustness.conditions = conditions;
  threshold_robustness.results = results;
  threshold_robustness.estimands = estimands;
  threshold_robustness.bootstraps = bootstraps;
  threshold_robustness.alerts = {};
  threshold_robustness.n_alerts = 0;
  threshold_robustness.elapsed_seconds = 100;
  threshold_robustness.bootstrap_elapsed_seconds = 10;
  threshold_robustness.checkpoint_dir = 'synthetic_checkpoint_dir';
end


function scenarios = synthetic_scenarios()
  specs = {
    'easier_tie',      'Easier tie readiness',      0.75, 0.80;
    'baseline',        'Baseline',                  0.80, 0.80;
    'easier_boundary', 'Easier boundary readiness', 0.80, 0.70;
    'harder_boundary', 'Harder boundary readiness', 0.80, 0.90;
    'harder_tie',      'Harder tie readiness',      0.85, 0.80
  };

  scenarios = [];
  for i = 1:size(specs, 1)
    S = struct();
    S.scenario_id = specs{i, 1};
    S.scenario_label = specs{i, 2};
    S.theta = specs{i, 3};
    S.q = specs{i, 4};
    if isempty(scenarios)
      scenarios = S;
    else
      scenarios(end + 1) = S;
    end
  end
end


function C = synthetic_condition(S, translation_level, pi_BS, pi_out, T_max)
  C = struct();
  C.condition_id = [S.scenario_id, '_', translation_level];
  C.scenario_id = S.scenario_id;
  C.scenario_label = S.scenario_label;
  C.architecture = 'boundary_spanning';
  C.translation_level = translation_level;
  C.P = synthetic_params(S.theta, S.q, pi_BS, pi_out, T_max);
end


function P = synthetic_params(theta, q, pi_BS, pi_out, T_max)
  P = struct();
  P.theta = theta;
  P.q = q;
  P.pi_BS = pi_BS;
  P.pi_out = pi_out;
  P.b = 2;
  P.T_max = T_max;
end


function R = synthetic_results(T_tilde, C)
  n = length(T_tilde);
  R.graph_id = [1; 1; 2; 2];
  R.trajectory_id = [1; 2; 1; 2];
  R.network_seed = [1; 1; 2; 2];
  R.trajectory_seed = [101; 102; 201; 202];
  R.T = T_tilde(:);
  R.T_tilde = T_tilde(:);
  R.delta = ones(n, 1);
  R.converged = ones(n, 1);
  R.final_RB = ones(n, 1);
  R.final_ready = ones(n, 1);
  R.total_boundary_edges = 12 * ones(n, 1);
  R.pi_BS = C.P.pi_BS * ones(n, 1);
  R.pi_out = C.P.pi_out * ones(n, 1);
  R.b = C.P.b * ones(n, 1);
  R.theta = C.P.theta * ones(n, 1);
  R.q = C.P.q * ones(n, 1);
  R.T_max = C.P.T_max * ones(n, 1);
  R.workload_mean = 3 * ones(n, 1);
  R.workload_min = 3 * ones(n, 1);
  R.workload_max = 3 * ones(n, 1);
  R.workload_sd = zeros(n, 1);
  R.condition_id = C.condition_id;
  R.scenario_id = C.scenario_id;
  R.architecture = C.architecture;
  R.selection_rule = 'agent_first';
end
