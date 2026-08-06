% BUILD_TABLE_DATA_CSVS
% Builds the clean CSV files used by the future Python table generator.
%
% This script does not generate LaTeX directly.
% It generates table-ready CSV files in:
%
%   results/table_data/
%
% The Python table generator will later transform these CSVs into
% publication-ready LaTeX tables.

clear;
clc;

addpath('../src');
rehash;

ensure_dir('../results');
ensure_dir('../results/table_data');

fprintf('\n============================================\n');
fprintf('BUILDING TABLE-DATA CSV FILES\n');
fprintf('============================================\n');

% ------------------------------------------------------------
% Table 1: Constructs and managerial interpretation
% ------------------------------------------------------------

header = {'table_id', 'row_order', 'construct', ...
  'formal_representation', 'managerial_interpretation'};

rows = {
  'table_01', 1, 'Relational confidence', ...
  '$w_{ab}(t)\in[0,1]$', ...
  'Reliability of a recurring working relation between two agents.';

  'table_01', 2, 'Successful interaction', ...
  '$x_{ab}(t)=1$', ...
  'An interaction that reinforces the working relation by improving understanding, alignment, or problem solving.';

  'table_01', 3, 'Failed interaction', ...
  '$x_{ab}(t)=0$', ...
  'An interaction that weakens the working relation through misunderstanding, friction, or misalignment.';

  'table_01', 4, 'Boundary readiness', ...
  '$R_B(t)$', ...
  'Fraction of cross-boundary ties that have reached sufficient relational confidence.';

  'table_01', 5, 'First-passage time', ...
  '$T=\inf\{t:R_B(t)\geq q\}$', ...
  'Time required for the collaboration boundary to become relationally ready.';

  'table_01', 6, 'Translation advantage', ...
  '$\pi_{BS}>\pi_{out}$', ...
  'Higher probability that boundary-spanning interactions succeed relative to ordinary cross-boundary interactions.';

  'table_01', 7, 'Boundary-spanner load', ...
  '$k/(2b)$', ...
  'Approximate amount of cross-boundary work carried by each boundary spanner.'
};

write_cell_csv('../results/table_data/table_01_constructs.csv', header, rows);
fprintf('Wrote table_01_constructs.csv\n');

% ------------------------------------------------------------
% Table 2: Baseline parameterization
% ------------------------------------------------------------

header = {'table_id', 'row_order', 'parameter', ...
  'meaning', 'value', 'managerial_rationale'};

rows = {
  'table_02', 1, '$n_U$', 'University agents', '20', ...
  'Symmetric modular R and D collaboration setting.';

  'table_02', 2, '$n_I$', 'Industry agents', '20', ...
  'Symmetric modular R and D collaboration setting.';

  'table_02', 3, '$p_{in}$', 'Internal tie probability', '0.20', ...
  'Within-module interaction is more frequent than cross-boundary interaction.';

  'table_02', 4, '$p_{out}$', 'Baseline cross-boundary tie probability', '0.03', ...
  'Cross-boundary ties are sparse in unmanaged modular collaboration.';

  'table_02', 5, '$k$', 'Cross-boundary tie budget', '12', ...
  'Fixed scarce interface capacity in controlled architectures.';

  'table_02', 6, '$b$', 'Boundary spanners per side', '2', ...
  'Concentrated boundary-spanning role allocation.';

  'table_02', 7, '$w_0$', 'Initial relational confidence', '0.40', ...
  'Initial relations are neither absent nor ready.';

  'table_02', 8, '$\alpha$', 'Reinforcement rate', '0.08', ...
  'Successful interactions increase relational confidence.';

  'table_02', 9, '$\beta$', 'Decay rate', '0.02', ...
  'Failed interactions erode relational confidence.';

  'table_02', 10, '$\pi_{in}$', 'Internal success probability', '0.80', ...
  'Interactions within the same module are easier.';

  'table_02', 11, '$\pi_{out}$', 'Ordinary cross-boundary success probability', '0.55', ...
  'Cross-boundary interactions are more difficult.';

  'table_02', 12, '$\pi_{BS}$', 'Boundary-spanning success probability', '0.65', ...
  'Boundary spanners have a modest translation advantage.';

  'table_02', 13, '$\theta$', 'Tie-level readiness threshold', '0.80', ...
  'A tie must reach high relational confidence to count as ready.';

  'table_02', 14, '$q$', 'Boundary-level readiness threshold', '0.80', ...
  'The boundary is ready when most cross-boundary ties are ready.';

  'table_02', 15, '$T_{\max}$', 'Simulation horizon', '50000', ...
  'Maximum number of interaction events per trajectory.';

  'table_02', 16, '$NG$', 'Graph realizations', '50', ...
  'Independent network structures per condition.';

  'table_02', 17, '$NT$', 'Trajectories per graph', '50', ...
  'Stochastic interaction histories per network structure.'
};

