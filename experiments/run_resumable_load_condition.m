% RUN_RESUMABLE_LOAD_CONDITION
% Resumable boundary-spanner load robustness experiment.
%
% This script runs one boundary-spanner load condition at a time.
%
% Load grid:
%   b = 1, 2, 4, 6
%
% where b is the number of boundary spanners per side.
%
% Cross-boundary tie budget:
%   k = 12
%
% Approximate load per boundary spanner:
%   load = k / (2*b)

clear;
clc;

addpath('../src');

% ------------------------------------------------------------
% User setting: choose ONE value at a time
% ------------------------------------------------------------
% b_value = 1;
% b_value = 2;
% b_value = 4;
 b_value = 6;

% ------------------------------------------------------------
% Base parameters
% ------------------------------------------------------------
P = baseline_params();

architecture = 'boundary_spanning';

P.b = b_value;

% Full boundary-spanning mechanism.
P.pi_out = 0.55;
P.pi_BS = 0.65;

NG = 50;
NT = 50;

P.T_max = 50000;

% Dedicated seed base for load-grid experiments.
seed_base = P.seed + 13000;

b_label = sprintf('%02d', b_value);

condition_label = ['LOAD_b_', b_label];

experiment_label = ['load_', condition_label, '_NG', ...
  num2str(NG), '_NT', num2str(NT)];

load_per_spanner = P.k / (2 * P.b);

% ------------------------------------------------------------
% Folders
% ------------------------------------------------------------
ensure_dir('../results');
ensure_dir('../results/raw');
ensure_dir('../results/processed');
ensure_dir('../results/checkpoints');

checkpoint_file = ['../results/checkpoints/', experiment_label, '.mat'];

% ------------------------------------------------------------
% Initialize or resume
% ------------------------------------------------------------
if exist(checkpoint_file, 'file') == 2

  fprintf('\nExisting checkpoint found. Loading:\n%s\n', checkpoint_file);
  load(checkpoint_file);

  start_graph = last_completed_graph + 1;
  previous_elapsed_time = elapsed_time;

  fprintf('Resuming from graph %d/%d.\n', start_graph, NG);

else

  fprintf('\nNo checkpoint found. Starting new load condition.\n');

  total_runs = NG * NT;

  graph_id = zeros(total_runs, 1);
  trajectory_id = zeros(total_runs, 1);

  T = NaN(total_runs, 1);
  converged = zeros(total_runs, 1);
  final_RB = NaN(total_runs, 1);
  final_ready = NaN(total_runs, 1);
  total_boundary_edges = NaN(total_runs, 1);

  total_edges = NaN(total_runs, 1);
  mean_degree = NaN(total_runs, 1);
  max_degree = NaN(total_runs, 1);

  last_completed_graph = 0;
  start_graph = 1;

  elapsed_time = 0;
  previous_elapsed_time = 0;
end

overall_tic = tic;

fprintf('\n============================================\n');
fprintf('RESUMABLE BOUNDARY-SPANNER LOAD CONDITION\n');
fprintf('Condition: %s\n', condition_label);
fprintf('Network architecture: %s\n', architecture);
fprintf('b: %d boundary spanners per side\n', P.b);
fprintf('k: %d cross-boundary ties\n', P.k);
fprintf('Approximate load per spanner: %.2f\n', load_per_spanner);
fprintf('pi_out: %.2f | pi_BS: %.2f\n', P.pi_out, P.pi_BS);
fprintf('NG: %d | NT: %d | T_max: %d\n', NG, NT, P.T_max);
fprintf('Seed base: %d\n', seed_base);
fprintf('Checkpoint file:\n%s\n', checkpoint_file);
fprintf('============================================\n\n');

