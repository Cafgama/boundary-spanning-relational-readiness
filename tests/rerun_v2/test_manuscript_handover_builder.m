function test_manuscript_handover_builder()
  % TEST_MANUSCRIPT_HANDOVER_BUILDER
  % Tests the Step 27 master handover builder using synthetic source handovers.
  % This test does not run simulations.

  setup_rerun_v2_tests();

  repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  test_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'manuscript_handover_test');
  ensure_dir(test_dir);

  source_files = {
    'final_core_results_handover.md', 'Final core synthetic values.';
    'translation_grid_results_handover.md', 'Translation-grid synthetic values.';
    'workload_grid_results_handover.md', 'Workload-grid synthetic values.';
    'selection_rule_results_handover.md', 'Selection-rule synthetic values.';
    'threshold_robustness_results_handover.md', 'Threshold-robustness synthetic values.'
  };

  for i = 1:size(source_files, 1)
    f = fullfile(test_dir, source_files{i, 1});
    fid = fopen(f, 'w');
    assert(fid > 0, ['Could not write synthetic source file: ', f]);
    fprintf(fid, '# %s\n\n%s\n', source_files{i, 1}, source_files{i, 2});
    fclose(fid);
  end

  output_file = fullfile(test_dir, 'manuscript_results_handover_test.md');

  config = struct();
  config.source_dir = test_dir;
  config.output_file = output_file;
  config.strict = true;
  config.include_verbatim_sources = true;

  exports = build_manuscript_results_handover(config);

  assert(isstruct(exports), 'Builder output must be a structure.');
  assert(exist(exports.output_file, 'file') == 2, 'Master handover output was not created.');
  assert(exports.n_sources == 5, 'Master handover should include five source handovers.');

  txt = fileread(exports.output_file);
  assert(~isempty(strfind(txt, 'Manuscript results handover')), ...
    'Output should contain the master handover title.');
  assert(~isempty(strfind(txt, 'Master claim map')), ...
    'Output should contain the master claim map.');
  assert(~isempty(strfind(txt, 'Final core synthetic values.')), ...
    'Output should append the final-core source text.');
  assert(~isempty(strfind(txt, 'Threshold-robustness synthetic values.')), ...
    'Output should append the threshold source text.');

  fprintf('test_manuscript_handover_builder passed.\n');
end
