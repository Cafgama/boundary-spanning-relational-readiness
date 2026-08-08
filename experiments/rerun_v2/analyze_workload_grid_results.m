function exports = analyze_workload_grid_results(processed_file)
  % ANALYZE_WORKLOAD_GRID_RESULTS
  % Reads a rerun_v2 workload-grid processed file and exports clean CSVs plus
  % a manuscript handover document.
  %
  % Usage:
  %   exports = analyze_workload_grid_results()
  %   exports = analyze_workload_grid_results(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/workload_grid/workload_grid_processed_*.mat file
  % is used. This script does not run simulations.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'workload_grid');
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', 'workload_grid');
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  if nargin < 1 || isempty(processed_file)
    processed_file = latest_workload_processed_file(processed_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Processed workload-grid file not found: ', processed_file]);

  loaded = load(processed_file);
  assert(isfield(loaded, 'workload_grid'), ...
    'Processed file must contain a workload_grid structure.');

  workload_grid = loaded.workload_grid;
  validate_workload_grid_structure(workload_grid);

  condition_rows = build_condition_rows(workload_grid);
  contrast_rows = build_contrast_rows(workload_grid);
  monotonic = compute_monotonic_summary(condition_rows);

  alerts = {};

  if workload_grid.n_alerts > 0
    for i = 1:length(workload_grid.alerts)
      alerts{end + 1} = workload_grid.alerts{i};
    end
  end

  if monotonic.RMST_monotonic_decreasing == 0
    alerts{end + 1} = 'EXPORT_ALERT_RMST_NOT_MONOTONIC_DECREASING_IN_B';
  end

  if monotonic.T95_monotonic_decreasing == 0
    alerts{end + 1} = 'EXPORT_ALERT_T95_NOT_MONOTONIC_DECREASING_IN_B';
  end

  condition_csv_processed = fullfile(processed_dir, 'workload_grid_condition_estimands.csv');
  contrast_csv_processed = fullfile(processed_dir, 'workload_grid_contrasts.csv');
  condition_csv_figure = fullfile(figure_data_dir, 'workload_grid_condition_estimands.csv');
  contrast_csv_figure = fullfile(figure_data_dir, 'workload_grid_contrasts.csv');
  handover_file = fullfile(docs_dir, 'workload_grid_results_handover.md');

  write_condition_csv(condition_csv_processed, condition_rows);
  write_contrast_csv(contrast_csv_processed, contrast_rows);

  copyfile(condition_csv_processed, condition_csv_figure);
  copyfile(contrast_csv_processed, contrast_csv_figure);

  write_workload_grid_handover(handover_file, workload_grid, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, monotonic, alerts);

  exports = struct();
  exports.processed_file = processed_file;
  exports.condition_csv_processed = condition_csv_processed;
  exports.contrast_csv_processed = contrast_csv_processed;
  exports.condition_csv_figure = condition_csv_figure;
  exports.contrast_csv_figure = contrast_csv_figure;
  exports.handover_file = handover_file;
  exports.condition_rows = condition_rows;
  exports.contrast_rows = contrast_rows;
  exports.monotonic = monotonic;
  exports.alerts = alerts(:);
  exports.n_alerts = length(alerts);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 WORKLOAD-GRID EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('condition CSV: %s\n', condition_csv_processed);
  fprintf('contrast CSV: %s\n', contrast_csv_processed);
  fprintf('handover: %s\n', handover_file);

  fprintf('\nWorkload monotonicity summary\n');
  fprintf('--------------------------------------------\n');
  fprintf('b values:\n');
  disp(monotonic.b);
  fprintf('load_per_spanner values:\n');
  disp(monotonic.load_per_spanner);
  fprintf('RMST values:\n');
  disp(monotonic.RMST_values);
  fprintf('T95 values:\n');
  disp(monotonic.T95_values);
  fprintf('RMST changes as b increases:\n');
  disp(monotonic.RMST_changes);
  fprintf('T95 changes as b increases:\n');
  disp(monotonic.T95_changes);
  fprintf('RMST_monotonic_decreasing = %d\n', monotonic.RMST_monotonic_decreasing);
  fprintf('T95_monotonic_decreasing = %d\n', monotonic.T95_monotonic_decreasing);

  fprintf('\nExport diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No workload-grid export alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  fprintf('\n============================================\n');
  fprintf('RERUN V2 WORKLOAD-GRID EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_workload_processed_file(processed_dir)
  files = dir(fullfile(processed_dir, 'workload_grid_processed_*.mat'));
  assert(~isempty(files), ...
    ['No workload-grid processed file found in ', processed_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(processed_dir, files(idx).name);
end


function validate_workload_grid_structure(workload_grid)
  required_fields = {
    'run_type', 'timestamp', 'NG', 'NT', 'T_max', 'n_boot', ...
    'seed_base', 'bootstrap_seed', 'theta', 'q', 'pi_out', 'pi_BS', ...
    'b_grid', 'conditions', 'estimands', 'bootstraps', 'alerts', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(workload_grid, fname), ...
      ['workload_grid missing field: ', fname]);
  end

  assert(length(workload_grid.b_grid) >= 2, ...
    'workload_grid.b_grid must contain at least two values.');
  assert(all(diff(workload_grid.b_grid) > 0), ...
    'workload_grid.b_grid must be strictly increasing.');
end


function rows = build_condition_rows(workload_grid)
  conditions = workload_grid.conditions;
  rows = [];

  for i = 1:length(conditions)
    C = conditions(i);
    cname = C.condition_id;
    S = workload_grid.estimands.(cname);
    R = workload_grid.results.(cname);

    row = struct();
    row.condition_id = cname;
    row.architecture = C.architecture;
    row.b = C.P.b;
    row.load_per_spanner = C.load_per_spanner;
    row.pi_out = C.P.pi_out;
    row.pi_BS = C.P.pi_BS;
    row.readiness_probability = S.readiness_probability;
    row.censoring_probability = S.censoring_probability;
    row.RMST = S.RMST;
    row.T50 = S.T50;
    row.T50_estimable = S.T50_estimable;
    row.T90 = S.T90;
    row.T90_estimable = S.T90_estimable;
    row.T95 = S.T95;
    row.T95_estimable = S.T95_estimable;
    row.workload_mean = first_value(R.workload_mean);
    row.workload_min = first_value(R.workload_min);
    row.workload_max = first_value(R.workload_max);
    row.workload_sd = first_value(R.workload_sd);

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function value = first_value(x)
  if isempty(x)
    value = NaN;
  else
    value = x(1);
  end
end


function rows = build_contrast_rows(workload_grid)
  names = fieldnames(workload_grid.bootstraps);
  rows = [];

  for i = 1:length(names)
    contrast_id = names{i};
    B = workload_grid.bootstraps.(contrast_id);
    [x_condition, y_condition] = split_contrast_id(contrast_id);

    row = struct();
    row.contrast_id = contrast_id;
    row.x_condition = x_condition;
    row.y_condition = y_condition;
    row.n_boot = B.n_boot;
    row.n_graphs = B.n_graphs;
    row.n_matched_trajectories = B.n_matched_trajectories;

    row.rmst_difference = B.observed_difference.rmst;
    row.rmst_ci_low = B.ci_low.rmst;
    row.rmst_ci_high = B.ci_high.rmst;

    row.readiness_probability_difference = B.observed_difference.readiness_probability;
    row.readiness_probability_ci_low = B.ci_low.readiness_probability;
    row.readiness_probability_ci_high = B.ci_high.readiness_probability;

    row.T50_difference = B.observed_difference.T50;
    row.T50_ci_low = B.ci_low.T50;
    row.T50_ci_high = B.ci_high.T50;
    row.T50_valid_share = B.bootstrap_valid_share.T50;

    row.T90_difference = B.observed_difference.T90;
    row.T90_ci_low = B.ci_low.T90;
    row.T90_ci_high = B.ci_high.T90;
    row.T90_valid_share = B.bootstrap_valid_share.T90;

    row.T95_difference = B.observed_difference.T95;
    row.T95_ci_low = B.ci_low.T95;
    row.T95_ci_high = B.ci_high.T95;
    row.T95_valid_share = B.bootstrap_valid_share.T95;

    row.rmst_interpretation = B.time_metric_interpretation;
    row.T95_interpretation = B.time_metric_interpretation;

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function [x_condition, y_condition] = split_contrast_id(contrast_id)
  idx = strfind(contrast_id, '_minus_');
  assert(~isempty(idx), ['Invalid contrast id: ', contrast_id]);
  idx = idx(1);
  x_condition = contrast_id(1:(idx - 1));
  y_condition = contrast_id((idx + length('_minus_')):end);
end


function monotonic = compute_monotonic_summary(condition_rows)
  n = length(condition_rows);

  b = zeros(n, 1);
  load_per_spanner = zeros(n, 1);
  RMST_values = zeros(n, 1);
  T95_values = zeros(n, 1);

  for i = 1:n
    b(i) = condition_rows(i).b;
    load_per_spanner(i) = condition_rows(i).load_per_spanner;
    RMST_values(i) = condition_rows(i).RMST;
    T95_values(i) = condition_rows(i).T95;
  end

  monotonic = struct();
  monotonic.b = b;
  monotonic.load_per_spanner = load_per_spanner;
  monotonic.RMST_values = RMST_values;
  monotonic.T95_values = T95_values;
  monotonic.RMST_changes = diff(RMST_values);
  monotonic.T95_changes = diff(T95_values);
  monotonic.RMST_monotonic_decreasing = all(diff(RMST_values) <= 0);
  monotonic.T95_monotonic_decreasing = all(diff(T95_values) <= 0);
end


function write_condition_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['condition_id,architecture,b,load_per_spanner,pi_out,pi_BS,', ...
    'readiness_probability,censoring_probability,RMST,T50,T50_estimable,', ...
    'T90,T90_estimable,T95,T95_estimable,workload_mean,workload_min,', ...
    'workload_max,workload_sd\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%.6f,%d,%.6f,%d,%.6f,%.6f,%.6f,%.6f\n', ...
      r.condition_id, r.architecture, r.b, r.load_per_spanner, ...
      r.pi_out, r.pi_BS, r.readiness_probability, r.censoring_probability, ...
      r.RMST, r.T50, r.T50_estimable, r.T90, r.T90_estimable, ...
      r.T95, r.T95_estimable, r.workload_mean, r.workload_min, ...
      r.workload_max, r.workload_sd);
  end

  fclose(fid);
end


function write_contrast_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['contrast_id,x_condition,y_condition,n_boot,n_graphs,', ...
    'n_matched_trajectories,rmst_difference,rmst_ci_low,rmst_ci_high,', ...
    'readiness_probability_difference,readiness_probability_ci_low,', ...
    'readiness_probability_ci_high,T50_difference,T50_ci_low,T50_ci_high,', ...
    'T50_valid_share,T90_difference,T90_ci_low,T90_ci_high,T90_valid_share,', ...
    'T95_difference,T95_ci_low,T95_ci_high,T95_valid_share,rmst_interpretation,', ...
    'T95_interpretation\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%s,%d,%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%s,%s\n', ...
      r.contrast_id, r.x_condition, r.y_condition, r.n_boot, r.n_graphs, ...
      r.n_matched_trajectories, r.rmst_difference, r.rmst_ci_low, ...
      r.rmst_ci_high, r.readiness_probability_difference, ...
      r.readiness_probability_ci_low, r.readiness_probability_ci_high, ...
      r.T50_difference, r.T50_ci_low, r.T50_ci_high, r.T50_valid_share, ...
      r.T90_difference, r.T90_ci_low, r.T90_ci_high, r.T90_valid_share, ...
      r.T95_difference, r.T95_ci_low, r.T95_ci_high, r.T95_valid_share, ...
      r.rmst_interpretation, r.T95_interpretation);
  end

  fclose(fid);
end


function write_workload_grid_handover(filename, workload_grid, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, monotonic, alerts)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Workload-grid results handover — rerun_v2\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_workload_grid_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', workload_grid.run_type);
  fprintf(fid, '- Output tag: `%s`\n', workload_grid.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', workload_grid.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', workload_grid.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', workload_grid.NT);
  fprintf(fid, '- T_max: %d\n', workload_grid.T_max);
  fprintf(fid, '- Bootstrap replications: %d\n', workload_grid.n_boot);
  fprintf(fid, '- Seed base: %d\n', workload_grid.seed_base);
  fprintf(fid, '- Bootstrap seed: %d\n', workload_grid.bootstrap_seed);
  fprintf(fid, '- Theta: %.2f\n', workload_grid.theta);
  fprintf(fid, '- q: %.2f\n', workload_grid.q);
  fprintf(fid, '- pi_out: %.2f\n', workload_grid.pi_out);
  fprintf(fid, '- pi_BS: %.2f\n', workload_grid.pi_BS);
  fprintf(fid, '- Diagnostic alerts: %d\n\n', length(alerts));

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimands CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- Contrast CSV: `%s`\n', contrast_csv_processed);
  fprintf(fid, '- Figure-data condition CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data contrast CSV: `%s`\n\n', contrast_csv_figure);

  fprintf(fid, '## Condition-level estimands\n\n');
  fprintf(fid, '| Condition | b | Load per spanner | Readiness probability | Censoring probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf(fid, '| `%s` | %d | %.2f | %.3f | %.3f | %.2f | %.2f | %.2f | %.2f |\n', ...
      r.condition_id, r.b, r.load_per_spanner, r.readiness_probability, ...
      r.censoring_probability, r.RMST, r.T50, r.T90, r.T95);
  end

  fprintf(fid, '\n## Workload monotonicity\n\n');
  fprintf(fid, '- RMST monotonic decreasing as b increases: `%d`\n', monotonic.RMST_monotonic_decreasing);
  fprintf(fid, '- T95 monotonic decreasing as b increases: `%d`\n\n', monotonic.T95_monotonic_decreasing);

  fprintf(fid, '| Transition | RMST change | T95 change |\n');
  fprintf(fid, '|---|---:|---:|\n');
  for i = 1:(length(monotonic.b) - 1)
    fprintf(fid, '| b=%d to b=%d | %.2f | %.2f |\n', ...
      monotonic.b(i), monotonic.b(i + 1), ...
      monotonic.RMST_changes(i), monotonic.T95_changes(i));
  end

  fprintf(fid, '\n## Contrast-level results\n\n');
  fprintf(fid, 'Differences are computed as condition X minus condition Y. For time metrics, positive values mean that condition Y is faster/lower.\n\n');
  fprintf(fid, '| Contrast | RMST difference | RMST 95%% CI | T95 difference | T95 95%% CI | T95 valid share | RMST interpretation |\n');
  fprintf(fid, '|---|---:|---:|---:|---:|---:|---|\n');

  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    fprintf(fid, '| `%s` | %.2f | [%.2f, %.2f] | %.2f | [%.2f, %.2f] | %.3f | `%s` |\n', ...
      r.contrast_id, r.rmst_difference, r.rmst_ci_low, r.rmst_ci_high, ...
      r.T95_difference, r.T95_ci_low, r.T95_ci_high, ...
      r.T95_valid_share, r.rmst_interpretation);
  end

  fprintf(fid, '\n## Claims supported by the workload-grid run\n\n');
  fprintf(fid, '### Workload/capacity effect\n\n');
  fprintf(fid, '- Claim status: supported if RMST and T95 decrease as b increases.\n');
  fprintf(fid, '- RMST monotonic decreasing: `%d`.\n', monotonic.RMST_monotonic_decreasing);
  fprintf(fid, '- T95 monotonic decreasing: `%d`.\n', monotonic.T95_monotonic_decreasing);
  fprintf(fid, '- Interpretation: when the same cross-boundary tie budget is distributed across more boundary spanners, the per-spanner load decreases and relational readiness is reached faster.\n\n');

  fprintf(fid, '## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- Increasing b changes the distribution of boundary-spanning workload under the fixed cross-boundary tie budget k=12.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`, while event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.\n');
  fprintf(fid, '- This handover covers only the workload-grid comparison. It should be combined later with final core and translation-grid handovers.\n\n');

  fprintf(fid, '## Export diagnostic alerts\n\n');
  if isempty(alerts)
    fprintf(fid, '- None.\n');
  else
    for i = 1:length(alerts)
      fprintf(fid, '- `%s`\n', alerts{i});
    end
  end

  fclose(fid);
end
