function run_pilot_tests()
  % RUN_PILOT_TESTS
  % Runs rerun_v2 production-pilot tests.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(this_dir);
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));

  tests = {
    'test_production_pilot'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 PRODUCTION PILOT TESTS\n');
  fprintf('============================================\n');

  failed = {};

  for i = 1:length(tests)
    test_name = tests{i};

    fprintf('\n--------------------------------------------\n');
    fprintf('Running %s\n', test_name);
    fprintf('--------------------------------------------\n');

    try
      feval(test_name);
      fprintf('PASSED: %s\n', test_name);
    catch err
      fprintf('FAILED: %s\n', test_name);
      fprintf('Reason: %s\n', err.message);
      failed{end + 1} = test_name;
    end
  end

  fprintf('\n============================================\n');

  if isempty(failed)
    fprintf('ALL RERUN V2 PRODUCTION PILOT TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');

    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end

    error('One or more rerun_v2 production pilot tests failed.');
  end

  fprintf('============================================\n');
end
