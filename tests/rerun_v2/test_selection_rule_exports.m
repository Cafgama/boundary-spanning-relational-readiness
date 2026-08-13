function test_selection_rule_exports()
  % TEST_SELECTION_RULE_EXPORTS
  % Tests the Step 22 selection-rule robustness export script using a
  % synthetic processed selection_rule file. This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'selection_rule_robustness');
  ensure_dir(processed_dir);

  selection_rule = build_synthetic_selection_rule();

  synthetic_file = fullfile(processed_dir, 'synthetic_selection_rule_processed_for_exports.mat');
  save(synthetic_file, 'selection_rule');

  exports = analyze_selection_rule_results(synthetic_file);

  assert(isstruct(exports), 'Exports output must be a structure.');
  assert(exports.n_alerts == 0, 'Synthetic export should not raise alerts.');
  assert(exist(exports.condition_csv_processed, 'file') == 2, ...
    'Condition CSV was not created.');
  assert(exist(exports.contrast_csv_processed, 'file') == 2, ...
    'Contrast CSV was not created.');
  assert(exist(exports.condition_csv_figure, 'file') == 2, ...
    'Figure-data condition CSV was not created.');
  assert(exist(exports.contrast_csv_figure, 'file') == 2, ...
    'Figure-data contrast CSV was not created.');
  assert(exist(exports.handover_file, 'file') == 2, ...
    'Selection-rule handover file was not created.');
  assert(length(exports.condition_rows) == 6, ...
    'Synthetic selection-rule export should contain six condition rows.');
  assert(length(exports.contrast_rows) == 6, ...
    'Synthetic selection-rule export should contain six contrast rows.');

  fprintf('test_selection_rule_exports passed.\n');
end


function selection_rule = build_synthetic_selection_rule()
  NG = 2;
  NT = 2;
  T_max = 1000;

  specs = {
    'RB_low_agent_first', 'random_bridging', 'agent_first', 0.55, [500; 520; 540; 560];
    'RB_low_edge_uniform', 'random_bridging', 'edge_uniform', 0.55, [440; 460; 480; 500];
    'BS_low_agent_first', 'boundary_spanning', 'agent_first', 0.55, [620; 640; 660; 680];
    'BS_low_edge_uniform', 'boundary_spanning', 'edge_uniform', 0.55, [445; 465; 485; 505];
    'BS_high_agent_first', 'boundary_spanning', 'agent_first', 0.65, [300; 320; 340; 360];
    'BS_high_edge_uniform', 'boundary_spanning', 'edge_uniform', 0.65, [240; 260; 280; 300]
  };

  conditions = [];
  results = struct();
  estimands = struct();

  for i = 1:size(specs, 1)
    C = struct();
    C.condition_id = specs{i, 1};
    C.architecture = specs{i, 2};
    C.selection_rule = specs{i, 3};
    C.P = synthetic_params(specs{i, 4}, T_max);

    if isempty(conditions)
      conditions = C;
    else
      conditions(end + 1) = C;
    end

    R = synthetic_results(specs{i, 5}, C.condition_id, C.architecture, C.selection_rule, C.P);
    results.(C.condition_id) = R;
    estimands.(C.condition_id) = compute_event_time_estimands(R);
  end

  pairs = {
    'RB_low_agent_first', 'RB_low_edge_uniform';
    'BS_low_agent_first', 'BS_low_edge_uniform';
    'BS_high_agent_first', 'BS_high_edge_uniform';
    'RB_low_edge_uniform', 'BS_low_edge_uniform';
    'BS_low_edge_uniform', 'BS_high_edge_uniform';
    'RB_low_edge_uniform', 'BS_high_edge_uniform'
  };

  bootstraps = struct();
  for i = 1:size(pairs, 1)
    x = pairs{i, 1};
    y = pairs{i, 2};
    contrast_id = [x, '_minus_', y];
    bootstraps.(contrast_id) = hierarchical_paired_bootstrap(
      results.(x), results.(y), 20, 120000 + i);
  end

  selection_rule = struct();
  selection_rule.run_type = 'selection_rule_robustness';
  selection_rule.output_tag = 'selection_rule_robustness';
  selection_rule.timestamp = 'synthetic_for_exports';
  selection_rule.NG = NG;
  selection_rule.NT = NT;
  selection_rule.T_max = T_max;
  selection_rule.n_boot = 20;
  selection_rule.seed_base = 1001000;
  selection_rule.bootstrap_seed = 1101000;
  selection_rule.theta = 0.80;
  selection_rule.q = 0.80;
  selection_rule.pi_out = 0.55;
  selection_rule.pi_BS_low = 0.55;
  selection_rule.pi_BS_high = 0.65;
  selection_rule.conditions = conditions;
  selection_rule.results = results;
  selection_rule.estimands = estimands;
  selection_rule.bootstraps = bootstraps;
  selection_rule.alerts = {};
  selection_rule.n_alerts = 0;
end


function P = synthetic_params(pi_BS, T_max)
  P = struct();
  P.pi_out = 0.55;
  P.pi_BS = pi_BS;
  P.b = 2;
  P.theta = 0.80;
  P.q = 0.80;
  P.T_max = T_max;
end


function R = synthetic_results(T_tilde, condition_id, architecture, selection_rule, P)
  n = length(T_tilde);

  R.graph_id = [1; 1; 2; 2];
  R.trajectory_id = [1; 2; 1; 2];
  R.network_seed = [1; 1; 2; 2];
  R.trajectory_seed = [101; 102; 201; 202];
  R.T_tilde = T_tilde(:);
  R.delta = ones(n, 1);
  R.T = T_tilde(:);
  R.converged = ones(n, 1);
  R.final_RB = ones(n, 1);
  R.final_ready = ones(n, 1);
  R.total_boundary_edges = 12 * ones(n, 1);
  R.pi_BS = P.pi_BS * ones(n, 1);
  R.pi_out = P.pi_out * ones(n, 1);
  R.b = P.b * ones(n, 1);
  R.theta = P.theta * ones(n, 1);
  R.q = P.q * ones(n, 1);
  R.T_max = P.T_max * ones(n, 1);
  R.workload_mean = 3 * ones(n, 1);
  R.workload_min = 3 * ones(n, 1);
  R.workload_max = 3 * ones(n, 1);
  R.workload_sd = zeros(n, 1);
  R.condition_id = condition_id;
  R.architecture = architecture;
  R.selection_rule = selection_rule;
end
