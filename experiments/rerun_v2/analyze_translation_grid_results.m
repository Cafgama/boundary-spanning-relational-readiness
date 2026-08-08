function translation_export = analyze_translation_grid_results(processed_file)
  % ANALYZE_TRANSLATION_GRID_RESULTS
  % Reads the final rerun_v2 translation-grid processed file and exports
  % manuscript-facing CSVs plus a Markdown handover.
  %
  % Usage:
  %   translation_export = analyze_translation_grid_results()
  %   translation_export = analyze_translation_grid_results(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/translation_grid/translation_grid_processed_*.mat
  % file is used.
  %
  % This script does not run simulations. It only reads a processed production
  % file and writes derived text/CSV outputs.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'translation_grid');
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', 'translation_grid');
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  if nargin < 1 || isempty(processed_file)
    processed_file = latest_translation_grid_processed_file(processed_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Translation-grid processed file not found: ', processed_file]);

  loaded = load(processed_file);

  assert(isfield(loaded, 'translation_grid'), ...
    'Processed file must contain a translation_grid structure.');

  translation_grid = loaded.translation_grid;
  validate_translation_grid_structure(translation_grid);

  condition_rows = build_condition_rows(translation_grid);
  contrast_rows = build_contrast_rows(translation_grid);
  monotonic = evaluate_translation_monotonicity(condition_rows);

  condition_csv_processed = fullfile(processed_dir, 'translation_grid_condition_estimands.csv');
  contrast_csv_processed = fullfile(processed_dir, 'translation_grid_contrasts.csv');

  condition_csv_figure = fullfile(figure_data_dir, 'translation_grid_condition_estimands.csv');
  contrast_csv_figure = fullfile(figure_data_dir, 'translation_grid_contrasts.csv');

  handover_file = fullfile(docs_dir, 'translation_grid_results_handover.md');

  write_condition_csv(condition_csv_processed, condition_rows);
  write_condition_csv(condition_csv_figure, condition_rows);
  write_contrast_csv(contrast_csv_processed, contrast_rows);
  write_contrast_csv(contrast_csv_figure, contrast_rows);
  write_translation_handover(handover_file, translation_grid, processed_file, ...
    condition_rows, contrast_rows, monotonic, condition_csv_processed, ...
    contrast_csv_processed, condition_csv_figure, contrast_csv_figure);

  translation_export = struct();
  translation_export.processed_file = processed_file;
  translation_export.condition_csv_processed = condition_csv_processed;
  translation_export.contrast_csv_processed = contrast_csv_processed;
  translation_export.condition_csv_figure = condition_csv_figure;
  translation_export.contrast_csv_figure = contrast_csv_figure;
  translation_export.handover_file = handover_file;
  translation_export.condition_rows = condition_rows;
  translation_export.contrast_rows = contrast_rows;
  translation_export.monotonic = monotonic;
  translation_export.n_alerts = translation_grid.n_alerts;

  fprintf('\n============================================\n');
  fprintf('RERUN V2 TRANSLATION-GRID EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('conditions exported: %d\n', length(condition_rows));
  fprintf('contrasts exported: %d\n', length(contrast_rows));
  fprintf('diagnostic alerts: %d\n', translation_grid.n_alerts);
  fprintf('RMST monotonic decreasing: %d\n', monotonic.RMST_monotonic_decreasing);
  fprintf('T95 monotonic decreasing: %d\n', monotonic.T95_monotonic_decreasing);

  fprintf('\nCondition CSV:\n%s\n', condition_csv_processed);
  fprintf('\nContrast CSV:\n%s\n', contrast_csv_processed);
  fprintf('\nFigure-data condition CSV:\n%s\n', condition_csv_figure);
  fprintf('\nFigure-data contrast CSV:\n%s\n', contrast_csv_figure);
  fprintf('\nTranslation-grid handover:\n%s\n', handover_file);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 TRANSLATION-GRID EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_translation_grid_processed_file(processed_dir)
  files = dir(fullfile(processed_dir, 'translation_grid_processed_*.mat'));

  assert(~isempty(files), ...
    ['No translation-grid processed file found in ', processed_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(processed_dir, files(idx).name);
end


function validate_translation_grid_structure(TG)
  required_fields = {
    'run_type', 'output_tag', 'timestamp', 'NG', 'NT', 'T_max', ...
    'n_boot', 'seed_base', 'bootstrap_seed', 'theta', 'q', 'pi_out', ...
    'pi_BS_grid', 'conditions', 'estimands', 'bootstraps', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(TG, fname), ['translation_grid missing field: ', fname]);
  end

  assert(length(TG.conditions) == length(TG.pi_BS_grid), ...
    'Number of conditions must match pi_BS_grid length.');

  assert(length(TG.conditions) >= 2, ...
    'Translation grid must contain at least two conditions.');
end


function rows = build_condition_rows(TG)
  rows = [];

  for i = 1:length(TG.conditions)
    C = TG.conditions(i);
    cname = C.condition_id;

    assert(isfield(TG.estimands, cname), ['Missing estimands for ', cname]);
    S = TG.estimands.(cname);

    row = struct();
    row.condition_id = cname;
    row.architecture = C.architecture;
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

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function rows = build_contrast_rows(TG)
  rows = [];
  bnames = fieldnames(TG.bootstraps);

  for i = 1:length(bnames)
    contrast_id = bnames{i};
    B = TG.bootstraps.(contrast_id);

    [x_condition, y_condition] = parse_contrast_id(contrast_id);

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

    row.readiness_probability_difference = ...
      B.observed_difference.readiness_probability;
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

    row.rmst_interpretation = time_difference_interpretation(
      row.rmst_difference, x_condition, y_condition);
    row.T95_interpretation = time_difference_interpretation(
      row.T95_difference, x_condition, y_condition);

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function [x_condition, y_condition] = parse_contrast_id(contrast_id)
  token = '_minus_';
  idx = strfind(contrast_id, token);
  assert(~isempty(idx), ['Could not parse contrast id: ', contrast_id]);
  idx = idx(1);

  x_condition = contrast_id(1:(idx - 1));
  y_condition = contrast_id((idx + length(token)):end);
end


function interp = time_difference_interpretation(diff_value, x_condition, y_condition)
  if isnan(diff_value)
    interp = 'not_estimable';
  elseif diff_value > 0
    interp = [y_condition, '_faster_than_', x_condition];
  elseif diff_value < 0
    interp = [x_condition, '_faster_than_', y_condition];
  else
    interp = 'no_difference';
  end
end


function monotonic = evaluate_translation_monotonicity(rows)
  n = length(rows);
  pi_values = zeros(n, 1);
  rmst_values = zeros(n, 1);
  t95_values = zeros(n, 1);

  for i = 1:n
    pi_values(i) = rows(i).pi_BS;
    rmst_values(i) = rows(i).RMST;
    t95_values(i) = rows(i).T95;
  end

  monotonic = struct();
  monotonic.pi_BS = pi_values;
  monotonic.RMST_values = rmst_values;
  monotonic.T95_values = t95_values;
  monotonic.RMST_changes = diff(rmst_values);
  monotonic.T95_changes = diff(t95_values);
  monotonic.RMST_monotonic_decreasing = all(diff(rmst_values) <= 0);
  monotonic.T95_monotonic_decreasing = all(diff(t95_values) <= 0);
end


function write_condition_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open CSV for writing: ', filename]);

  headers = {
    'condition_id', 'architecture', 'pi_out', 'pi_BS', ...
    'readiness_probability', 'censoring_probability', 'RMST', ...
    'T50', 'T50_estimable', 'T90', 'T90_estimable', 'T95', 'T95_estimable'
  };

  write_csv_line(fid, headers);

  for i = 1:length(rows)
    r = rows(i);
    values = {
      r.condition_id, r.architecture, r.pi_out, r.pi_BS, ...
      r.readiness_probability, r.censoring_probability, r.RMST, ...
      r.T50, r.T50_estimable, r.T90, r.T90_estimable, ...
      r.T95, r.T95_estimable
    };
    write_csv_line(fid, values);
  end

  fclose(fid);
end


function write_contrast_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open CSV for writing: ', filename]);

  headers = {
    'contrast_id', 'x_condition', 'y_condition', 'n_boot', 'n_graphs', ...
    'n_matched_trajectories', 'rmst_difference', 'rmst_ci_low', ...
    'rmst_ci_high', 'readiness_probability_difference', ...
    'readiness_probability_ci_low', 'readiness_probability_ci_high', ...
    'T50_difference', 'T50_ci_low', 'T50_ci_high', 'T50_valid_share', ...
    'T90_difference', 'T90_ci_low', 'T90_ci_high', 'T90_valid_share', ...
    'T95_difference', 'T95_ci_low', 'T95_ci_high', 'T95_valid_share', ...
    'rmst_interpretation', 'T95_interpretation'
  };

  write_csv_line(fid, headers);

  for i = 1:length(rows)
    r = rows(i);
    values = {
      r.contrast_id, r.x_condition, r.y_condition, r.n_boot, ...
      r.n_graphs, r.n_matched_trajectories, r.rmst_difference, ...
      r.rmst_ci_low, r.rmst_ci_high, ...
      r.readiness_probability_difference, ...
      r.readiness_probability_ci_low, r.readiness_probability_ci_high, ...
      r.T50_difference, r.T50_ci_low, r.T50_ci_high, r.T50_valid_share, ...
      r.T90_difference, r.T90_ci_low, r.T90_ci_high, r.T90_valid_share, ...
      r.T95_difference, r.T95_ci_low, r.T95_ci_high, r.T95_valid_share, ...
      r.rmst_interpretation, r.T95_interpretation
    };
    write_csv_line(fid, values);
  end

  fclose(fid);
end


function write_csv_line(fid, values)
  for j = 1:length(values)
    if j > 1
      fprintf(fid, ',');
    end
    fprintf(fid, '%s', csv_value(values{j}));
  end
  fprintf(fid, '\n');
end


function out = csv_value(value)
  if isnumeric(value)
    if isempty(value)
      out = '';
    elseif isnan(value)
      out = 'NaN';
    else
      out = sprintf('%.10g', value);
    end
  elseif islogical(value)
    out = sprintf('%d', value);
  else
    s = value;
    if ~ischar(s)
      s = char(s);
    end
    s = strrep(s, '"', '""');
    if any(s == ',') || any(s == '"') || any(s == sprintf('\n')) || any(s == sprintf('\r'))
      out = ['"', s, '"'];
    else
      out = s;
    end
  end
end


function write_translation_handover(filename, TG, processed_file, condition_rows, ...
    contrast_rows, monotonic, condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Translation-grid results handover — rerun_v2\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_translation_grid_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', TG.run_type);
  fprintf(fid, '- Output tag: `%s`\n', TG.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', TG.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', TG.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', TG.NT);
  fprintf(fid, '- T_max: %d\n', TG.T_max);
  fprintf(fid, '- Bootstrap replications: %d\n', TG.n_boot);
  fprintf(fid, '- Seed base: %d\n', TG.seed_base);
  fprintf(fid, '- Bootstrap seed: %d\n', TG.bootstrap_seed);
  fprintf(fid, '- Theta: %.2f\n', TG.theta);
  fprintf(fid, '- q: %.2f\n', TG.q);
  fprintf(fid, '- pi_out: %.2f\n', TG.pi_out);
  fprintf(fid, '- Diagnostic alerts: %d\n\n', TG.n_alerts);

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimands CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- Contrast CSV: `%s`\n', contrast_csv_processed);
  fprintf(fid, '- Figure-data condition CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data contrast CSV: `%s`\n\n', contrast_csv_figure);

  fprintf(fid, '## Condition-level estimands\n\n');
  fprintf(fid, '| Condition | Architecture | pi_out | pi_BS | Readiness probability | Censoring probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf(fid, '| `%s` | `%s` | %.2f | %.2f | %.3f | %.3f | %.2f | %.2f | %.2f | %.2f |\n', ...
      r.condition_id, r.architecture, r.pi_out, r.pi_BS, ...
      r.readiness_probability, r.censoring_probability, r.RMST, ...
      r.T50, r.T90, r.T95);
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

  fprintf(fid, '\n## Monotonicity diagnostics\n\n');
  fprintf(fid, '- RMST monotonic decreasing in pi_BS: `%d`\n', monotonic.RMST_monotonic_decreasing);
  fprintf(fid, '- T95 monotonic decreasing in pi_BS: `%d`\n\n', monotonic.T95_monotonic_decreasing);

  fprintf(fid, '| pi_BS | RMST | T95 |\n');
  fprintf(fid, '|---:|---:|---:|\n');
  for i = 1:length(condition_rows)
    fprintf(fid, '| %.2f | %.2f | %.2f |\n', ...
      condition_rows(i).pi_BS, condition_rows(i).RMST, condition_rows(i).T95);
  end

  fprintf(fid, '\n## Claims supported by the translation-grid run\n\n');

  if monotonic.RMST_monotonic_decreasing && monotonic.T95_monotonic_decreasing
    fprintf(fid, '- Claim status: supported. Increasing `pi_BS` monotonically reduces both RMST and T95 in the translation grid.\n');
  elseif monotonic.RMST_monotonic_decreasing
    fprintf(fid, '- Claim status: partially supported. Increasing `pi_BS` monotonically reduces RMST, but T95 is not monotonic.\n');
  else
    fprintf(fid, '- Claim status: not fully supported. RMST is not monotonic in the translation grid.\n');
  end

  fprintf(fid, '- This result supports interpreting translation capability as a continuous switching mechanism, not only as a binary comparison between `BS_low` and `BS_high`.\n\n');

  fprintf(fid, '## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`, while event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.\n');
  fprintf(fid, '- This handover covers only the translation-capability grid. Workload-grid and robustness outputs must be added in later steps.\n');

  fclose(fid);
end