% ------------------------------------------------------------
% Main graph loop
% ------------------------------------------------------------
for g = start_graph:NG

  graph_tic = tic;

  fprintf('\nCondition: %s | Graph %d/%d started.\n', ...
    condition_label, g, NG);

  % Deterministic graph seed.
  rand('seed', seed_base + g);

  G = safe_generate_network(P, architecture);

  graph_total_edges = sum(sum(G.A)) / 2;
  degrees = sum(G.A, 2);
  graph_mean_degree = mean(degrees);
  graph_max_degree = max(degrees);

  for r = 1:NT

    row = (g - 1) * NT + r;

    % Deterministic trajectory seed.
    rand('seed', seed_base + 100000 * g + r);

    out = run_dynamics_fast(G, P, false);

    graph_id(row) = g;
    trajectory_id(row) = r;

    T(row) = out.T;
    converged(row) = out.converged;
    final_RB(row) = out.final_RB;
    final_ready(row) = out.final_ready;
    total_boundary_edges(row) = out.total_boundary_edges;

    total_edges(row) = graph_total_edges;
    mean_degree(row) = graph_mean_degree;
    max_degree(row) = graph_max_degree;
  end

  last_completed_graph = g;
  elapsed_time = previous_elapsed_time + toc(overall_tic);
  graph_elapsed_time = toc(graph_tic);

  save(checkpoint_file, ...
    'condition_label', 'architecture', 'b_value', 'load_per_spanner', ...
    'NG', 'NT', 'P', 'seed_base', ...
    'graph_id', 'trajectory_id', 'T', 'converged', ...
    'final_RB', 'final_ready', 'total_boundary_edges', ...
    'total_edges', 'mean_degree', 'max_degree', ...
    'last_completed_graph', 'elapsed_time');

  fprintf('Condition: %s | Graph %d/%d completed and saved.\n', ...
    condition_label, g, NG);

  fprintf('Graph elapsed time: %.2f seconds | %.2f minutes\n', ...
    graph_elapsed_time, graph_elapsed_time / 60);

  fprintf('Elapsed time so far: %.2f seconds | %.2f hours\n', ...
    elapsed_time, elapsed_time / 3600);
end

% ------------------------------------------------------------
% Package final results
% ------------------------------------------------------------
results.architecture = condition_label;
results.network_architecture = architecture;
results.condition_label = condition_label;
results.b_value = b_value;
results.load_per_spanner = load_per_spanner;

results.NG = NG;
results.NT = NT;
results.seed = seed_base;

results.graph_id = graph_id;
results.trajectory_id = trajectory_id;

results.T = T;
results.converged = converged;
results.final_RB = final_RB;
results.final_ready = final_ready;
results.total_boundary_edges = total_boundary_edges;

results.total_edges = total_edges;
results.mean_degree = mean_degree;
results.max_degree = max_degree;

results.n_runs = NG * NT;
results.n_converged = sum(converged == 1);
results.n_nonconverged = sum(converged == 0);
results.nonconvergence_rate = results.n_nonconverged / results.n_runs;

summary = summarize_results(results, P);

timestamp = datestr(now(), 'yyyymmdd_HHMMSS');

raw_file = ['../results/raw/', experiment_label, '_results_', timestamp, '.mat'];
summary_file = ['../results/processed/', experiment_label, '_summary_', timestamp, '.mat'];
summary_csv_file = ['../results/processed/', experiment_label, '_summary_', timestamp, '.csv'];

save(raw_file, ...
  'results', 'P', 'condition_label', 'architecture', ...
  'b_value', 'load_per_spanner', ...
  'NG', 'NT', 'seed_base', 'elapsed_time');

save(summary_file, ...
  'summary', 'P', 'condition_label', 'architecture', ...
  'b_value', 'load_per_spanner', ...
  'NG', 'NT', 'seed_base', 'elapsed_time');

export_summary_csv({summary}, summary_csv_file);

fprintf('\n============================================\n');
fprintf('LOAD CONDITION COMPLETED\n');
fprintf('Condition: %s\n', condition_label);
fprintf('Network architecture: %s\n', architecture);
fprintf('b: %d boundary spanners per side\n', P.b);
fprintf('Approximate load per spanner: %.2f\n', load_per_spanner);
fprintf('pi_out: %.2f | pi_BS: %.2f\n', P.pi_out, P.pi_BS);
fprintf('Runs: %d\n', results.n_runs);
fprintf('Convergence rate: %.3f\n', summary.convergence_rate);
fprintf('Non-convergence rate: %.3f\n', summary.nonconvergence_rate);
fprintf('Median censored T: %.2f\n', summary.T_cens_median);
fprintf('P95 censored T: %.2f\n', summary.T_cens_p95);
fprintf('Elapsed time: %.2f hours\n', elapsed_time / 3600);
fprintf('============================================\n');

fprintf('\nSaved raw results to:\n%s\n', raw_file);
fprintf('\nSaved summary results to:\n%s\n', summary_file);
fprintf('\nSaved summary CSV to:\n%s\n', summary_csv_file);
