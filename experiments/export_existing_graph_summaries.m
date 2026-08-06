% EXPORT_EXISTING_GRAPH_SUMMARIES
% Converts completed NG50-NT50 raw simulations into graph-level datasets.

clear;
clc;

addpath('../src');

output_dir = '../results/processed/graph_level';
ensure_dir(output_dir);

raw_files = {
  '../results/raw/resumable_baseline_NG50_NT50_results_20260606_232858.mat',
  '../results/raw/resumable_random_bridging_NG50_NT50_results_20260606_214033.mat',
  '../results/raw/resumable_boundary_spanning_NG50_NT50_results_20260606_201540.mat'
};

all_GS = cell(length(raw_files), 1);

fprintf('\n============================================\n');
fprintf('EXPORTING GRAPH-LEVEL SUMMARIES\n');
fprintf('============================================\n');

for i = 1:length(raw_files)
  fprintf('\nProcessing:\n%s\n', raw_files{i});

  [GS, ~, ~] = process_raw_result_file( ...
    raw_files{i}, output_dir);

  all_GS{i} = GS;
end

combined_csv = fullfile(output_dir, ...
  'combined_graph_summary_NG50_NT50.csv');

combined_mat = fullfile(output_dir, ...
  'combined_graph_summary_NG50_NT50.mat');

export_combined_graph_summaries_csv(all_GS, combined_csv);
save(combined_mat, 'all_GS');

total_graphs = 0;

for i = 1:length(all_GS)
  total_graphs = total_graphs + length(all_GS{i}.graph_id);
end

fprintf('\n============================================\n');
fprintf('GRAPH-LEVEL EXPORT COMPLETED\n');
fprintf('Architectures: %d\n', length(all_GS));
fprintf('Total graph observations: %d\n', total_graphs);
fprintf('Combined CSV:\n%s\n', combined_csv);
fprintf('Combined MAT:\n%s\n', combined_mat);
fprintf('============================================\n');
