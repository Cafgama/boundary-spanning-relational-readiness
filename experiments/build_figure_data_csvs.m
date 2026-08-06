% BUILD_FIGURE_DATA_CSVS
% Builds the seven clean CSV files used by the Python figure generator.
%
% This script transforms Octave simulation outputs into figure-ready data.
%
% Output folder:
%   results/figure_data/
%
% Python should read only these seven CSV files.

clear;
clc;

addpath('../src');

ensure_dir('../results');
ensure_dir('../results/figure_data');

fprintf('\n============================================\n');
fprintf('BUILDING FIGURE-DATA CSV FILES\n');
fprintf('============================================\n');

% ------------------------------------------------------------
% 1. Load core result files
% ------------------------------------------------------------

% Mechanism decomposition raw files.
file_RB_low = latest_file('../results/raw/mechanism_RB_low_NG50_NT50_results_*.mat');
file_BS_low = latest_file('../results/raw/mechanism_BS_low_NG50_NT50_results_*.mat');
file_BS_high = latest_file('../results/raw/mechanism_BS_high_NG50_NT50_results_*.mat');

% Translation capability raw files.
file_TR_060 = latest_file('../results/raw/translation_TR_piBS_060_NG50_NT50_results_*.mat');
file_TR_070 = latest_file('../results/raw/translation_TR_piBS_070_NG50_NT50_results_*.mat');

% Load raw files.
file_LOAD_01 = latest_file('../results/raw/load_LOAD_b_01_NG50_NT50_results_*.mat');
file_LOAD_02 = latest_file('../results/raw/load_LOAD_b_02_NG50_NT50_results_*.mat');
file_LOAD_04 = latest_file('../results/raw/load_LOAD_b_04_NG50_NT50_results_*.mat');
file_LOAD_06 = latest_file('../results/raw/load_LOAD_b_06_NG50_NT50_results_*.mat');

% Selection-rule raw files.
file_SEL_RB_low_EU = latest_file('../results/raw/selection_RB_low_edge_uniform_NG50_NT50_results_*.mat');
file_SEL_BS_low_EU = latest_file('../results/raw/selection_BS_low_edge_uniform_NG50_NT50_results_*.mat');
file_SEL_BS_high_EU = latest_file('../results/raw/selection_BS_high_edge_uniform_NG50_NT50_results_*.mat');

% Threshold raw files.
file_TH_low_075_080 = latest_file('../results/raw/threshold_BS_low_TH_075_Q_080_NG50_NT50_results_*.mat');
file_TH_high_075_080 = latest_file('../results/raw/threshold_BS_high_TH_075_Q_080_NG50_NT50_results_*.mat');

file_TH_low_085_080 = latest_file('../results/raw/threshold_BS_low_TH_085_Q_080_NG50_NT50_results_*.mat');
file_TH_high_085_080 = latest_file('../results/raw/threshold_BS_high_TH_085_Q_080_NG50_NT50_results_*.mat');

file_TH_low_080_070 = latest_file('../results/raw/threshold_BS_low_TH_080_Q_070_NG50_NT50_results_*.mat');
file_TH_high_080_070 = latest_file('../results/raw/threshold_BS_high_TH_080_Q_070_NG50_NT50_results_*.mat');

file_TH_low_080_090 = latest_file('../results/raw/threshold_BS_low_TH_080_Q_090_NG50_NT50_results_*.mat');
file_TH_high_080_090 = latest_file('../results/raw/threshold_BS_high_TH_080_Q_090_NG50_NT50_results_*.mat');

fprintf('Core files found.\n');

% ------------------------------------------------------------
% 2. Generate Figure 03 data
% ------------------------------------------------------------
% This figure uses the locked baseline architecture results.
% If later we standardize raw files for baseline, this block can be
% replaced by direct loading from raw results.

header = {'figure_id', 'architecture_code', 'architecture_label', ...
  'mean_T', 'median_T', 'p90_T', 'p95_T', ...
  'convergence_rate', 'n_graphs', 'n_trajectories', 'source'};

