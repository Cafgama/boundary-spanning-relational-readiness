function exports = analyze_final_core_results(processed_file, output_tag_override)
  % ANALYZE_FINAL_CORE_RESULTS
  % Step 13 export script for the rerun_v2 final core production results.
  %
  % Purpose:
  %   Read the final_core processed .mat file and export clean manuscript-facing
  %   tables, diagnostics, and a Markdown handover for the writing chat.
  %
  % Usage:
  %   exports = analyze_final_core_results()
  %   exports = analyze_final_core_results(processed_file)
  %   exports = analyze_final_core_results(processed_file, output_tag_override)
  %
  % Default input:
  %   latest results/processed/rerun_v2/final_core/final_core_processed_*.mat
  %
  % Default outputs:
  %   results/processed/rerun_v2/final_core/final_core_condition_estimands.csv
  %   results/processed/rerun_v2/final_core/final_core_contrasts.csv
  %   results/figure_data/rerun_v2/final_core/final_core_condition_estimands.csv
  %   results/figure_data/rerun_v2/final_core/final_core_contrasts.csv
  %   docs/manuscript_results_handover.md

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  if nargin < 1 || isempty(processed_file)
    final_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'final_core');
    processed_file = latest_final_core_processed_file(final_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Final-core processed file not found: ', processed_file]);

  loaded = load(processed_file);
  assert(isfield(loaded, 'final_core'), ...
    'Processed file must contain final_core structure.');

  final_core = loaded.final_core;
  validate_final_core_structure(final_core);

  if nargin < 2 || isempty(output_tag_override)
    output_tag = final_core.output_tag;
  else
    output_tag = output_tag_override;
  end

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', output_tag);
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', output_tag);
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  condition_rows = build_condition_rows(final_core);
  contrast_rows = build_contrast_rows(final_core);

  condition_csv_processed = fullfile(processed_dir, 'final_core_condition_estimands.csv');
  contrast_csv_processed = fullfile(processed_dir, 'final_core_contrasts.csv');

  condition_csv_figure = fullfile(figure_data_dir, 'final_core_condition_estimands.csv');
  contrast_csv_figure = fullfile(figure_data_dir, 'final_core_contrasts.csv');

  write_condition_csv(condition_csv_processed, condition_rows);
  write_contrast_csv(contrast_csv_processed, contrast_rows);
  write_condition_csv(condition_csv_figure, condition_rows);
  write_contrast_csv(contrast_csv_figure, contrast_rows);

  if strcmp(output_tag, 'final_core')
    handover_file = fullfile(docs_dir, 'manuscript_results_handover.md');
  else
    handover_file = fullfile(docs_dir, ['manuscript_results_handover_', output_tag, '.md']);
  end

  write_manuscript_handover(handover_file, final_core, processed_file, ...
    condition_rows, contrast_rows, condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure);

  exports = struct();
  exports.processed_file = processed_file;
  exports.output_tag = output_tag;
  exports.condition_csv_processed = condition_csv_processed;
  exports.contrast_csv_processed = contrast_csv_processed;
  exports.condition_csv_figure = condition_csv_figure;
  exports.contrast_csv_figure = contrast_csv_figure;
  exports.handover_file = handover_file;
  exports.condition_rows = condition_rows;
  exports.contrast_rows = contrast_rows;
  exports.n_alerts = final_core.n_alerts;

  fprintf('\n============================================\n');
  fprintf('RERUN V2 FINAL CORE EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('output_tag: %s\n', output_tag);
  fprintf('condition CSV: %s\n', condition_csv_processed);
  fprintf('contrast CSV: %s\n', contrast_csv_processed);
  fprintf('figure-data condition CSV: %s\n', condition_csv_figure);
  fprintf('figure-data contrast CSV: %s\n', contrast_csv_figure);
  fprintf('handover: %s\n', handover_file);
  fprintf('n_alerts: %d\n', final_core.n_alerts);

  fprintf('\nCondition summary\n');
  fprintf('--------------------------------------------\n');
  for i = 1:length(condition_rows)
    R = condition_rows(i);
    fprintf('%s | readiness %.3f | censoring %.3f | RMST %.2f | T95 ', ...
      R.condition_id, R.readiness_probability, R.censoring_probability, R.RMST);
    print_estimable(R.T95, R.T95_estimable);
    fprintf('\n');
  end

  fprintf('\nContrast summary\n');
  fprintf('--------------------------------------------\n');
  for i = 1:length(contrast_rows)
    C = contrast_rows(i);
    fprintf('%s | RMST diff %.2f CI [%.2f, %.2f] | T95 diff ', ...
      C.contrast_id, C.rmst_difference, C.rmst_ci_low, C.rmst_ci_high);
    print_numeric_or_nan(C.T95_difference);
    fprintf(' CI [');
    print_numeric_or_nan(C.T95_ci_low);
    fprintf(', ');
    print_numeric_or_nan(C.T95_ci_high);
    fprintf('] | valid %.3f\n', C.T95_valid_share);
  end

  fprintf('\n============================================\n');
  fprintf('RERUN V2 FINAL CORE EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_final_core_processed_file(final_dir)
  files = dir(fullfile(final_dir, 'final_core_processed_*.mat'));

  assert(~isempty(files), ...
    ['No final_core_processed_*.mat file found in ', final_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(final_dir, files(idx).name);
end


function validate_final_core_structure(final_core)
  required_fields = {
    'run_type', 'output_tag', 'timestamp', 'NG', 'NT', 'T_max', 'n_boot', ...
    'seed_base', 'bootstrap_seed', 'theta', 'q', 'conditions', ...
    'estimands', 'bootstraps', 'alerts', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(final_core, fname), ['final_core missing field: ', fname]);
  end

  assert(isstruct(final_core.estimands), 'final_core.estimands must be a struct.');
  assert(isstruct(final_core.bootstraps), 'final_core.bootstraps must be a struct.');
  assert(final_core.NG > 0 && final_core.NT > 0, 'NG and NT must be positive.');
  assert(final_core.T_max > 0, 'T_max must be positive.');
  assert(final_core.n_boot > 0, 'n_boot must be positive.');
end


function rows_out = build_condition_rows(final_core)
  preferred_names = {'RB_low', 'BS_low', 'BS_high'};
  condition_names = select_names(preferred_names, fieldnames(final_core.estimands));

  rows_out = struct([]);

  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = final_core.estimands.(cname);
    C = find_condition(final_core.conditions, cname);

    row = struct();
    row.condition_id = cname;
    row.architecture = C.architecture;
    row.pi_out = C.P.pi_out;
    row.pi_BS = C.P.pi_BS;
    row.b = C.P.b;
    row.k = C.P.k;
    row.theta = final_core.theta;
    row.q = final_core.q;
    row.T_max = final_core.T_max;
    row.n = S.n;
    row.n_events = S.n_events;
    row.n_censored = S.n_censored;
    row.readiness_probability = S.readiness_probability;
    row.censoring_probability = S.censoring_probability;
    row.RMST = S.RMST;
    row.T50 = S.T50;
    row.T50_estimable = S.T50_estimable;
    row.T90 = S.T90;
    row.T90_estimable = S.T90_estimable;
    row.T95 = S.T95;
    row.T95_estimable = S.T95_estimable;

    if isempty(rows_out)
      rows_out = row;
    else
      rows_out(end + 1) = row;
    end
  end
end


function rows_out = build_contrast_rows(final_core)
  preferred_names = {'RB_low_minus_BS_low', 'BS_low_minus_BS_high', 'RB_low_minus_BS_high'};
  contrast_names = select_names(preferred_names, fieldnames(final_core.bootstraps));

  rows_out = struct([]);

  for i = 1:length(contrast_names)
    bname = contrast_names{i};
    B = final_core.bootstraps.(bname);
    [x_name, y_name] = split_contrast_name(bname);

    row = struct();
    row.contrast_id = bname;
    row.x_condition = x_name;
    row.y_condition = y_name;
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

    row.rmst_interpretation = interpret_time_metric(row.rmst_difference, row.rmst_ci_low, row.rmst_ci_high, x_name, y_name);
    row.T95_interpretation = interpret_time_metric(row.T95_difference, row.T95_ci_low, row.T95_ci_high, x_name, y_name);

    if isempty(rows_out)
      rows_out = row;
    else
      rows_out(end + 1) = row;
    end
  end
end


function selected = select_names(preferred, available)
  selected = {};

  for i = 1:length(preferred)
    if any(strcmp(available, preferred{i}))
      selected{end + 1} = preferred{i};
    end
  end

  for i = 1:length(available)
    if ~any(strcmp(selected, available{i}))
      selected{end + 1} = available{i};
    end
  end
end


function C = find_condition(conditions, condition_id)
  for i = 1:length(conditions)
    if strcmp(conditions(i).condition_id, condition_id)
      C = conditions(i);
      return;
    end
  end

  error(['Condition not found in final_core.conditions: ', condition_id]);
end


function [x_name, y_name] = split_contrast_name(contrast_id)
  marker = '_minus_';
  idx = strfind(contrast_id, marker);

  if isempty(idx)
    x_name = '';
    y_name = '';
  else
    idx = idx(1);
    x_name = contrast_id(1:(idx - 1));
    y_name = contrast_id((idx + length(marker)):end);
  end
end


function interpretation = interpret_time_metric(diff_value, ci_low, ci_high, x_name, y_name)
  if isnan(diff_value) || isnan(ci_low) || isnan(ci_high)
    interpretation = 'not_estimable_or_low_valid_share';
  elseif ci_low > 0
    interpretation = [y_name, '_faster_than_', x_name];
  elseif ci_high < 0
    interpretation = [x_name, '_faster_than_', y_name];
  else
    interpretation = 'interval_overlaps_zero';
  end
end


function write_condition_csv(filename, rows_in)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['condition_id,architecture,pi_out,pi_BS,b,k,theta,q,T_max,n,n_events,n_censored,', ...
    'readiness_probability,censoring_probability,RMST,T50,T50_estimable,T90,T90_estimable,T95,T95_estimable\n']);

  for i = 1:length(rows_in)
    R = rows_in(i);
    fprintf(fid, '%s,%s,', R.condition_id, R.architecture);
    fprintf_number(fid, R.pi_out); fprintf(fid, ',');
    fprintf_number(fid, R.pi_BS); fprintf(fid, ',');
    fprintf_number(fid, R.b); fprintf(fid, ',');
    fprintf_number(fid, R.k); fprintf(fid, ',');
    fprintf_number(fid, R.theta); fprintf(fid, ',');
    fprintf_number(fid, R.q); fprintf(fid, ',');
    fprintf_number(fid, R.T_max); fprintf(fid, ',');
    fprintf_number(fid, R.n); fprintf(fid, ',');
    fprintf_number(fid, R.n_events); fprintf(fid, ',');
    fprintf_number(fid, R.n_censored); fprintf(fid, ',');
    fprintf_number(fid, R.readiness_probability); fprintf(fid, ',');
    fprintf_number(fid, R.censoring_probability); fprintf(fid, ',');
    fprintf_number(fid, R.RMST); fprintf(fid, ',');
    fprintf_number(fid, R.T50); fprintf(fid, ',');
    fprintf_number(fid, R.T50_estimable); fprintf(fid, ',');
    fprintf_number(fid, R.T90); fprintf(fid, ',');
    fprintf_number(fid, R.T90_estimable); fprintf(fid, ',');
    fprintf_number(fid, R.T95); fprintf(fid, ',');
    fprintf_number(fid, R.T95_estimable); fprintf(fid, '\n');
  end

  fclose(fid);
end


function write_contrast_csv(filename, rows_in)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['contrast_id,x_condition,y_condition,n_boot,n_graphs,n_matched_trajectories,', ...
    'rmst_difference,rmst_ci_low,rmst_ci_high,readiness_probability_difference,', ...
    'readiness_probability_ci_low,readiness_probability_ci_high,', ...
    'T50_difference,T50_ci_low,T50_ci_high,T50_valid_share,', ...
    'T90_difference,T90_ci_low,T90_ci_high,T90_valid_share,', ...
    'T95_difference,T95_ci_low,T95_ci_high,T95_valid_share,', ...
    'rmst_interpretation,T95_interpretation\n']);

  for i = 1:length(rows_in)
    C = rows_in(i);
    fprintf(fid, '%s,%s,%s,', C.contrast_id, C.x_condition, C.y_condition);
    fprintf_number(fid, C.n_boot); fprintf(fid, ',');
    fprintf_number(fid, C.n_graphs); fprintf(fid, ',');
    fprintf_number(fid, C.n_matched_trajectories); fprintf(fid, ',');
    fprintf_number(fid, C.rmst_difference); fprintf(fid, ',');
    fprintf_number(fid, C.rmst_ci_low); fprintf(fid, ',');
    fprintf_number(fid, C.rmst_ci_high); fprintf(fid, ',');
    fprintf_number(fid, C.readiness_probability_difference); fprintf(fid, ',');
    fprintf_number(fid, C.readiness_probability_ci_low); fprintf(fid, ',');
    fprintf_number(fid, C.readiness_probability_ci_high); fprintf(fid, ',');
    fprintf_number(fid, C.T50_difference); fprintf(fid, ',');
    fprintf_number(fid, C.T50_ci_low); fprintf(fid, ',');
    fprintf_number(fid, C.T50_ci_high); fprintf(fid, ',');
    fprintf_number(fid, C.T50_valid_share); fprintf(fid, ',');
    fprintf_number(fid, C.T90_difference); fprintf(fid, ',');
    fprintf_number(fid, C.T90_ci_low); fprintf(fid, ',');
    fprintf_number(fid, C.T90_ci_high); fprintf(fid, ',');
    fprintf_number(fid, C.T90_valid_share); fprintf(fid, ',');
    fprintf_number(fid, C.T95_difference); fprintf(fid, ',');
    fprintf_number(fid, C.T95_ci_low); fprintf(fid, ',');
    fprintf_number(fid, C.T95_ci_high); fprintf(fid, ',');
    fprintf_number(fid, C.T95_valid_share); fprintf(fid, ',');
    fprintf(fid, '%s,%s\n', C.rmst_interpretation, C.T95_interpretation);
  end

  fclose(fid);
end


function fprintf_number(fid, value)
  if isnan(value)
    fprintf(fid, 'NaN');
  else
    fprintf(fid, '%.10g', value);
  end
end


function write_manuscript_handover(filename, final_core, processed_file, condition_rows, contrast_rows, ...
    condition_csv_processed, contrast_csv_processed, condition_csv_figure, contrast_csv_figure)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Manuscript results handover — rerun_v2 final core\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_final_core_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', final_core.run_type);
  fprintf(fid, '- Output tag: `%s`\n', final_core.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', final_core.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', final_core.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', final_core.NT);
  fprintf(fid, '- T_max: %d\n', final_core.T_max);
  fprintf(fid, '- Bootstrap replications: %d\n', final_core.n_boot);
  fprintf(fid, '- Seed base: %d\n', final_core.seed_base);
  fprintf(fid, '- Bootstrap seed: %d\n', final_core.bootstrap_seed);
  fprintf(fid, '- Theta: %.2f\n', final_core.theta);
  fprintf(fid, '- q: %.2f\n', final_core.q);
  fprintf(fid, '- Diagnostic alerts: %d\n\n', final_core.n_alerts);

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimands CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- Contrast CSV: `%s`\n', contrast_csv_processed);
  fprintf(fid, '- Figure-data condition CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data contrast CSV: `%s`\n\n', contrast_csv_figure);

  fprintf(fid, '## Condition-level estimands\n\n');
  fprintf(fid, '| Condition | Architecture | pi_out | pi_BS | Readiness probability | Censoring probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

  for i = 1:length(condition_rows)
    R = condition_rows(i);
    fprintf(fid, '| `%s` | `%s` | %.2f | %.2f | %.3f | %.3f | %.2f | %s | %s | %s |\n', ...
      R.condition_id, R.architecture, R.pi_out, R.pi_BS, ...
      R.readiness_probability, R.censoring_probability, R.RMST, ...
      md_estimable(R.T50, R.T50_estimable), ...
      md_estimable(R.T90, R.T90_estimable), ...
      md_estimable(R.T95, R.T95_estimable));
  end

  fprintf(fid, '\n## Contrast-level results\n\n');
  fprintf(fid, 'Differences are computed as condition X minus condition Y. For time metrics, positive values mean that condition Y is faster/lower.\n\n');
  fprintf(fid, '| Contrast | RMST difference | RMST 95%% CI | Readiness probability difference | T95 difference | T95 95%% CI | T95 valid share | RMST interpretation |\n');
  fprintf(fid, '|---|---:|---:|---:|---:|---:|---:|---|\n');

  for i = 1:length(contrast_rows)
    C = contrast_rows(i);
    fprintf(fid, '| `%s` | %.2f | [%s, %s] | %.3f | %s | [%s, %s] | %.3f | `%s` |\n', ...
      C.contrast_id, C.rmst_difference, fmt_md_number(C.rmst_ci_low), fmt_md_number(C.rmst_ci_high), ...
      C.readiness_probability_difference, fmt_md_number(C.T95_difference), ...
      fmt_md_number(C.T95_ci_low), fmt_md_number(C.T95_ci_high), ...
      C.T95_valid_share, C.rmst_interpretation);
  end

  fprintf(fid, '\n## Claims supported by the final core run\n\n');
  write_claim_assessment(fid, contrast_rows);

  fprintf(fid, '\n## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`, while event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.\n');
  fprintf(fid, '- This handover covers only the final core comparison: `RB_low`, `BS_low`, and `BS_high`. Translation-grid, workload-grid, and robustness outputs must be added in later steps.\n');

  fclose(fid);
end


function write_claim_assessment(fid, contrast_rows)
  rb_bs = find_contrast(contrast_rows, 'RB_low_minus_BS_low');
  bs_trans = find_contrast(contrast_rows, 'BS_low_minus_BS_high');
  rb_high = find_contrast(contrast_rows, 'RB_low_minus_BS_high');

  fprintf(fid, '### Concentration without translation: `RB_low_minus_BS_low`\n\n');
  if isempty(rb_bs)
    fprintf(fid, '- Not assessed: contrast not found.\n\n');
  else
    fprintf(fid, '- RMST difference: %.2f, 95%% CI [%s, %s].\n', ...
      rb_bs.rmst_difference, fmt_md_number(rb_bs.rmst_ci_low), fmt_md_number(rb_bs.rmst_ci_high));
    fprintf(fid, '- Interpretation: `%s`.\n', rb_bs.rmst_interpretation);
    if rb_bs.rmst_ci_high < 0
      fprintf(fid, '- Claim status: supported for a bottleneck penalty; `BS_low` is slower/larger than `RB_low` on RMST.\n\n');
    elseif rb_bs.rmst_ci_low > 0
      fprintf(fid, '- Claim status: not supported as a bottleneck penalty; `BS_low` is faster/lower than `RB_low` on RMST.\n\n');
    else
      fprintf(fid, '- Claim status: inconclusive on RMST because the interval overlaps zero.\n\n');
    end
  end

  fprintf(fid, '### Translation capability switching effect: `BS_low_minus_BS_high`\n\n');
  if isempty(bs_trans)
    fprintf(fid, '- Not assessed: contrast not found.\n\n');
  else
    fprintf(fid, '- RMST difference: %.2f, 95%% CI [%s, %s].\n', ...
      bs_trans.rmst_difference, fmt_md_number(bs_trans.rmst_ci_low), fmt_md_number(bs_trans.rmst_ci_high));
    fprintf(fid, '- Interpretation: `%s`.\n', bs_trans.rmst_interpretation);
    if bs_trans.rmst_ci_low > 0
      fprintf(fid, '- Claim status: supported; `BS_high` is faster/lower than `BS_low` on RMST.\n\n');
    else
      fprintf(fid, '- Claim status: not confirmed on RMST.\n\n');
    end
  end

  fprintf(fid, '### Total boundary-spanning effect: `RB_low_minus_BS_high`\n\n');
  if isempty(rb_high)
    fprintf(fid, '- Not assessed: contrast not found.\n\n');
  else
    fprintf(fid, '- RMST difference: %.2f, 95%% CI [%s, %s].\n', ...
      rb_high.rmst_difference, fmt_md_number(rb_high.rmst_ci_low), fmt_md_number(rb_high.rmst_ci_high));
    fprintf(fid, '- Interpretation: `%s`.\n', rb_high.rmst_interpretation);
    if rb_high.rmst_ci_low > 0
      fprintf(fid, '- Claim status: supported; `BS_high` is faster/lower than `RB_low` on RMST.\n\n');
    else
      fprintf(fid, '- Claim status: not confirmed on RMST.\n\n');
    end
  end
end


function C = find_contrast(rows_in, contrast_id)
  C = [];
  for i = 1:length(rows_in)
    if strcmp(rows_in(i).contrast_id, contrast_id)
      C = rows_in(i);
      return;
    end
  end
end


function s = md_estimable(value, flag)
  if flag == 1
    s = sprintf('%.2f', value);
  else
    s = 'not estimable';
  end
end


function s = fmt_md_number(value)
  if isnan(value)
    s = 'NaN';
  else
    s = sprintf('%.2f', value);
  end
end


function print_estimable(value, flag)
  if flag == 1
    fprintf('%.2f', value);
  else
    fprintf('not estimable');
  end
end


function print_numeric_or_nan(value)
  if isnan(value)
    fprintf('NaN');
  else
    fprintf('%.2f', value);
  end
end
