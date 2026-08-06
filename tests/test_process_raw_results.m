% TEST_PROCESS_RAW_RESULTS
% Tests processing of a raw MAT file and combined CSV export.

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

% Keep the test fast.
P.T_max = 2000;

results = run_single_experiment( ...
  P, 'random_bridging', 2, 3, P.seed);

raw_file = [tempname(), '.mat'];
output_dir = [tempname(), '_outputs'];

save(raw_file, 'results', 'P');

[GS, csv_file, mat_file] = ...
  process_raw_result_file(raw_file, output_dir);

assert(length(GS.graph_id) == 2, ...
  'Expected two graph-level observations.');

assert(exist(csv_file, 'file') == 2, ...
  'Individual graph-summary CSV was not created.');

assert(exist(mat_file, 'file') == 2, ...
  'Individual graph-summary MAT was not created.');

combined_file = fullfile(output_dir, 'combined.csv');

export_combined_graph_summaries_csv({GS, GS}, combined_file);

assert(exist(combined_file, 'file') == 2, ...
  'Combined graph-summary CSV was not created.');

fid = fopen(combined_file, 'r');
content = char(fread(fid, Inf, 'char')');
fclose(fid);

assert(~isempty(strfind(content, 'architecture')), ...
  'Combined CSV must contain architecture header.');

assert(~isempty(strfind(content, 'random_bridging')), ...
  'Combined CSV must contain the architecture name.');

delete(raw_file);
delete(csv_file);
delete(mat_file);
delete(combined_file);
rmdir(output_dir);

disp('Raw-result processing test passed.');