rows = {
  'fig_03', 'baseline', 'Baseline modular network', ...
  7435.8, 7048.0, 9925.6, 11016.9, 1.0, 50, 2500, 'locked architecture summary';
  'fig_03', 'random_bridging', 'Random bridging', ...
  7280.2, 7008.4, 9653.6, 10592.6, 1.0, 50, 2500, 'locked architecture summary';
  'fig_03', 'boundary_spanning', 'Boundary spanning', ...
  4576.0, 4513.5, 5444.7, 5743.5, 1.0, 50, 2500, 'locked architecture summary'
};

write_cell_csv('../results/figure_data/fig_03_baseline_architecture.csv', header, rows);

fprintf('Wrote fig_03_baseline_architecture.csv\n');

% ------------------------------------------------------------
% 3. Generate Figure 05 data: tail-risk profile
% ------------------------------------------------------------

load(file_RB_low); S_RB_low = graph_level_summary_from_results(results);
load(file_BS_low); S_BS_low = graph_level_summary_from_results(results);
load(file_BS_high); S_BS_high = graph_level_summary_from_results(results);

header = {'figure_id', 'condition', 'condition_label', ...
  'network_architecture', 'n_graphs', 'n_trajectories', ...
  'convergence_rate', 'mean_T', 'median_T', 'p90_T', 'p95_T', ...
  'max_T', 'total_edges', 'mean_degree', 'max_degree', 'boundary_edges'};

rows = {
  'fig_05', 'RB_low', 'Random bridging, ordinary translation', ...
  'random_bridging', S_RB_low.n_graphs, S_RB_low.n_trajectories, ...
  S_RB_low.convergence_rate, S_RB_low.mean_T, S_RB_low.median_T, ...
  S_RB_low.p90_T, S_RB_low.p95_T, S_RB_low.max_T, ...
  S_RB_low.total_edges, S_RB_low.mean_degree, S_RB_low.max_degree, ...
  S_RB_low.boundary_edges;

  'fig_05', 'BS_low', 'Boundary spanning, no translation advantage', ...
  'boundary_spanning', S_BS_low.n_graphs, S_BS_low.n_trajectories, ...
  S_BS_low.convergence_rate, S_BS_low.mean_T, S_BS_low.median_T, ...
  S_BS_low.p90_T, S_BS_low.p95_T, S_BS_low.max_T, ...
  S_BS_low.total_edges, S_BS_low.mean_degree, S_BS_low.max_degree, ...
  S_BS_low.boundary_edges;

  'fig_05', 'BS_high', 'Boundary spanning, translation advantage', ...
  'boundary_spanning', S_BS_high.n_graphs, S_BS_high.n_trajectories, ...
  S_BS_high.convergence_rate, S_BS_high.mean_T, S_BS_high.median_T, ...
  S_BS_high.p90_T, S_BS_high.p95_T, S_BS_high.max_T, ...
  S_BS_high.total_edges, S_BS_high.mean_degree, S_BS_high.max_degree, ...
  S_BS_high.boundary_edges
};

write_cell_csv('../results/figure_data/fig_05_tail_risk_profile.csv', header, rows);

fprintf('Wrote fig_05_tail_risk_profile.csv\n');

% ------------------------------------------------------------
% 4. Generate Figure 06 data: translation capability curve
% ------------------------------------------------------------

load(file_BS_low); S_TR_055 = graph_level_summary_from_results(results);
load(file_TR_060); S_TR_060 = graph_level_summary_from_results(results);
load(file_BS_high); S_TR_065 = graph_level_summary_from_results(results);
load(file_TR_070); S_TR_070 = graph_level_summary_from_results(results);

header = {'figure_id', 'pi_out', 'pi_BS', 'condition', ...
  'n_graphs', 'n_trajectories', 'convergence_rate', ...
  'mean_T', 'median_T', 'p90_T', 'p95_T', 'max_T', ...
  'total_edges', 'mean_degree', 'max_degree', 'boundary_edges'};

