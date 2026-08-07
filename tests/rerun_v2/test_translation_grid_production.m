function test_translation_grid_production()
  % TEST_TRANSLATION_GRID_PRODUCTION
  % Runs a tiny translation-grid production-pipeline test.
  % This validates plumbing only; it is not a scientific result.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  config = struct();
  config.run_type = 'translation_grid_test';
  config.output_tag = 'translation_grid_test';
  config.NG = 2;
  config.NT = 3;
  config.T_max = 2000;
  config.n_boot = 20;
  config.theta = 0.80;
  config.q = 0.80;
  config.pi_out = 0.55;
  config.pi_BS_grid = [0.55, 0.65];
  config.seed_base = 606000;
  config.bootstrap_seed = 707000;

  out = run_translation_grid_production(config);

  assert(isstruct(out), 'Translation-grid output must be a structure.');
  assert(strcmp(out.run_type, 'translation_grid_test'), 'run_type mismatch.');
  assert(strcmp(out.output_tag, 'translation_grid_test'), 'output_tag mismatch.');
  assert(out.NG == 2, 'NG mismatch.');
  assert(out.NT == 3, 'NT mismatch.');
  assert(out.T_max == 2000, 'T_max mismatch.');
  assert(out.n_boot == 20, 'n_boot mismatch.');

  expected_n = out.NG * out.NT;

  condition_names = fieldnames(out.results);
  assert(length(condition_names) == 2, 'Expected two translation-grid test conditions.');
  assert(isfield(out.results, 'BS_pi_055'), 'Missing BS_pi_055.');
  assert(isfield(out.results, 'BS_pi_065'), 'Missing BS_pi_065.');

  for i = 1:length(condition_names)
    cname = condition_names{i};
    R = out.results.(cname);

    assert(length(R.T_tilde) == expected_n, ['Wrong trajectory count for ', cname]);
    assert(length(R.delta) == expected_n, ['Wrong delta count for ', cname]);
    assert(all(R.delta == 0 | R.delta == 1), ['delta must be binary for ', cname]);
    assert(all(R.converged == R.delta), ['converged must equal delta for ', cname]);
    assert(all(~isnan(R.T_tilde)), ['T_tilde cannot contain NaN for ', cname]);
    assert(all(strcmp(R.architecture, 'boundary_spanning')), ...
      ['architecture must be boundary_spanning for ', cname]);
  end

  assert(isfield(out.estimands, 'BS_pi_055'), 'Missing estimands for BS_pi_055.');
  assert(isfield(out.estimands, 'BS_pi_065'), 'Missing estimands for BS_pi_065.');

  assert(isfield(out.bootstraps, 'BS_pi_055_minus_BS_pi_065'), ...
    'Missing adjacent bootstrap contrast.');

  B = out.bootstraps.BS_pi_055_minus_BS_pi_065;
  assert(B.n_boot == config.n_boot, 'Bootstrap n_boot mismatch.');

  assert(exist(out.raw_file, 'file') == 2, 'Raw output file was not created.');
  assert(exist(out.processed_file, 'file') == 2, 'Processed output file was not created.');
  assert(exist(out.manifest_file, 'file') == 2, 'Manifest file was not created.');

  fprintf('test_translation_grid_production passed.\n');
end
