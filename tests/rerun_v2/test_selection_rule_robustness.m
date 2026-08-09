function test_selection_rule_robustness()
  % TEST_SELECTION_RULE_ROBUSTNESS
  % Runs a small selection-rule robustness pipeline to validate the Step 21
  % production script. This test is technical only and does not generate
  % manuscript results.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'selection_rule_test';
  config.output_tag = 'selection_rule_test';
  config.NG = 2;
  config.NT = 3;
  config.T_max = 2000;
  config.n_boot = 20;
  config.seed_base = 10010;
  config.bootstrap_seed = 11010;

  S = run_selection_rule_robustness(config);

  assert(isstruct(S), 'Selection-rule output must be a structure.');
  assert(strcmp(S.run_type, 'selection_rule_test'), 'run_type mismatch.');
  assert(S.NG == config.NG, 'NG mismatch.');
  assert(S.NT == config.NT, 'NT mismatch.');
  assert(S.T_max == config.T_max, 'T_max mismatch.');
  assert(S.n_boot == config.n_boot, 'n_boot mismatch.');

  expected_conditions = {
    'RB_low_agent_first',
    'RB_low_edge_uniform',
    'BS_low_agent_first',
    'BS_low_edge_uniform',
    'BS_high_agent_first',
    'BS_high_edge_uniform'
  };

  for i = 1:length(expected_conditions)
    cname = expected_conditions{i};
    assert(isfield(S.results, cname), ['Missing result condition: ', cname]);
    assert(isfield(S.estimands, cname), ['Missing estimand condition: ', cname]);

    R = S.results.(cname);
    assert(length(R.graph_id) == config.NG * config.NT, ...
      ['Unexpected trajectory count for ', cname]);
    assert(isfield(R, 'T_tilde'), ['Missing T_tilde for ', cname]);
    assert(isfield(R, 'delta'), ['Missing delta for ', cname]);
    assert(all(R.delta == 0 | R.delta == 1), ['Invalid delta values for ', cname]);
    assert(all(R.converged == R.delta), ['converged must equal delta for ', cname]);
  end

  expected_contrasts = {
    'RB_low_agent_first_minus_RB_low_edge_uniform',
    'BS_low_agent_first_minus_BS_low_edge_uniform',
    'BS_high_agent_first_minus_BS_high_edge_uniform',
    'RB_low_edge_uniform_minus_BS_low_edge_uniform',
    'BS_low_edge_uniform_minus_BS_high_edge_uniform',
    'RB_low_edge_uniform_minus_BS_high_edge_uniform'
  };

  for i = 1:length(expected_contrasts)
    bname = expected_contrasts{i};
    assert(isfield(S.bootstraps, bname), ['Missing bootstrap contrast: ', bname]);
    B = S.bootstraps.(bname);
    assert(B.n_boot == config.n_boot, ['n_boot mismatch for ', bname]);
    assert(B.n_graphs == config.NG, ['n_graphs mismatch for ', bname]);
  end

  assert(exist(S.raw_file, 'file') == 2, 'Raw file was not created.');
  assert(exist(S.processed_file, 'file') == 2, 'Processed file was not created.');
  assert(exist(S.manifest_file, 'file') == 2, 'Manifest file was not created.');

  fprintf('test_selection_rule_robustness passed.\n');
end