rows = {
  'fig_06', 0.55, 0.55, 'TR_piBS_055', ...
  S_TR_055.n_graphs, S_TR_055.n_trajectories, S_TR_055.convergence_rate, ...
  S_TR_055.mean_T, S_TR_055.median_T, S_TR_055.p90_T, S_TR_055.p95_T, ...
  S_TR_055.max_T, S_TR_055.total_edges, S_TR_055.mean_degree, ...
  S_TR_055.max_degree, S_TR_055.boundary_edges;

  'fig_06', 0.55, 0.60, 'TR_piBS_060', ...
  S_TR_060.n_graphs, S_TR_060.n_trajectories, S_TR_060.convergence_rate, ...
  S_TR_060.mean_T, S_TR_060.median_T, S_TR_060.p90_T, S_TR_060.p95_T, ...
  S_TR_060.max_T, S_TR_060.total_edges, S_TR_060.mean_degree, ...
  S_TR_060.max_degree, S_TR_060.boundary_edges;

  'fig_06', 0.55, 0.65, 'TR_piBS_065', ...
  S_TR_065.n_graphs, S_TR_065.n_trajectories, S_TR_065.convergence_rate, ...
  S_TR_065.mean_T, S_TR_065.median_T, S_TR_065.p90_T, S_TR_065.p95_T, ...
  S_TR_065.max_T, S_TR_065.total_edges, S_TR_065.mean_degree, ...
  S_TR_065.max_degree, S_TR_065.boundary_edges;

  'fig_06', 0.55, 0.70, 'TR_piBS_070', ...
  S_TR_070.n_graphs, S_TR_070.n_trajectories, S_TR_070.convergence_rate, ...
  S_TR_070.mean_T, S_TR_070.median_T, S_TR_070.p90_T, S_TR_070.p95_T, ...
  S_TR_070.max_T, S_TR_070.total_edges, S_TR_070.mean_degree, ...
  S_TR_070.max_degree, S_TR_070.boundary_edges
};

write_cell_csv('../results/figure_data/fig_06_translation_capability_curve.csv', header, rows);

fprintf('Wrote fig_06_translation_capability_curve.csv\n');

% ------------------------------------------------------------
% 5. Generate Figure 07 data: boundary-spanner load
% ------------------------------------------------------------

load(file_LOAD_01); S_LOAD_01 = graph_level_summary_from_results(results);
load(file_LOAD_02); S_LOAD_02 = graph_level_summary_from_results(results);
load(file_LOAD_04); S_LOAD_04 = graph_level_summary_from_results(results);
load(file_LOAD_06); S_LOAD_06 = graph_level_summary_from_results(results);

header = {'figure_id', 'architecture', 'b', 'load_per_spanner', ...
  'cross_boundary_tie_budget', 'n_graphs', 'n_trajectories', ...
  'convergence_rate', 'mean_T', 'median_T', 'p90_T', 'p95_T', ...
  'total_edges', 'mean_degree', 'max_degree', 'boundary_edges'};

rows = {
  'fig_07', 'LOAD_b_01', 1, 6.0, 12, ...
  S_LOAD_01.n_graphs, S_LOAD_01.n_trajectories, S_LOAD_01.convergence_rate, ...
  S_LOAD_01.mean_T, S_LOAD_01.median_T, S_LOAD_01.p90_T, S_LOAD_01.p95_T, ...
  S_LOAD_01.total_edges, S_LOAD_01.mean_degree, S_LOAD_01.max_degree, ...
  S_LOAD_01.boundary_edges;

  'fig_07', 'LOAD_b_02', 2, 3.0, 12, ...
  S_LOAD_02.n_graphs, S_LOAD_02.n_trajectories, S_LOAD_02.convergence_rate, ...
  S_LOAD_02.mean_T, S_LOAD_02.median_T, S_LOAD_02.p90_T, S_LOAD_02.p95_T, ...
  S_LOAD_02.total_edges, S_LOAD_02.mean_degree, S_LOAD_02.max_degree, ...
  S_LOAD_02.boundary_edges;

  'fig_07', 'LOAD_b_04', 4, 1.5, 12, ...
  S_LOAD_04.n_graphs, S_LOAD_04.n_trajectories, S_LOAD_04.convergence_rate, ...
  S_LOAD_04.mean_T, S_LOAD_04.median_T, S_LOAD_04.p90_T, S_LOAD_04.p95_T, ...
  S_LOAD_04.total_edges, S_LOAD_04.mean_degree, S_LOAD_04.max_degree, ...
  S_LOAD_04.boundary_edges;

  'fig_07', 'LOAD_b_06', 6, 1.0, 12, ...
  S_LOAD_06.n_graphs, S_LOAD_06.n_trajectories, S_LOAD_06.convergence_rate, ...
  S_LOAD_06.mean_T, S_LOAD_06.median_T, S_LOAD_06.p90_T, S_LOAD_06.p95_T, ...
  S_LOAD_06.total_edges, S_LOAD_06.mean_degree, S_LOAD_06.max_degree, ...
  S_LOAD_06.boundary_edges
};

