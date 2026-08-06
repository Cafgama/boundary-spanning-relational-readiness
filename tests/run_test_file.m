function run_test_file(test_file)
  % RUN_TEST_FILE
  % Runs one test script in an isolated function workspace.
  %
  % This protects run_all_tests.m from test scripts that contain
  % clear; clc; because those commands will affect only this function
  % workspace, not the main test runner workspace.

  assert(ischar(test_file), 'test_file must be a character string.');

  eval(test_file);
end
