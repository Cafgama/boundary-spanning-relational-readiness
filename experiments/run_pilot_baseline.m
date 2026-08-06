% RUN_PILOT_BASELINE
% Pilot experiment for the boundary-spanning relational readiness model.
%
% Purpose:
%   1. Run a moderate-size experiment across the three architectures.
%   2. Check whether the qualitative behavior is stable beyond the tiny debug run.
%   3. Produce CSV and MAT outputs for inspection.
%
% This is still not the final full experiment for the paper.

clear;
clc;

addpath('../src');

% -----------------------------
% Load parameters
% -----------------------------
P = baseline_params();

% Pilot replication size.
NG = 10;
NT = 20;

% Use the baseline maximum horizon.
P.T_max = 50000;

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

% -----------------------------
% Prepare result folders
% -----------------------------
ensure_dir('../results');
ensure_dir('../results/raw');
ensure_dir('../results/processed');

% -----------------------------
% Start timer
% -----------------------------
tic;

% -----------------------------
% Run experiments
% -----------------------------
all_results = cell(length(architectures), 1);
all_summaries = cell(length(architectures), 1);

fprintf('\n============================================\n');
fprintf('PILOT EXPERIMENT\n');
fprintf('============================================\n');
fprintf('Graph realizations per architecture: %d\n', NG);
fprintf('Trajectories per graph: %d\n', NT);
fprintf('Total trajectories per architecture: %d\n', NG * NT);
fprintf('T_max: %d\n', P.T_max);
fprintf('theta: %.2f | q: %.2f\n', P.theta, P.q);
fprintf('============================================\n\n');

for a = 1:length(architectures)

  arch = architectures{a};

  fprintf('\n--------------------------------------------\n');
  fprintf('Running architecture: %s\n', arch);
  fprintf('--------------------------------------------\n');

  seed_a = P.seed + 1000 * a;

  results = run_single_experiment(P, arch, NG, NT, seed_a);
  summary = summarize_results(results, P);

  all_results{a} = results;
  all_summaries{a} = summary;
end

elapsed_time = toc;

% -----------------------------
% Print summary table
% -----------------------------
fprintf('\n\n============================================\n');
fprintf('PILOT SUMMARY TABLE\n');
fprintf('============================================\n');

fprintf('%-22s %8s %8s %10s %12s %12s %12s %12s\n', ...
  'Architecture', ...
  'Runs', ...
  'Conv', ...
  'NC_rate', ...
  'Tmed_cens', ...
  'T_p90', ...
  'T_p95', ...
  'RB_final');

for a = 1:length(all_summaries)

  S = all_summaries{a};

  fprintf('%-22s %8d %8.3f %10.3f %12.2f %12.2f %12.2f %12.3f\n', ...
    S.architecture, ...
    S.n_runs, ...
    S.convergence_rate, ...
    S.nonconvergence_rate, ...
    S.T_cens_median, ...
    S.T_cens_p90, ...
    S.T_cens_p95, ...
    S.final_RB_mean);
end

fprintf('============================================\n');
fprintf('Elapsed time: %.2f seconds\n', elapsed_time);
fprintf('============================================\n');

% -----------------------------
% Save results
% -----------------------------
timestamp = datestr(now(), 'yyyymmdd_HHMMSS');

raw_file = ['../results/raw/pilot_results_', timestamp, '.mat'];
summary_file = ['../results/processed/pilot_summary_', timestamp, '.mat'];
summary_csv_file = ['../results/processed/pilot_summary_', timestamp, '.csv'];

save(raw_file, 'all_results', 'P', 'architectures', 'NG', 'NT', 'elapsed_time');
save(summary_file, 'all_summaries', 'P', 'architectures', 'NG', 'NT', 'elapsed_time');

export_summary_csv(all_summaries, summary_csv_file);

fprintf('\nSaved raw results to:\n%s\n', raw_file);
fprintf('\nSaved summary results to:\n%s\n', summary_file);
fprintf('\nSaved summary CSV to:\n%s\n', summary_csv_file);

fprintf('\nPilot experiment completed successfully.\n');
