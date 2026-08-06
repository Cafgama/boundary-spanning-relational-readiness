function [GS, csv_file, mat_file] = process_raw_result_file(raw_file, output_dir)
  % PROCESS_RAW_RESULT_FILE
  % Loads one raw simulation result file, aggregates trajectories by graph,
  % and exports graph-level CSV and MAT files.
  %
  % Inputs:
  %   raw_file   path to raw .mat result file
  %   output_dir directory for graph-level outputs
  %
  % Outputs:
  %   GS         graph-level summary structure
  %   csv_file   generated CSV path
  %   mat_file   generated MAT path

  assert(ischar(raw_file), 'raw_file must be a character string.');
  assert(ischar(output_dir), 'output_dir must be a character string.');
  assert(exist(raw_file, 'file') == 2, ...
    ['Raw result file not found: ', raw_file]);

  ensure_dir(output_dir);

  data = load(raw_file);

  assert(isfield(data, 'results'), ...
    'Raw file must contain a results structure.');

  assert(isfield(data, 'P'), ...
    'Raw file must contain parameter structure P.');

  GS = summarize_by_graph(data.results, data.P);

  [~, base_name, ~] = fileparts(raw_file);

  csv_file = fullfile(output_dir, ...
    [base_name, '_graph_summary.csv']);

  mat_file = fullfile(output_dir, ...
    [base_name, '_graph_summary.mat']);

  export_graph_summary_csv(GS, csv_file);
  save(mat_file, 'GS');

  fprintf('\nGraph-level outputs created:\n');
  fprintf('%s\n', csv_file);
  fprintf('%s\n', mat_file);
end
