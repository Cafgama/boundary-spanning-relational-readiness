function exports = analyze_mini_heatmap_results(processed_file)
  % ANALYZE_MINI_HEATMAP_RESULTS
  % Reads a rerun_v2 mini heatmap processed file and exports clean CSVs plus
  % a manuscript-facing handover document.
  %
  % Usage:
  %   exports = analyze_mini_heatmap_results()
  %   exports = analyze_mini_heatmap_results(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/mini_heatmap/mini_heatmap_processed_*.mat
  % file is used. This script does not run simulations.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  if nargin < 1 || isempty(processed_file)
    processed_dir_default = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'mini_heatmap');
    processed_file = latest_mini_heatmap_processed_file(processed_dir_default);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Mini heatmap processed file not found: ', processed_file]);

  loaded = load(processed_file);
  assert(isfield(loaded, 'mini_heatmap'), ...
    'Processed file must contain a mini_heatmap structure.');

  mini_heatmap = loaded.mini_heatmap;
  validate_mini_heatmap_structure(mini_heatmap);

  output_tag = mini_heatmap.output_tag;
  processed_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', output_tag);
  figure_data_dir = fullfile(repo_root, 'results', 'figure_data', 'rerun_v2', output_tag);
  docs_dir = fullfile(repo_root, 'docs');

  ensure_dir(processed_dir);
  ensure_dir(figure_data_dir);
  ensure_dir(docs_dir);

  condition_rows = build_condition_rows(mini_heatmap);
  matrices = build_heatmap_matrices(mini_heatmap, condition_rows);
  diagnostic = build_export_diagnostic(mini_heatmap, matrices);

  condition_csv_processed = fullfile(processed_dir, 'mini_heatmap_condition_estimates.csv');
  rmst_matrix_csv_processed = fullfile(processed_dir, 'mini_heatmap_matrix_RMST.csv');
  t95_matrix_csv_processed = fullfile(processed_dir, 'mini_heatmap_matrix_T95.csv');
  readiness_matrix_csv_processed = fullfile(processed_dir, 'mini_heatmap_matrix_readiness_probability.csv');

  condition_csv_figure = fullfile(figure_data_dir, 'mini_heatmap_condition_estimates.csv');
  rmst_matrix_csv_figure = fullfile(figure_data_dir, 'mini_heatmap_matrix_RMST.csv');
  t95_matrix_csv_figure = fullfile(figure_data_dir, 'mini_heatmap_matrix_T95.csv');
  readiness_matrix_csv_figure = fullfile(figure_data_dir, 'mini_heatmap_matrix_readiness_probability.csv');

  handover_file = fullfile(docs_dir, 'mini_heatmap_results_handover.md');

  write_condition_csv(condition_csv_processed, condition_rows);
  write_matrix_csv(rmst_matrix_csv_processed, matrices.pi_BS_grid, matrices.b_grid, ...
    matrices.load_grid, matrices.RMST_matrix, 'RMST');
  write_matrix_csv(t95_matrix_csv_processed, matrices.pi_BS_grid, matrices.b_grid, ...
    matrices.load_grid, matrices.T95_matrix, 'T95');
  write_matrix_csv(readiness_matrix_csv_processed, matrices.pi_BS_grid, matrices.b_grid, ...
    matrices.load_grid, matrices.readiness_matrix, 'readiness_probability');

  copyfile(condition_csv_processed, condition_csv_figure);
  copyfile(rmst_matrix_csv_processed, rmst_matrix_csv_figure);
  copyfile(t95_matrix_csv_processed, t95_matrix_csv_figure);
  copyfile(readiness_matrix_csv_processed, readiness_matrix_csv_figure);

  write_mini_heatmap_handover(handover_file, mini_heatmap, processed_file, ...
    condition_csv_processed, rmst_matrix_csv_processed, t95_matrix_csv_processed, ...
    readiness_matrix_csv_processed, condition_csv_figure, rmst_matrix_csv_figure, ...
    t95_matrix_csv_figure, readiness_matrix_csv_figure, condition_rows, matrices, diagnostic);

  exports = struct();
  exports.processed_file = processed_file;
  exports.output_tag = output_tag;
  exports.condition_csv_processed = condition_csv_processed;
  exports.rmst_matrix_csv_processed = rmst_matrix_csv_processed;
  exports.t95_matrix_csv_processed = t95_matrix_csv_processed;
  exports.readiness_matrix_csv_processed = readiness_matrix_csv_processed;
  exports.condition_csv_figure = condition_csv_figure;
  exports.rmst_matrix_csv_figure = rmst_matrix_csv_figure;
  exports.t95_matrix_csv_figure = t95_matrix_csv_figure;
  exports.readiness_matrix_csv_figure = readiness_matrix_csv_figure;
  exports.handover_file = handover_file;
  exports.condition_rows = condition_rows;
  exports.matrices = matrices;
  exports.diagnostic = diagnostic;
  exports.alerts = diagnostic.alerts(:);
  exports.n_alerts = length(diagnostic.alerts);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 MINI HEATMAP EXPORTS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('condition CSV: %s\n', condition_csv_processed);
  fprintf('RMST matrix CSV: %s\n', rmst_matrix_csv_processed);
  fprintf('T95 matrix CSV: %s\n', t95_matrix_csv_processed);
  fprintf('readiness matrix CSV: %s\n', readiness_matrix_csv_processed);
  fprintf('handover: %s\n', handover_file);

  fprintf('\nMini heatmap RMST matrix\n');
  fprintf('--------------------------------------------\n');
  disp(matrices.RMST_matrix);

  fprintf('\nDiagnostics\n');
  fprintf('--------------------------------------------\n');
  fprintf('translation_monotone_all_b: %d\n', diagnostic.translation_monotone_all_b);
  fprintf('workload_monotone_all_pi: %d\n', diagnostic.workload_monotone_all_pi);
  fprintf('n_alerts: %d\n', length(diagnostic.alerts));

  if isempty(diagnostic.alerts)
    fprintf('No mini heatmap export alerts.\n');
  else
    for i = 1:length(diagnostic.alerts)
      fprintf('- %s\n', diagnostic.alerts{i});
    end
  end

  fprintf('\n============================================\n');
  fprintf('RERUN V2 MINI HEATMAP EXPORTS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_mini_heatmap_processed_file(processed_dir)
  files = dir(fullfile(processed_dir, 'mini_heatmap_processed_*.mat'));
  assert(~isempty(files), ...
    ['No mini_heatmap_processed_*.mat file found in ', processed_dir]);

  datenums = zeros(length(files), 1);
  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(processed_dir, files(idx).name);
end


function validate_mini_heatmap_structure(mini_heatmap)
  required_fields = {
    'run_type', 'output_tag', 'timestamp', 'NG', 'NT', 'T_max', ...
    'seed_base', 'theta', 'q', 'pi_out', 'pi_BS_grid', 'b_grid', ...
    'conditions', 'estimands', 'diagnostic', 'alerts', 'n_alerts'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(mini_heatmap, fname), ...
      ['mini_heatmap missing field: ', fname]);
  end

  assert(isstruct(mini_heatmap.estimands), 'mini_heatmap.estimands must be a struct.');
  assert(length(mini_heatmap.conditions) == ...
    length(mini_heatmap.pi_BS_grid) * length(mini_heatmap.b_grid), ...
    'Number of conditions must equal length(pi_BS_grid) * length(b_grid).');
end


function rows = build_condition_rows(mini_heatmap)
  conditions = mini_heatmap.conditions;
  rows = [];

  for i = 1:length(conditions)
    C = conditions(i);
    S = mini_heatmap.estimands.(C.condition_id);

    row = struct();
    row.condition_id = C.condition_id;
    row.architecture = C.architecture;
    row.selection_rule = C.selection_rule;
    row.pi_BS = C.P.pi_BS;
    row.pi_out = C.P.pi_out;
    row.b = C.P.b;
    row.load_per_spanner = C.load_per_spanner;
    row.theta = mini_heatmap.theta;
    row.q = mini_heatmap.q;
    row.T_max = mini_heatmap.T_max;
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


function matrices = build_heatmap_matrices(mini_heatmap, condition_rows)
  pi_BS_grid = mini_heatmap.pi_BS_grid(:)';
  b_grid = mini_heatmap.b_grid(:)';
  load_grid = zeros(length(b_grid), 1);

  RMST_matrix = NaN(length(b_grid), length(pi_BS_grid));
  T95_matrix = NaN(length(b_grid), length(pi_BS_grid));
  readiness_matrix = NaN(length(b_grid), length(pi_BS_grid));

  for b_idx = 1:length(b_grid)
    load_grid(b_idx) = mini_heatmap.conditions((b_idx - 1) * length(pi_BS_grid) + 1).load_per_spanner;
  end

  for i = 1:length(condition_rows)
    r = condition_rows(i);
    b_idx = find(b_grid == r.b);
    p_idx = find(abs(pi_BS_grid - r.pi_BS) < 1e-9);

    assert(~isempty(b_idx), 'b value not found in b_grid.');
    assert(~isempty(p_idx), 'pi_BS value not found in pi_BS_grid.');

    RMST_matrix(b_idx, p_idx) = r.RMST;
    readiness_matrix(b_idx, p_idx) = r.readiness_probability;

    if r.T95_estimable == 1
      T95_matrix(b_idx, p_idx) = r.T95;
    end
  end

  matrices = struct();
  matrices.pi_BS_grid = pi_BS_grid;
  matrices.b_grid = b_grid;
  matrices.load_grid = load_grid;
  matrices.RMST_matrix = RMST_matrix;
  matrices.T95_matrix = T95_matrix;
  matrices.readiness_matrix = readiness_matrix;
end


function diagnostic = build_export_diagnostic(mini_heatmap, matrices)
  translation_monotone_by_b = ones(length(matrices.b_grid), 1);
  workload_monotone_by_pi = ones(length(matrices.pi_BS_grid), 1);

  for b_idx = 1:length(matrices.b_grid)
    if any(diff(matrices.RMST_matrix(b_idx, :)) > 0)
      translation_monotone_by_b(b_idx) = 0;
    end
  end

  for p_idx = 1:length(matrices.pi_BS_grid)
    if any(diff(matrices.RMST_matrix(:, p_idx)) > 0)
      workload_monotone_by_pi(p_idx) = 0;
    end
  end

  alerts = {};
  for i = 1:length(mini_heatmap.alerts)
    alerts{end + 1} = mini_heatmap.alerts{i};
  end

  if any(translation_monotone_by_b == 0)
    alerts{end + 1} = 'EXPORT_RMST_NOT_MONOTONIC_DECREASING_IN_PI_FOR_AT_LEAST_ONE_B';
  end

  if any(workload_monotone_by_pi == 0)
    alerts{end + 1} = 'EXPORT_RMST_NOT_MONOTONIC_DECREASING_IN_B_FOR_AT_LEAST_ONE_PI';
  end

  diagnostic = struct();
  diagnostic.translation_monotone_by_b = translation_monotone_by_b;
  diagnostic.workload_monotone_by_pi = workload_monotone_by_pi;
  diagnostic.translation_monotone_all_b = all(translation_monotone_by_b == 1);
  diagnostic.workload_monotone_all_pi = all(workload_monotone_by_pi == 1);
  diagnostic.alerts = alerts(:);
end


function write_condition_csv(filename, rows)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, ['condition_id,architecture,selection_rule,pi_BS,pi_out,b,', ...
    'load_per_spanner,theta,q,T_max,readiness_probability,', ...
    'censoring_probability,RMST,T50,T50_estimable,T90,T90_estimable,', ...
    'T95,T95_estimable\n']);

  for i = 1:length(rows)
    r = rows(i);
    fprintf(fid, '%s,%s,%s,%.6f,%.6f,%d,%.6f,%.6f,%.6f,%d,%.6f,%.6f,%.6f,', ...
      r.condition_id, r.architecture, r.selection_rule, r.pi_BS, r.pi_out, ...
      r.b, r.load_per_spanner, r.theta, r.q, r.T_max, ...
      r.readiness_probability, r.censoring_probability, r.RMST);
    write_csv_numeric(fid, r.T50, r.T50_estimable);
    fprintf(fid, ',%d,', r.T50_estimable);
    write_csv_numeric(fid, r.T90, r.T90_estimable);
    fprintf(fid, ',%d,', r.T90_estimable);
    write_csv_numeric(fid, r.T95, r.T95_estimable);
    fprintf(fid, ',%d\n', r.T95_estimable);
  end

  fclose(fid);