write_cell_csv('../results/figure_data/fig_07_boundary_spanner_load.csv', header, rows);

fprintf('Wrote fig_07_boundary_spanner_load.csv\n');

fprintf('\nPART 1 COMPLETE.\n');
fprintf('Next we will add fig_04, fig_08, and fig_09 if this compiles cleanly.\n');

% ------------------------------------------------------------
% 6. Generate Figure 04 data: mechanism decomposition
% ------------------------------------------------------------

fprintf('\nBuilding fig_04_mechanism_decomposition.csv\n');

rand('seed', 98765);

D_RB_low = load(file_RB_low);
D_BS_low = load(file_BS_low);
D_BS_high = load(file_BS_high);

R_RB_low = D_RB_low.results;
R_BS_low = D_BS_low.results;
R_BS_high = D_BS_high.results;

n_boot = 5000;

header = {'figure_id', 'comparison_code', 'comparison_label', ...
  'statistic', 'condition_x', 'condition_y', ...
  'x_value', 'y_value', 'difference_x_minus_y', ...
  'ci_low', 'ci_high', 'reduction_pct', ...
  'n_boot', 'paired', 'y_faster_graphs', 'y_faster_share'};

rows = {};

metrics = {'mean_T', 'median_T', 'p90_T', 'p95_T'};
metric_labels = {'Mean T', 'Median T', 'P90', 'P95'};

comparison_codes = {'RB_low_minus_BS_low', ...
  'BS_low_minus_BS_high', ...
  'RB_low_minus_BS_high'};

comparison_labels = {'Concentration without translation', ...
  'Translation capability effect', ...
  'Total boundary-spanning effect'};

condition_x = {'RB_low', 'BS_low', 'RB_low'};
condition_y = {'BS_low', 'BS_high', 'BS_high'};

paired_flags = [false, true, false];

for c = 1:length(comparison_codes)

  for m = 1:length(metrics)

    metric_name = metrics{m};

    if strcmp(condition_x{c}, 'RB_low')
      x = graph_metric_vector_from_results(R_RB_low, metric_name);
    elseif strcmp(condition_x{c}, 'BS_low')
      x = graph_metric_vector_from_results(R_BS_low, metric_name);
    elseif strcmp(condition_x{c}, 'BS_high')
      x = graph_metric_vector_from_results(R_BS_high, metric_name);
    else
      error('Unknown condition_x.');
    end

    if strcmp(condition_y{c}, 'RB_low')
      y = graph_metric_vector_from_results(R_RB_low, metric_name);
    elseif strcmp(condition_y{c}, 'BS_low')
      y = graph_metric_vector_from_results(R_BS_low, metric_name);
    elseif strcmp(condition_y{c}, 'BS_high')
      y = graph_metric_vector_from_results(R_BS_high, metric_name);
    else
      error('Unknown condition_y.');
    end

    B = bootstrap_graph_difference(x, y, n_boot, paired_flags(c));

    new_row = {
      'fig_04', comparison_codes{c}, comparison_labels{c}, ...
      metric_labels{m}, condition_x{c}, condition_y{c}, ...
      B.x_value, B.y_value, B.difference, ...
      B.ci_low, B.ci_high, B.reduction_pct, ...
      B.n_boot, B.paired, B.y_faster_graphs, B.y_faster_share
    };

    rows = [rows; new_row];
  end
