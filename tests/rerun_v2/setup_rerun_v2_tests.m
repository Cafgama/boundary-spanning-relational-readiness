function repo_root = setup_rerun_v2_tests()
  % SETUP_RERUN_V2_TESTS
  % Adds the repository src folder and this test folder to the Octave path.
  %
  % This makes the rerun_v2 tests runnable either from the repository root
  % or from inside tests/rerun_v2.

  this_file = mfilename('fullpath');
  this_dir = fileparts(this_file);
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(this_dir);
end
