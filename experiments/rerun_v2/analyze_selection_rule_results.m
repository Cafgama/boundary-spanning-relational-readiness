function exports = analyze_selection_rule_results(processed_file)
  % ANALYZE_SELECTION_RULE_RESULTS
  % Reads a rerun_v2 selection-rule robustness processed file and exports
  % clean CSVs plus a manuscript handover document.
  %
  % Usage:
  %   exports = analyze_selection_rule_results()
  %   exports = analyze_selection_rule_results(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/selection_rule_robustness/selection_rule_processed_*.mat
  % file is used. This script does not run simulations.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'selection_rule_robustness');
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', 'selection_rule_robustness');
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  if nargin < 1 || isempty(processed_file)
    processed_file = latest_selection_rule_processed_file(processed_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Processed selection-rule file not found: ', processed_file]);

  loaded = load(processed_file);
  assert(isfield(loaded, 'selection_rule'), ...
    'Processed file must contain a selection_rule structure.');

  selection_rule = loaded.selection_rule;
  validate_selection_rule_structure(selection_rule);

  condition_rows = build_condition_rows(selection_rule);
  contrast_rows = build_contrast_rows(selection_rule);
  comparison_summary = compute_comparison_summary(condition_rows, contrast_rows);

  alerts = {};
  if selection_rule.n_alerts > 0
    for i = 1:length(selection_rule.alerts)
      alerts{end + 1} = selection_rule.alerts{i};
    end
  end

  condition_csv_processed = fullfile(processed_dir, 'selection_rule_condition_estimands.csv');
  contrast_csv_processed = fullfile(processed_dir, 'selection_rule_contrasts.csv');
  condition_csv_figure = fullfile(figure_data_dir, 'selection_rule_condition_estimands.csv');
  contrast_csv_figure = fullfile(figure_data_dir, 'selection_rule_contrasts.csv');
  handover_file = fullfile(docs_dir, 'selection_rule_results_handover.md');

  write_condition_csv(condition_csv_processed, condition_rows);
  write_contrast_csv(contrast_csv_processed, contrast_rows);

  copyfile(condition_csv_processed, condition_csv_figure);
  copyfile(contrast_csv_processed, contrast_csv_figure);

  write_selection_rule_handover(handover_file, selection_rule, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, comparison_summary, alerts);

  exports = struct();
  exports.processed_file = processed_file;
  exports.condition_csv_processed = condition_csv_processed;
  exports.contrast_csv_processed = contrast_csv_processed;
  exports.condition_csv_figure = condition_csv_figure;
  exports.contrast_csv_figure = contrast_csv_figure;
  exports.handover_file = handover_file;
  exports.condition_rows = condition_rows;
  exports.contrast_rows = contrast_rows;
  exports.comparison_summary = comparison_summary;
  exports.alerts = alerts(:);
  exports.n_alerts = length(alerts);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SELECTION-RULE EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('condition CSV: %s\n', condition_csv_processed);
  fprintf('contrast CSV: %s\n', contrast_csv_processed);
  fprintf('handover: %s\n', handover_file);

  fprintf('\nCondition-level RMST/T95 by selection rule\n');
  fprintf('--------------------------------------------\n');
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf('%s | %s | RMST %.2f | T95 %.2f\n', ...
      r.condition_id, r.selection_rule, r.RMST, r.T95);
  end

  fprintf('\nKey selection-rule contrasts\n');
  fprintf('--------------------------------------------\n');
  names = fieldnames(comparison_summary);
  for i = 1:length(names)
    s = comparison_summary.(names{i});
    fprintf('%s | RMST diff %.2f | T95 diff %.2f\n', ...
      names{i}, s.rmst_difference, s.T95_difference);
  end

  fprintf('\nExport diagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No selection-rule export alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  fprintf('\n============================================\n');
  fprintf('RERUN V2 SELECTION-RULE EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_selection_rule_processed_file(processed_dir)
  files = dir(fullfile(processed_dir, 'selection_rule_processed_*.mat'));
  assert(~isempty(files), ...
    ['No selection-rule processed file found in ', processed_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(processed_dir, files(idx).name);
end


function validate_selection_rule_structure(selection_rule)
  required_fields = {
    'run_type', 'timestamp', 'NG', 'NT', 'T_max', 'n_boot', ...
    'seed_base', 'bootstrap_seed', 'theta', 'q', 'pi_out', ...
    'pi_BS_low', 'pi_BS_high', 'conditions', 'estimands', ...
    'bootstraps', 'alerts', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(selection_rule, fname), ...
      ['selection_rule missing field: ', fname]);
  end

  assert(length(selection_rule.conditions) >= 6, ...
    'selection_rule.conditions should contain the six robustness conditions.');
end


function rows = build_condition_rows(selection_rule)
  conditions = selection_rule.conditions;
  rows = [];

  for i = 1:length(conditions)
    C = conditions(i);
    cname = C.condition_id;
    S = selection_rule.estimands.(cname);

    row = struct();
    row.condition_id = cname;
    row.mechanism_condition = mechanism_from_condition(cname);
    row.architecture = C.architecture;
    row.selection_rule = C.selection_rule;
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


function mechanism = mechanism_from_condition(condition_id)
  if ~isempty(strfind(condition_id, 'RB_low'))
    mechanism = 'RB_low';
  elseif ~isempty(strfind(condition_id, 'BS_low'))
    mechanism = 'BS_low';
  elseif ~isempty(strfind(condition_id, 'BS_high'))
    mechanism = 'BS_high';
  else
    mechanism = 'unknown';
  end
end


function rows = build_contrast_rows(selection_rule)
  names = fieldnames(selection_rule.bootstraps);
  rows = [];

  for i = 1:length(names)
    contrast_id = names{i};
    B = selection_rule.bootstraps.(contrast_id);
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


function summary = compute_comparison_summary(condition_rows, contrast_rows)
  summary = struct();
  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    key = r.contrast_id;
    summary.(key).rmst_difference = r.rmst_difference;
    summary.(key).rmst_ci_low = r.rmst_ci_low;
    summary.(key).rmst_ci_high = r.rmst_ci_high;
    summary.(key).T95_difference = r.T95_difference;
    summary.(key).T95_ci_low = r.T95_ci_low;
    summary.(key).T95_ci_high = r.T95_ci_high;
    summary.(key).T95_valid_share = r.T95_valid_share;
  end

  % Include compact condition values for convenience.
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    key = ['condition_', r.condition_id];
    summary.(key).RMST = r.RMST;
    summary.(key).T95 = r.T95;
    summary.(key).readiness_probability = r.readiness_probability;
  end
end


function write_condition_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['condition_id,mechanism_condition,architecture,selection_rule,pi_out,pi_BS,', ...
    'readiness_probability,censoring_probability,RMST,T50,T50_estimable,', ...
    'T90,T90_estimable,T95,T95_estimable\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%.6f,%d,%.6f,%d\n', ...
      r.condition_id, r.mechanism_condition, r.architecture, r.selection_rule, ...
      r.pi_out, r.pi_BS, r.readiness_probability, r.censoring_probability, ...
      r.RMST, r.T50, r.T50_estimable, r.T90, r.T90_estimable, ...
      r.T95, r.T95_estimable);
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


function write_selection_rule_handover(filename, selection_rule, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, comparison_summary, alerts)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Selection-rule robustness handover — rerun_v2\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_selection_rule_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', selection_rule.run_type);
  fprintf(fid, '- Output tag: `%s`\n', selection_rule.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', selection_rule.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', selection_rule.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', selection_rule.NT);
  fprintf(fid, '- T_max: %d\n', selection_rule.T_max);
  fprintf(fid, '- Bootstrap replications: %d\n', selection_rule.n_boot);
  fprintf(fid, '- Seed base: %d\n', selection_rule.seed_base);
  fprintf(fid, '- Bootstrap seed: %d\n', selection_rule.bootstrap_seed);
  fprintf(fid, '- Theta: %.2f\n', selection_rule.theta);
  fprintf(fid, '- q: %.2f\n', selection_rule.q);
  fprintf(fid, '- pi_out: %.2f\n', selection_rule.pi_out);
  fprintf(fid, '- pi_BS_low: %.2f\n', selection_rule.pi_BS_low);
  fprintf(fid, '- pi_BS_high: %.2f\n', selection_rule.pi_BS_high);
  fprintf(fid, '- Diagnostic alerts: %d\n\n', length(alerts));

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimands CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- Contrast CSV: `%s`\n', contrast_csv_processed);
  fprintf(fid, '- Figure-data condition CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data contrast CSV: `%s`\n\n', contrast_csv_figure);

  fprintf(fid, '## Condition-level estimands\n\n');
  fprintf(fid, '| Condition | Mechanism | Architecture | Selection rule | Readiness probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---|---|---|---:|---:|---:|---:|---:|\n');
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf(fid, '| `%s` | `%s` | `%s` | `%s` | %.3f | %.2f | %.2f | %.2f | %.2f |\n', ...
      r.condition_id, r.mechanism_condition, r.architecture, r.selection_rule, ...
      r.readiness_probability, r.RMST, r.T50, r.T90, r.T95);
  end

  fprintf(fid, '\n## Contrast-level results\n\n');
  fprintf(fid, 'Differences are computed as condition X minus condition Y. For time metrics, positive values mean that condition Y is faster/lower.\n\n');
  fprintf(fid, '| Contrast | RMST difference | RMST 95%% CI | T95 difference | T95 95%% CI | T95 valid share |\n');
  fprintf(fid, '|---|---:|---:|---:|---:|---:|\n');
  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    fprintf(fid, '| `%s` | %.2f | [%.2f, %.2f] | %.2f | [%.2f, %.2f] | %.3f |\n', ...
      r.contrast_id, r.rmst_difference, r.rmst_ci_low, r.rmst_ci_high, ...
      r.T95_difference, r.T95_ci_low, r.T95_ci_high, r.T95_valid_share);
  end

  fprintf(fid, '\n## Claims supported or bounded by the selection-rule run\n\n');
  fprintf(fid, '### Actor-capacity interpretation\n\n');
  fprintf(fid, '- This run compares the baseline `agent_first` rule with the robustness rule `edge_uniform`.\n');
  fprintf(fid, '- If the BS-low bottleneck penalty weakens or disappears under `edge_uniform`, the result supports the interpretation that the bottleneck mechanism depends on actor-level interaction-capacity scarcity.\n');
  fprintf(fid, '- If translation-capable boundary spanning remains faster than low-translation boundary spanning under `edge_uniform`, the translation mechanism is robust to the alternative selection rule.\n\n');

  fprintf(fid, '## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- `agent_first` is the baseline because it represents scarce actor attention and interaction capacity.\n');
  fprintf(fid, '- `edge_uniform` is a robustness rule; it should not replace the baseline unless explicitly justified.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`, while event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.\n');
  fprintf(fid, '- This handover covers only selection-rule robustness and should be combined later with final core, translation-grid, and workload-grid handovers.\n\n');

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
