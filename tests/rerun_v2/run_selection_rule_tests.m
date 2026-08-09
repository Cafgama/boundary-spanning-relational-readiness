function run_selection_rule_tests()
  % RUN_SELECTION_RULE_TESTS
  % Runs rerun_v2 Step 21 selection-rule robustness tests.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));
  addpath(fullfile(repo_root, 'experiments', 'rerun_v2'));
  addpath(this_dir);

  tests = {
    'test_selection_rule_robustness'
  };

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SELECTION-RULE ROBUSTNESS TESTS\n');
  fprintf('============================================\n');

  failed = {};

  for i = 1:length(tests)
    test_name = tests{i};

    fprintf('\n--------------------------------------------\n');
    fprintf('Running %s\n', test_name);
    fprintf('\n--------------------------------------------\n');

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
    fprintf('ALL RERUN V2 SELECTION-RULE ROBUSTNESS TESTS PASSED\n');
  else
    fprintf('FAILED TESTS:\n');
    for i = 1:length(failed)
      fprintf('- %s\n', failed{i});
    end
    error('One or more rerun_v2 selection-rule robustness tests failed.');
  end

  fprintf('============================================\n');
end
