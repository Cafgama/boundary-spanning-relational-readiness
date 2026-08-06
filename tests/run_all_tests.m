% RUN_ALL_TESTS
% Runs all smoke tests for the boundary-spanning relational readiness model.
%
% This runner calls each test inside run_test_file(), so test scripts
% cannot accidentally erase the runner workspace.

clear;
clc;

fprintf('\n============================================\n');
fprintf('RUNNING ALL TESTS\n');
fprintf('============================================\n');

test_files = {
  'test_params',
  'test_network_generation',
  'test_compute_readiness',
  'test_dynamics_small',
  'test_dynamics_fast',
  'test_single_experiment',
  'test_summarize_results',
  'test_export_summary_csv',
  'test_graph_summary',
  'test_process_raw_results'
  'test_paired_bootstrap_difference'
  'test_compare_graph_metric'
  'test_configure_mechanism_condition'
  'test_dynamics_edge_uniform'
};

n_tests = length(test_files);

for i = 1:n_tests
  current_test = test_files{i};

  fprintf('\n--------------------------------------------\n');
  fprintf('Running %s\n', current_test);
  fprintf('--------------------------------------------\n');

  try
    run_test_file(current_test);
    fprintf('PASSED: %s\n', current_test);
  catch err
    fprintf('FAILED: %s\n', current_test);
    fprintf('Error message:\n');
    fprintf('%s\n', err.message);
    rethrow(err);
  end
end

fprintf('\n============================================\n');
fprintf('ALL TESTS PASSED\n');
fprintf('============================================\n');
