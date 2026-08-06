% TEST_COMPARE_GRAPH_METRIC

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

GS1.architecture = 'architecture_1';
GS1.graph_id = (1:5)';
GS1.T_cens_median = [10; 12; 14; 16; 18];

GS2.architecture = 'architecture_2';
GS2.graph_id = (1:5)';
GS2.T_cens_median = [8; 9; 11; 12; 14];

C = compare_graph_metric( ...
  GS1, GS2, 'T_cens_median', 2000, 12345);

assert(C.n_pairs == 5, ...
  'Unexpected number of paired graphs.');

assert(abs(C.mean_difference - mean( ...
  GS1.T_cens_median - GS2.T_cens_median)) < 1e-12, ...
  'Incorrect paired mean difference.');

assert(C.n_x_greater == 5, ...
  'Architecture 1 should have a higher value in all pairs.');

assert(C.fraction_y_lower == 1, ...
  'Architecture 2 should be lower in all pairs.');

assert(C.ci_lower > 0, ...
  'Bootstrap interval should be positive.');

disp('Graph metric comparison test passed.');
