function test_readiness_threshold_robustness()
  % TEST_READINESS_THRESHOLD_ROBUSTNESS
  % Small pipeline test for Step 24. This is not a production run.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'threshold_robustness_test';
  config.output_tag = 'threshold_robustness_test';
  config.NG = 2;
  config.NT = 3;
  config.T_max = 2000;
  config.n_boot = 20;
  config.seed_base = 1201000;
  config.bootstrap_seed = 1301000;

  out = run_readiness_threshold_robustness(config);

  assert(isstruct(out), 'Output must be a structure.');
  assert(strcmp(out.run_type, 'threshold_robustness_test'), 'run_type mismatch.');
  assert(length(out.scenarios) == 5, 'Expected five scenarios.');
  assert(length(out.conditions) == 10, 'Expected ten conditions.');

  names = fieldnames(out.results);
  assert(length(names) == 10, 'Expected ten result fields.');

  expected_n = config.NG * config.NT;
  for i = 1:length(names)
    R = out.results.(names{i});
    assert(length(R.T_tilde) == expected_n, 'Unexpected trajectory count.');
    assert(all(R.delta == 0 | R.delta == 1), 'delta must contain only 0/1.');
    assert(all(R.converged == R.delta), 'converged must equal delta.');
  end

  bnames = fieldnames(out.bootstraps);
  assert(length(bnames) == 5, 'Expected five bootstrap contrasts.');

  assert(exist(out.raw_file, 'file') == 2, 'Raw file was not created.');
  assert(exist(out.processed_file, 'file') == 2, 'Processed file was not created.');
  assert(exist(out.manifest_file, 'file') == 2, 'Manifest file was not created.');

  fprintf('test_readiness_threshold_robustness passed.\n');
end