end

write_cell_csv('../results/figure_data/fig_04_mechanism_decomposition.csv', ...
  header, rows);

fprintf('Wrote fig_04_mechanism_decomposition.csv\n');

% ------------------------------------------------------------
% 7. Generate Figure 08 data: selection-rule robustness
% ------------------------------------------------------------

fprintf('\nBuilding fig_08_selection_rule_robustness.csv\n');

D_SEL_RB_low_EU = load(file_SEL_RB_low_EU);
D_SEL_BS_low_EU = load(file_SEL_BS_low_EU);
D_SEL_BS_high_EU = load(file_SEL_BS_high_EU);

S_RB_low_AF = graph_level_summary_from_results(R_RB_low);
S_BS_low_AF = graph_level_summary_from_results(R_BS_low);
S_BS_high_AF = graph_level_summary_from_results(R_BS_high);

S_RB_low_EU = graph_level_summary_from_results(D_SEL_RB_low_EU.results);
S_BS_low_EU = graph_level_summary_from_results(D_SEL_BS_low_EU.results);
S_BS_high_EU = graph_level_summary_from_results(D_SEL_BS_high_EU.results);

header = {'figure_id', 'condition', 'selection_rule', ...
  'n_graphs', 'n_trajectories', 'convergence_rate', ...
  'mean_T', 'median_T', 'p90_T', 'p95_T', ...
  'total_edges', 'mean_degree', 'max_degree', 'boundary_edges'};

rows = {
  'fig_08', 'RB_low', 'agent_first', ...
  S_RB_low_AF.n_graphs, S_RB_low_AF.n_trajectories, ...
  S_RB_low_AF.convergence_rate, S_RB_low_AF.mean_T, ...
  S_RB_low_AF.median_T, S_RB_low_AF.p90_T, S_RB_low_AF.p95_T, ...
  S_RB_low_AF.total_edges, S_RB_low_AF.mean_degree, ...
  S_RB_low_AF.max_degree, S_RB_low_AF.boundary_edges;

  'fig_08', 'RB_low', 'edge_uniform', ...
  S_RB_low_EU.n_graphs, S_RB_low_EU.n_trajectories, ...
  S_RB_low_EU.convergence_rate, S_RB_low_EU.mean_T, ...
  S_RB_low_EU.median_T, S_RB_low_EU.p90_T, S_RB_low_EU.p95_T, ...
  S_RB_low_EU.total_edges, S_RB_low_EU.mean_degree, ...
  S_RB_low_EU.max_degree, S_RB_low_EU.boundary_edges;

  'fig_08', 'BS_low', 'agent_first', ...
  S_BS_low_AF.n_graphs, S_BS_low_AF.n_trajectories, ...
  S_BS_low_AF.convergence_rate, S_BS_low_AF.mean_T, ...
  S_BS_low_AF.median_T, S_BS_low_AF.p90_T, S_BS_low_AF.p95_T, ...
  S_BS_low_AF.total_edges, S_BS_low_AF.mean_degree, ...
  S_BS_low_AF.max_degree, S_BS_low_AF.boundary_edges;

  'fig_08', 'BS_low', 'edge_uniform', ...
  S_BS_low_EU.n_graphs, S_BS_low_EU.n_trajectories, ...
  S_BS_low_EU.convergence_rate, S_BS_low_EU.mean_T, ...
  S_BS_low_EU.median_T, S_BS_low_EU.p90_T, S_BS_low_EU.p95_T, ...
  S_BS_low_EU.total_edges, S_BS_low_EU.mean_degree, ...
  S_BS_low_EU.max_degree, S_BS_low_EU.boundary_edges;

  'fig_08', 'BS_high', 'agent_first', ...
  S_BS_high_AF.n_graphs, S_BS_high_AF.n_trajectories, ...
  S_BS_high_AF.convergence_rate, S_BS_high_AF.mean_T, ...
  S_BS_high_AF.median_T, S_BS_high_AF.p90_T, S_BS_high_AF.p95_T, ...
  S_BS_high_AF.total_edges, S_BS_high_AF.mean_degree, ...
  S_BS_high_AF.max_degree, S_BS_high_AF.boundary_edges;

  'fig_08', 'BS_high', 'edge_uniform', ...
  S_BS_high_EU.n_graphs, S_BS_high_EU.n_trajectories, ...
  S_BS_high_EU.convergence_rate, S_BS_high_EU.mean_T, ...
  S_BS_high_EU.median_T, S_BS_high_EU.p90_T, S_BS_high_EU.p95_T, ...
  S_BS_high_EU.total_edges, S_BS_high_EU.mean_degree, ...
  S_BS_high_EU.max_degree, S_BS_high_EU.boundary_edges
};