write_cell_csv('../results/table_data/table_02_baseline_parameters.csv', header, rows);
fprintf('Wrote table_02_baseline_parameters.csv\n');

% ------------------------------------------------------------
% Table 3: Experimental design
% ------------------------------------------------------------

header = {'table_id', 'row_order', 'experiment', ...
  'conditions', 'managerial_question'};

rows = {
  'table_03', 1, 'Baseline architecture comparison', ...
  'Baseline modular network; random bridging; boundary spanning', ...
  'Are random cross-boundary ties sufficient, or does deliberate boundary-spanning design matter?';

  'table_03', 2, 'Mechanism decomposition', ...
  'RB_low; BS_low; BS_high', ...
  'Does boundary spanning work through concentrated allocation, translation capability, or both?';

  'table_03', 3, 'Translation-capability grid', ...
  'pi_BS equals 0.55, 0.60, 0.65, and 0.70', ...
  'How much translation capability is needed to reduce relational delay?';

  'table_03', 4, 'Boundary-spanner load grid', ...
  'b equals 1, 2, 4, and 6', ...
  'Does distributing interface work across more boundary spanners reduce bottleneck risk?';

  'table_03', 5, 'Selection-rule robustness', ...
  'Agent-first interaction selection; edge-uniform interaction selection', ...
  'Does the bottleneck mechanism depend on scarce actor-level interaction capacity?';

  'table_03', 6, 'Readiness-threshold robustness', ...
  'Alternative values of theta and q', ...
  'Does the mechanism depend on the baseline readiness definition?'
};

write_cell_csv('../results/table_data/table_03_experimental_design.csv', header, rows);
fprintf('Wrote table_03_experimental_design.csv\n');

% ------------------------------------------------------------
% Tables 4 to 9: Copy from locked figure-data CSVs
% ------------------------------------------------------------

figure_data_dir = '../results/figure_data/';
table_data_dir = '../results/table_data/';

source_target = {
  'fig_03_baseline_architecture.csv', ...
  'table_04_baseline_architecture.csv';

  'fig_04_mechanism_decomposition.csv', ...
  'table_05_mechanism_decomposition.csv';

  'fig_06_translation_capability_curve.csv', ...
  'table_06_translation_capability.csv';

  'fig_07_boundary_spanner_load.csv', ...
  'table_07_boundary_spanner_load.csv';

  'fig_08_selection_rule_robustness.csv', ...
  'table_08_selection_rule_robustness.csv';

  'fig_09_readiness_threshold_robustness.csv', ...
  'table_09_readiness_threshold_robustness.csv'
};

for i = 1:size(source_target, 1)

  source_file = fullfile(figure_data_dir, source_target{i, 1});
  target_file = fullfile(table_data_dir, source_target{i, 2});

  if exist(source_file, 'file') ~= 2
    error(['Missing source file: ', source_file]);
  end

  copyfile(source_file, target_file);

  fprintf('Copied %s to %s\n', source_target{i, 1}, source_target{i, 2});
end

% ------------------------------------------------------------
% README for table-data folder
% ------------------------------------------------------------

readme_file = '../results/table_data/README_table_data.md';

fid = fopen(readme_file, 'w');

fprintf(fid, '# Table data files\n\n');
fprintf(fid, 'This folder contains the CSV files used by the Python table generator.\n\n');
fprintf(fid, 'The table-data layer is generated by Octave using:\n\n');
fprintf(fid, '`experiments/build_table_data_csvs.m`\n\n');
fprintf(fid, 'Tables 1 to 3 are conceptual and methodological tables generated directly by this script.\n');
fprintf(fid, 'Tables 4 to 9 are derived from the locked figure-data CSV files, so tables and figures use the same numerical source.\n\n');
fprintf(fid, 'Files:\n\n');
fprintf(fid, '- table_01_constructs.csv\n');
fprintf(fid, '- table_02_baseline_parameters.csv\n');
fprintf(fid, '- table_03_experimental_design.csv\n');
fprintf(fid, '- table_04_baseline_architecture.csv\n');
fprintf(fid, '- table_05_mechanism_decomposition.csv\n');
fprintf(fid, '- table_06_translation_capability.csv\n');
fprintf(fid, '- table_07_boundary_spanner_load.csv\n');
fprintf(fid, '- table_08_selection_rule_robustness.csv\n');
fprintf(fid, '- table_09_readiness_threshold_robustness.csv\n');

fclose(fid);

fprintf('Wrote README_table_data.md\n');

fprintf('\n============================================\n');
fprintf('ALL TABLE-DATA CSV FILES BUILT SUCCESSFULLY\n');
fprintf('Output folder: ../results/table_data/\n');
fprintf('============================================\n');
