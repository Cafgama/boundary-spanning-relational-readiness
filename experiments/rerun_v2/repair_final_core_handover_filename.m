function repaired_file = repair_final_core_handover_filename()
  % REPAIR_FINAL_CORE_HANDOVER_FILENAME
  % Temporary compatibility helper.
  %
  % Some early Step 13 exports wrote the final-core handover to
  % docs/manuscript_results_handover.md. The Step 27 master handover builder
  % expects the block-specific source file:
  % docs/final_core_results_handover.md.
  %
  % This helper copies the existing core-only manuscript handover to the
  % expected block-specific filename. It does not run simulations.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  docs_dir = fullfile(repo_root, 'docs');

  old_file = fullfile(docs_dir, 'manuscript_results_handover.md');
  repaired_file = fullfile(docs_dir, 'final_core_results_handover.md');

  assert(exist(old_file, 'file') == 2, ...
    ['Expected source handover not found: ', old_file]);

  copyfile(old_file, repaired_file);

  assert(exist(repaired_file, 'file') == 2, ...
    ['Could not create repaired handover: ', repaired_file]);

  fprintf('\n============================================\n');
  fprintf('FINAL CORE HANDOVER FILENAME REPAIR PASSED\n');
  fprintf('============================================\n');
  fprintf('source:   %s\n', old_file);
  fprintf('repaired: %s\n', repaired_file);
end