write_cell_csv('../results/figure_data/fig_08_selection_rule_robustness.csv', ...
  header, rows);

fprintf('Wrote fig_08_selection_rule_robustness.csv\n');

% ------------------------------------------------------------
% 8. Generate Figure 09 data: readiness-threshold robustness
% ------------------------------------------------------------

fprintf('\nBuilding fig_09_readiness_threshold_robustness.csv\n');

threshold_low_files = {
  file_TH_low_075_080;
  file_BS_low;
  file_TH_low_080_070;
  file_TH_low_080_090;
  file_TH_low_085_080
};

threshold_high_files = {
  file_TH_high_075_080;
  file_BS_high;
  file_TH_high_080_070;
  file_TH_high_080_090;
  file_TH_high_085_080
};

theta_values = [0.75; 0.80; 0.80; 0.80; 0.85];
q_values = [0.80; 0.80; 0.70; 0.90; 0.80];

scenario_codes = {
  'TH_075_Q_080';
  'TH_080_Q_080';
  'TH_080_Q_070';
  'TH_080_Q_090';
  'TH_085_Q_080'
};

scenario_labels = {
  'Easier tie readiness';
  'Baseline readiness';
  'Easier boundary readiness';
  'Harder boundary readiness';
  'Harder tie readiness'
};

header = {'figure_id', 'scenario_code', 'scenario_label', ...
  'theta', 'q', ...
  'BS_low_convergence_rate', 'BS_high_convergence_rate', ...
  'BS_low_mean_T', 'BS_high_mean_T', ...
  'BS_low_median_T', 'BS_high_median_T', ...
  'BS_low_p90_T', 'BS_high_p90_T', ...
  'BS_low_p95_T', 'BS_high_p95_T', ...
  'p95_difference', 'p95_ci_low', 'p95_ci_high', ...
  'p95_reduction_pct', 'n_boot'};

rows = {};

for s = 1:length(scenario_codes)

  D_low = load(threshold_low_files{s});
  D_high = load(threshold_high_files{s});

  S_low = graph_level_summary_from_results(D_low.results);
  S_high = graph_level_summary_from_results(D_high.results);

  x_p95 = graph_metric_vector_from_results(D_low.results, 'p95_T');
  y_p95 = graph_metric_vector_from_results(D_high.results, 'p95_T');

  B_p95 = bootstrap_graph_difference(x_p95, y_p95, n_boot, true);

  new_row = {
    'fig_09', scenario_codes{s}, scenario_labels{s}, ...
    theta_values(s), q_values(s), ...
    S_low.convergence_rate, S_high.convergence_rate, ...
    S_low.mean_T, S_high.mean_T, ...
    S_low.median_T, S_high.median_T, ...
    S_low.p90_T, S_high.p90_T, ...
    S_low.p95_T, S_high.p95_T, ...
    B_p95.difference, B_p95.ci_low, B_p95.ci_high, ...
    B_p95.reduction_pct, B_p95.n_boot
  };

  rows = [rows; new_row];
end

write_cell_csv('../results/figure_data/fig_09_readiness_threshold_robustness.csv', ...
  header, rows);

fprintf('Wrote fig_09_readiness_threshold_robustness.csv\n');

fprintf('\n============================================\n');
fprintf('ALL FIGURE-DATA CSV FILES BUILT SUCCESSFULLY\n');
fprintf('Output folder: ../results/figure_data/\n');
fprintf('============================================\n');
