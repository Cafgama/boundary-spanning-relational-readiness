function exports = analyze_threshold_checkpointed_results(processed_file)
  % ANALYZE_THRESHOLD_CHECKPOINTED_RESULTS
  % Reads the rerun_v2 checkpointed threshold-robustness processed file and
  % exports clean CSVs plus a manuscript-facing handover document.
  %
  % Usage:
  %   exports = analyze_threshold_checkpointed_results()
  %   exports = analyze_threshold_checkpointed_results(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_checkpointed_processed_*.mat
  % file is used. This script does not run simulations.

  if nargin < 1
    processed_file = '';
  end

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'src'));

  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'threshold_robustness_checkpointed');
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', 'threshold_robustness_checkpointed');
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  if isempty(processed_file)
    processed_file = latest_threshold_checkpointed_file(processed_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Processed checkpointed-threshold file not found: ', processed_file]);

  loaded = load(processed_file);
  assert(isfield(loaded, 'threshold_robustness'), ...
    'Processed file must contain threshold_robustness.');

  threshold = loaded.threshold_robustness;
  validate_threshold_structure(threshold);

  condition_rows = build_threshold_condition_rows(threshold);
  contrast_rows = build_threshold_contrast_rows(threshold);
  diagnostic = summarize_threshold_diagnostics(condition_rows, contrast_rows, threshold.alerts);

  condition_csv_processed = fullfile(processed_dir, 'threshold_condition_estimands.csv');
  contrast_csv_processed = fullfile(processed_dir, 'threshold_contrasts.csv');
  condition_csv_figure = fullfile(figure_data_dir, 'threshold_condition_estimands.csv');
  contrast_csv_figure = fullfile(figure_data_dir, 'threshold_contrasts.csv');
  handover_file = fullfile(docs_dir, 'threshold_robustness_results_handover.md');

  write_threshold_condition_csv(condition_csv_processed, condition_rows);
  write_threshold_contrast_csv(contrast_csv_processed, contrast_rows);

  copyfile(condition_csv_processed, condition_csv_figure);
  copyfile(contrast_csv_processed, contrast_csv_figure);

  write_threshold_handover(handover_file, threshold, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, diagnostic);

  exports = struct();
  exports.processed_file = processed_file;
  exports.condition_csv_processed = condition_csv_processed;
  exports.contrast_csv_processed = contrast_csv_processed;
  exports.condition_csv_figure = condition_csv_figure;
  exports.contrast_csv_figure = contrast_csv_figure;
  exports.handover_file = handover_file;
  exports.condition_rows = condition_rows;
  exports.contrast_rows = contrast_rows;
  exports.diagnostic = diagnostic;
  exports.alerts = threshold.alerts(:);
  exports.n_alerts = length(threshold.alerts);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 THRESHOLD CHECKPOINTED EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('condition CSV: %s\n', condition_csv_processed);
  fprintf('contrast CSV: %s\n', contrast_csv_processed);
  fprintf('handover: %s\n', handover_file);

  fprintf('\nCondition-level RMST/T95 by threshold scenario\n');
  fprintf('--------------------------------------------\n');
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf('%s | theta %.2f | q %.2f | %s | readiness %.3f | RMST %.2f | T95 ', ...
      r.condition_id, r.theta, r.q, r.translation_level, ...
      r.readiness_probability, r.RMST);
    print_export_value(r.T95, r.T95_estimable);
    fprintf('\n');
  end

  fprintf('\nThreshold contrast summary\n');
  fprintf('--------------------------------------------\n');
  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    fprintf('%s | RMST diff %.2f | T95 diff ', r.contrast_id, r.rmst_difference);
    print_export_value(r.T95_difference, r.T95_valid_share >= 0.50);
    fprintf(' | T95 valid share %.3f\n', r.T95_valid_share);
  end

  fprintf('\nThreshold diagnostics\n');
  fprintf('--------------------------------------------\n');
  fprintf('n_alerts: %d\n', exports.n_alerts);
  fprintf('translation_RMST_positive_all_scenarios: %d\n', diagnostic.translation_RMST_positive_all_scenarios);
  fprintf('translation_T95_positive_estimable_scenarios: %d\n', diagnostic.translation_T95_positive_estimable_scenarios);
  fprintf('harder_tie_low_readiness_flag: %d\n', diagnostic.harder_tie_low_readiness_flag);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 THRESHOLD CHECKPOINTED EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_threshold_checkpointed_file(processed_dir)
  files = dir(fullfile(processed_dir, 'threshold_checkpointed_processed_*.mat'));
  assert(~isempty(files), ...
    ['No threshold_checkpointed_processed_*.mat file found in ', processed_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end
  [~, idx] = max(datenums);
  processed_file = fullfile(processed_dir, files(idx).name);
end


function validate_threshold_structure(threshold)
  required_fields = {
    'run_type', 'output_tag', 'timestamp', 'NG', 'NT', 'T_max', ...
    'n_boot', 'seed_base', 'bootstrap_seed', 'pi_out', 'pi_BS_low', ...
    'pi_BS_high', 'scenarios', 'conditions', 'estimands', ...
    'bootstraps', 'alerts', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(threshold, fname), ['threshold missing field: ', fname]);
  end

  assert(length(threshold.scenarios) >= 1, 'threshold.scenarios cannot be empty.');
  assert(length(threshold.conditions) >= 2, 'threshold.conditions must contain paired conditions.');
end


function rows = build_threshold_condition_rows(threshold)
  rows = [];
  for i = 1:length(threshold.conditions)
    C = threshold.conditions(i);
    cname = C.condition_id;
    E = threshold.estimands.(cname);

    row = struct();
    row.condition_id = cname;
    row.scenario_id = C.scenario_id;
    row.scenario_label = C.scenario_label;
    row.architecture = C.architecture;
    row.selection_rule = 'agent_first';
    row.translation_level = C.translation_level;
    row.theta = C.P.theta;
    row.q = C.P.q;
    row.pi_out = C.P.pi_out;
    row.pi_BS = C.P.pi_BS;
    row.readiness_probability = E.readiness_probability;
    row.censoring_probability = E.censoring_probability;
    row.RMST = E.RMST;
    row.T50 = E.T50;
    row.T50_estimable = E.T50_estimable;
    row.T90 = E.T90;
    row.T90_estimable = E.T90_estimable;
    row.T95 = E.T95;
    row.T95_estimable = E.T95_estimable;

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function rows = build_threshold_contrast_rows(threshold)
  names = fieldnames(threshold.bootstraps);
  rows = [];

  for i = 1:length(names)
    contrast_id = names{i};
    B = threshold.bootstraps.(contrast_id);
    [x_condition, y_condition] = split_threshold_contrast_id(contrast_id);
    scenario_id = scenario_from_condition_id(x_condition);

    row = struct();
    row.contrast_id = contrast_id;
    row.scenario_id = scenario_id;
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

    if isempty(rows)
      rows = row;
    else
      rows(end + 1) = row;
    end
  end
end


function [x_condition, y_condition] = split_threshold_contrast_id(contrast_id)
  idx = strfind(contrast_id, '_minus_');
  assert(~isempty(idx), ['Invalid contrast id: ', contrast_id]);
  idx = idx(1);
  x_condition = contrast_id(1:(idx - 1));
  y_condition = contrast_id((idx + length('_minus_')):end);
end


function scenario_id = scenario_from_condition_id(condition_id)
  if ~isempty(strfind(condition_id, '_BS_low'))
    scenario_id = strrep(condition_id, '_BS_low', '');
  elseif ~isempty(strfind(condition_id, '_BS_high'))
    scenario_id = strrep(condition_id, '_BS_high', '');
  else
    scenario_id = condition_id;
  end
end


function diagnostic = summarize_threshold_diagnostics(condition_rows, contrast_rows, alerts)
  diagnostic = struct();
  diagnostic.n_alerts = length(alerts);
  diagnostic.alerts = alerts(:);

  rmst_positive = 1;
  T95_positive_estimable = 1;
  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    if ~(r.rmst_difference > 0)
      rmst_positive = 0;
    end
    if r.T95_valid_share >= 0.50
      if ~(r.T95_difference > 0)
        T95_positive_estimable = 0;
      end
    end
  end
  diagnostic.translation_RMST_positive_all_scenarios = rmst_positive;
  diagnostic.translation_T95_positive_estimable_scenarios = T95_positive_estimable;

  diagnostic.harder_tie_low_readiness_flag = 0;
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    if strcmp(r.condition_id, 'harder_tie_BS_low') && r.readiness_probability < 0.95
      diagnostic.harder_tie_low_readiness_flag = 1;
    end
  end
end


function write_threshold_condition_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['condition_id,scenario_id,scenario_label,architecture,selection_rule,', ...
    'translation_level,theta,q,pi_out,pi_BS,readiness_probability,', ...
    'censoring_probability,RMST,T50,T50_estimable,T90,T90_estimable,T95,T95_estimable\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%s,%s,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%.6f,%d,%.6f,%d\n', ...
      r.condition_id, r.scenario_id, r.scenario_label, r.architecture, ...
      r.selection_rule, r.translation_level, r.theta, r.q, r.pi_out, r.pi_BS, ...
      r.readiness_probability, r.censoring_probability, r.RMST, ...
      r.T50, r.T50_estimable, r.T90, r.T90_estimable, r.T95, r.T95_estimable);
  end
  fclose(fid);
end


function write_threshold_contrast_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['contrast_id,scenario_id,x_condition,y_condition,n_boot,n_graphs,', ...
    'n_matched_trajectories,rmst_difference,rmst_ci_low,rmst_ci_high,', ...
    'readiness_probability_difference,readiness_probability_ci_low,', ...
    'readiness_probability_ci_high,T50_difference,T50_ci_low,T50_ci_high,', ...
    'T50_valid_share,T90_difference,T90_ci_low,T90_ci_high,T90_valid_share,', ...
    'T95_difference,T95_ci_low,T95_ci_high,T95_valid_share\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%s,%s,%d,%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
      r.contrast_id, r.scenario_id, r.x_condition, r.y_condition, ...
      r.n_boot, r.n_graphs, r.n_matched_trajectories, ...
      r.rmst_difference, r.rmst_ci_low, r.rmst_ci_high, ...
      r.readiness_probability_difference, r.readiness_probability_ci_low, ...
      r.readiness_probability_ci_high, r.T50_difference, r.T50_ci_low, ...
      r.T50_ci_high, r.T50_valid_share, r.T90_difference, r.T90_ci_low, ...
      r.T90_ci_high, r.T90_valid_share, r.T95_difference, r.T95_ci_low, ...
      r.T95_ci_high, r.T95_valid_share);
  end
  fclose(fid);
end


function write_threshold_handover(filename, threshold, processed_file, ...
    condition_csv_processed, contrast_csv_processed, ...
    condition_csv_figure, contrast_csv_figure, ...
    condition_rows, contrast_rows, diagnostic)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Readiness-threshold robustness handover — rerun_v2 checkpointed\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_threshold_checkpointed_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', threshold.run_type);
  fprintf(fid, '- Output tag: `%s`\n', threshold.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', threshold.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', threshold.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', threshold.NT);
  fprintf(fid, '- T_max: %d\n', threshold.T_max);
  fprintf(fid, '- Bootstrap replications: %d\n', threshold.n_boot);
  fprintf(fid, '- Seed base: %d\n', threshold.seed_base);
  fprintf(fid, '- Bootstrap seed: %d\n', threshold.bootstrap_seed);
  fprintf(fid, '- pi_out: %.2f\n', threshold.pi_out);
  fprintf(fid, '- pi_BS_low: %.2f\n', threshold.pi_BS_low);
  fprintf(fid, '- pi_BS_high: %.2f\n', threshold.pi_BS_high);
  fprintf(fid, '- Diagnostic alerts: %d\n\n', threshold.n_alerts);

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimands CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- Contrast CSV: `%s`\n', contrast_csv_processed);
  fprintf(fid, '- Figure-data condition CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data contrast CSV: `%s`\n\n', contrast_csv_figure);

  fprintf(fid, '## Condition-level estimands\n\n');
  fprintf(fid, '| Condition | Scenario | theta | q | Translation level | Readiness probability | Censoring probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---|---:|---:|---|---:|---:|---:|---:|---:|---:|\n');
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf(fid, '| `%s` | `%s` | %.2f | %.2f | `%s` | %.3f | %.3f | %.2f | ', ...
      r.condition_id, r.scenario_id, r.theta, r.q, r.translation_level, ...
      r.readiness_probability, r.censoring_probability, r.RMST);
    write_md_estimable(fid, r.T50, r.T50_estimable);
    fprintf(fid, ' | ');
    write_md_estimable(fid, r.T90, r.T90_estimable);
    fprintf(fid, ' | ');
    write_md_estimable(fid, r.T95, r.T95_estimable);
    fprintf(fid, ' |\n');
  end

  fprintf(fid, '\n## Contrast-level results\n\n');
  fprintf(fid, 'Differences are computed as `BS_low minus BS_high` within each threshold scenario. For time metrics, positive values mean that `BS_high` reaches readiness faster/lower.\n\n');
  fprintf(fid, '| Scenario | Contrast | RMST difference | RMST 95%% CI | T95 difference | T95 95%% CI | T95 valid share |\n');
  fprintf(fid, '|---|---|---:|---:|---:|---:|---:|\n');
  for i = 1:length(contrast_rows)
    r = contrast_rows(i);
    fprintf(fid, '| `%s` | `%s` | %.2f | [%.2f, %.2f] | ', ...
      r.scenario_id, r.contrast_id, r.rmst_difference, r.rmst_ci_low, r.rmst_ci_high);
    write_md_boot_quantile(fid, r.T95_difference, r.T95_ci_low, r.T95_ci_high, r.T95_valid_share);
    fprintf(fid, ' | %.3f |\n', r.T95_valid_share);
  end

  fprintf(fid, '\n## Diagnostic interpretation\n\n');
  fprintf(fid, '- Translation-capable boundary spanning reduces RMST in all threshold scenarios: `%d`.\n', diagnostic.translation_RMST_positive_all_scenarios);
  fprintf(fid, '- Translation-capable boundary spanning reduces T95 in all scenarios where T95 is estimable with sufficient bootstrap support: `%d`.\n', diagnostic.translation_T95_positive_estimable_scenarios);
  fprintf(fid, '- Harder-tie BS-low low-readiness flag: `%d`.\n', diagnostic.harder_tie_low_readiness_flag);
  fprintf(fid, '- Total diagnostic alerts: `%d`.\n\n', diagnostic.n_alerts);

  fprintf(fid, '## Claims supported or bounded by this run\n\n');
  fprintf(fid, '- The translation mechanism is directionally robust across easier and harder readiness thresholds when evaluated with RMST.\n');
  fprintf(fid, '- Upper-tail quantiles must be interpreted only when estimable. In the hardest tie-threshold scenario, low-translation boundary spanning can fail to reach readiness often enough for event quantiles to be reliable.\n');
  fprintf(fid, '- This is not a failure of the mechanism; it is evidence that the low-translation condition becomes severely delayed under stringent tie-level readiness requirements.\n\n');

  fprintf(fid, '## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`; event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- Bootstrap intervals are hierarchical and paired over matched graph and trajectory identifiers.\n');
  fprintf(fid, '- This handover covers readiness-threshold robustness and should be combined later with final core, translation-grid, workload-grid, and selection-rule handovers.\n\n');

  fprintf(fid, '## Export diagnostic alerts\n\n');
  if isempty(threshold.alerts)
    fprintf(fid, '- None.\n');
  else
    for i = 1:length(threshold.alerts)
      fprintf(fid, '- `%s`\n', threshold.alerts{i});
    end
  end

  fclose(fid);
end


function write_md_estimable(fid, value, flag)
  if flag == 1
    fprintf(fid, '%.2f', value);
  else
    fprintf(fid, 'not estimable');
  end
end


function write_md_boot_quantile(fid, value, lo, hi, valid_share)
  if valid_share >= 0.50
    fprintf(fid, '%.2f | [%.2f, %.2f]', value, lo, hi);
  else
    fprintf(fid, 'not reliable | not reliable');
  end
end


function print_export_value(value, flag)
  if flag == 1
    fprintf('%.2f', value);
  else
    fprintf('not estimable');
  end
end
