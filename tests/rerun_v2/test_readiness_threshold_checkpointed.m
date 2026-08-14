function test_readiness_threshold_checkpointed()
  % TEST_READINESS_THRESHOLD_CHECKPOINTED
  % Runs a very small checkpointed threshold-robustness pipeline and verifies
  % that scenario checkpoints, bootstrap checkpoints, and final outputs are
  % created. This is a code-path test, not a scientific result.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'threshold_checkpoint_test';
  config.output_tag = 'threshold_checkpoint_test';
  config.NG = 1;
  config.NT = 2;
  config.T_max = 2000;
  config.n_boot = 10;
  config.seed_base = 2201000;
  config.bootstrap_seed = 2301000;

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', config.output_tag);
  checkpoint_dir = fullfile(processed_dir, 'checkpoints');

  % Keep the test deterministic and avoid accidentally reusing an old failed
  % checkpoint from a previous test run.
  if exist(checkpoint_dir, 'dir') == 7
    delete(fullfile(checkpoint_dir, '*.mat'));
  end

  threshold_robustness = run_readiness_threshold_checkpointed(config);

  assert(isstruct(threshold_robustness), 'Output must be a structure.');
  assert(strcmp(threshold_robustness.run_type, 'threshold_checkpoint_test'), ...
    'run_type mismatch.');
  assert(exist(threshold_robustness.raw_file, 'file') == 2, ...
    'Raw checkpointed threshold file was not created.');
  assert(exist(threshold_robustness.processed_file, 'file') == 2, ...
    'Processed checkpointed threshold file was not created.');
  assert(exist(threshold_robustness.manifest_file, 'file') == 2, ...
    'Manifest checkpointed threshold file was not created.');
  assert(exist(checkpoint_dir, 'dir') == 7, ...
    'Checkpoint directory was not created.');

  expected_scenarios = {
    'easier_tie', 'baseline', 'easier_boundary', 'harder_boundary', 'harder_tie'
  };

  for i = 1:length(expected_scenarios)
    scenario_file = fullfile(checkpoint_dir, ['scenario_', expected_scenarios{i}, '.mat']);
    assert(exist(scenario_file, 'file') == 2, ...
      ['Missing scenario checkpoint: ', scenario_file]);
  end

  expected_contrasts = {
    'easier_tie_BS_low_minus_easier_tie_BS_high', ...
    'baseline_BS_low_minus_baseline_BS_high', ...
    'easier_boundary_BS_low_minus_easier_boundary_BS_high', ...
    'harder_boundary_BS_low_minus_harder_boundary_BS_high', ...
    'harder_tie_BS_low_minus_harder_tie_BS_high'
  };

  for i = 1:length(expected_contrasts)
    bootstrap_file = fullfile(checkpoint_dir, ['bootstrap_', expected_contrasts{i}, '.mat']);
    assert(exist(bootstrap_file, 'file') == 2, ...
      ['Missing bootstrap checkpoint: ', bootstrap_file]);
  end

  assert(length(fieldnames(threshold_robustness.estimands)) == 10, ...
    'Expected ten condition estimands.');
  assert(length(fieldnames(threshold_robustness.bootstraps)) == 5, ...
    'Expected five bootstrap contrasts.');

  fprintf('test_readiness_threshold_checkpointed passed.\n');
end
