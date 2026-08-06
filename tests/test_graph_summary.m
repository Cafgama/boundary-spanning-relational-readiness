% TEST_GRAPH_SUMMARY
% Tests graph-level aggregation and CSV export.

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

% Keep test fast.
P.T_max = 3000;

NG = 3;
NT = 4;

results = run_single_experiment( ...
  P, 'random_bridging', NG, NT, P.seed);

GS = summarize_by_graph(results, P);

assert(length(GS.graph_id) == NG, ...
  'Graph summary must contain one row per graph.');

assert(all(GS.n_trajectories == NT), ...
  'Each graph must contain NT trajectories.');

assert(all(GS.graph_id == (1:NG)'), ...
  'Unexpected graph identifiers.');

assert(all(GS.convergence_rate >= 0 & ...
           GS.convergence_rate <= 1), ...
  'Graph convergence rates must be in [0,1].');

assert(all(GS.nonconvergence_rate >= 0 & ...
           GS.nonconvergence_rate <= 1), ...
  'Graph non-convergence rates must be in [0,1].');

assert(all(abs(GS.convergence_rate + ...
               GS.nonconvergence_rate - 1) < 1e-12), ...
  'Graph convergence and non-convergence rates must sum to one.');

assert(all(GS.total_boundary_edges == P.k), ...
  'Random bridging must have exactly k boundary edges per graph.');

outfile = [tempname(), '.csv'];

export_graph_summary_csv(GS, outfile);

assert(exist(outfile, 'file') == 2, ...
  'Graph summary CSV was not created.');

fid = fopen(outfile, 'r');
content = char(fread(fid, Inf, 'char')');
fclose(fid);

assert(~isempty(strfind(content, 'graph_id')), ...
  'CSV header must contain graph_id.');

assert(~isempty(strfind(content, 'random_bridging')), ...
  'CSV must contain architecture name.');

delete(outfile);

disp('Graph-level summary test passed.');