end


function write_matrix_csv(filename, pi_BS_grid, b_grid, load_grid, matrix_values, metric_name)
  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open file for writing: ', filename]);

  fprintf(fid, 'metric,b,load_per_spanner');
  for p_idx = 1:length(pi_BS_grid)
    fprintf(fid, ',pi_BS_%.2f', pi_BS_grid(p_idx));
  end
  fprintf(fid, '\n');

  for b_idx = 1:length(b_grid)
    fprintf(fid, '%s,%d,%.6f', metric_name, b_grid(b_idx), load_grid(b_idx));
    for p_idx = 1:length(pi_BS_grid)
      fprintf(fid, ',');
      write_csv_numeric(fid, matrix_values(b_idx, p_idx), ~isnan(matrix_values(b_idx, p_idx)));
    end
    fprintf(fid, '\n');
  end

  fclose(fid);
end


function write_csv_numeric(fid, value, estimable)
  if estimable == 1 && ~isnan(value)
    fprintf(fid, '%.6f', value);
  end
end


function write_mini_heatmap_handover(filename, mini_heatmap, processed_file, ...
    condition_csv_processed, rmst_matrix_csv_processed, t95_matrix_csv_processed, ...
    readiness_matrix_csv_processed, condition_csv_figure, rmst_matrix_csv_figure, ...
    t95_matrix_csv_figure, readiness_matrix_csv_figure, condition_rows, matrices, diagnostic)

  fid = fopen(filename, 'w');
  assert(fid > 0, ['Could not open handover file for writing: ', filename]);

  fprintf(fid, '# Mini heatmap results handover — rerun_v2\n\n');
  fprintf(fid, 'Generated by `experiments/rerun_v2/analyze_mini_heatmap_results.m`.\n\n');

  fprintf(fid, '## Source and reproducibility\n\n');
  fprintf(fid, '- Processed source file: `%s`\n', processed_file);
  fprintf(fid, '- Run type: `%s`\n', mini_heatmap.run_type);
  fprintf(fid, '- Output tag: `%s`\n', mini_heatmap.output_tag);
  fprintf(fid, '- Timestamp: `%s`\n', mini_heatmap.timestamp);
  fprintf(fid, '- NG: %d graph realizations\n', mini_heatmap.NG);
  fprintf(fid, '- NT: %d trajectories per graph\n', mini_heatmap.NT);
  fprintf(fid, '- T_max: %d\n', mini_heatmap.T_max);
  fprintf(fid, '- Seed base: %d\n', mini_heatmap.seed_base);
  fprintf(fid, '- Theta: %.2f\n', mini_heatmap.theta);
  fprintf(fid, '- q: %.2f\n', mini_heatmap.q);
  fprintf(fid, '- pi_out: %.2f\n', mini_heatmap.pi_out);
  fprintf(fid, '- pi_BS grid: ');
  for i = 1:length(mini_heatmap.pi_BS_grid)
    fprintf(fid, '%.2f ', mini_heatmap.pi_BS_grid(i));
  end
  fprintf(fid, '\n');
  fprintf(fid, '- b grid: ');
  for i = 1:length(mini_heatmap.b_grid)
    fprintf(fid, '%d ', mini_heatmap.b_grid(i));
  end
  fprintf(fid, '\n');
  fprintf(fid, '- Diagnostic alerts: %d\n\n', length(diagnostic.alerts));

  fprintf(fid, '## Exported files\n\n');
  fprintf(fid, '- Condition estimates CSV: `%s`\n', condition_csv_processed);
  fprintf(fid, '- RMST matrix CSV: `%s`\n', rmst_matrix_csv_processed);
  fprintf(fid, '- T95 matrix CSV: `%s`\n', t95_matrix_csv_processed);
  fprintf(fid, '- Readiness-probability matrix CSV: `%s`\n', readiness_matrix_csv_processed);
  fprintf(fid, '- Figure-data condition estimates CSV: `%s`\n', condition_csv_figure);
  fprintf(fid, '- Figure-data RMST matrix CSV: `%s`\n', rmst_matrix_csv_figure);
  fprintf(fid, '- Figure-data T95 matrix CSV: `%s`\n', t95_matrix_csv_figure);
  fprintf(fid, '- Figure-data readiness-probability matrix CSV: `%s`\n\n', readiness_matrix_csv_figure);

  fprintf(fid, '## Condition-level estimates\n\n');
  fprintf(fid, '| Condition | pi_BS | b | Load per spanner | Readiness probability | RMST | T50 | T90 | T95 |\n');
  fprintf(fid, '|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');
  for i = 1:length(condition_rows)
    r = condition_rows(i);
    fprintf(fid, '| `%s` | %.2f | %d | %.2f | %.3f | %.2f | ', ...
      r.condition_id, r.pi_BS, r.b, r.load_per_spanner, ...
      r.readiness_probability, r.RMST);
    write_md_estimable(fid, r.T50, r.T50_estimable);
    fprintf(fid, ' | ');
    write_md_estimable(fid, r.T90, r.T90_estimable);
    fprintf(fid, ' | ');
    write_md_estimable(fid, r.T95, r.T95_estimable);
    fprintf(fid, ' |\n');
  end

  fprintf(fid, '\n## RMST heatmap matrix\n\n');
  write_md_matrix(fid, matrices.pi_BS_grid, matrices.b_grid, matrices.load_grid, matrices.RMST_matrix);

  fprintf(fid, '\n## Diagnostic interpretation\n\n');
  fprintf(fid, '- RMST decreases with translation capability for every tested workload level: `%d`.\n', ...
    diagnostic.translation_monotone_all_b);
  fprintf(fid, '- RMST decreases as boundary-spanner capacity increases for every tested translation level: `%d`.\n', ...
    diagnostic.workload_monotone_all_pi);
  fprintf(fid, '- Total diagnostic alerts: `%d`.\n\n', length(diagnostic.alerts));

  fprintf(fid, '## Claims supported or bounded by this run\n\n');
  fprintf(fid, '- The mini heatmap is a visual synthesis of the translation and workload mechanisms, not a replacement for the main final-core, translation-grid, and workload-grid tests.\n');
  fprintf(fid, '- The intended figure should use RMST as the primary cell value.\n');
  fprintf(fid, '- The figure should be interpreted as a design map: higher translation capability and lower per-spanner workload are expected to move the system toward lower relational readiness delay.\n');
  fprintf(fid, '- Event quantiles should remain secondary and reported only when estimable.\n\n');

  fprintf(fid, '## Interpretation guardrails\n\n');
  fprintf(fid, '- These results refer to time to relational coordination readiness, not R&D performance, innovation success, patents, or output quality.\n');
  fprintf(fid, '- RMST uses observed time `T_tilde`; event quantiles are reported only when estimable.\n');
  fprintf(fid, '- Censored trajectories are not converted into artificial event times.\n');
  fprintf(fid, '- This mini heatmap does not add a new causal identification strategy; it integrates two already-tested design dimensions for reader comprehension.\n\n');

  fprintf(fid, '## Export diagnostic alerts\n\n');
  if isempty(diagnostic.alerts)
    fprintf(fid, '- None.\n');
  else
    for i = 1:length(diagnostic.alerts)
      fprintf(fid, '- `%s`\n', diagnostic.alerts{i});
    end
  end

  fclose(fid);
end


function write_md_estimable(fid, value, flag)
  if flag == 1 && ~isnan(value)
    fprintf(fid, '%.2f', value);
  else
    fprintf(fid, 'not estimable');
  end
end


function write_md_matrix(fid, pi_BS_grid, b_grid, load_grid, matrix_values)
  fprintf(fid, '| b | Load per spanner |');
  for p_idx = 1:length(pi_BS_grid)
    fprintf(fid, ' pi_BS %.2f |', pi_BS_grid(p_idx));
  end
  fprintf(fid, '\n');

  fprintf(fid, '|---:|---:|');
  for p_idx = 1:length(pi_BS_grid)
    fprintf(fid, '---:|');
  end
  fprintf(fid, '\n');

  for b_idx = 1:length(b_grid)
    fprintf(fid, '| %d | %.2f |', b_grid(b_idx), load_grid(b_idx));
    for p_idx = 1:length(pi_BS_grid)
      if isnan(matrix_values(b_idx, p_idx))
        fprintf(fid, ' not estimable |');
      else
        fprintf(fid, ' %.2f |', matrix_values(b_idx, p_idx));
      end
    end
    fprintf(fid, '\n');
  end
end
