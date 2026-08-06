function export_summary_csv(all_summaries, filename)
  % EXPORT_SUMMARY_CSV
  % Exports experiment summary structures to a CSV file.
  %
  % Input:
  %   all_summaries  cell array of summary structures from summarize_results()
  %   filename       output CSV filename
  %
  % Example:
  %   export_summary_csv(all_summaries, '../results/processed/debug_summary.csv');

  validate_inputs(all_summaries, filename);

  fid = fopen(filename, 'w');

  assert(fid != -1, ['Could not open file for writing: ', filename]);

  % -----------------------------
  % Header
  % -----------------------------
  header = {
    'architecture',
    'seed',
    'NG',
    'NT',
    'n_runs',
    'n_converged',
    'n_nonconverged',
    'convergence_rate',
    'nonconvergence_rate',
    'T_conv_mean',
    'T_conv_median',
    'T_conv_p75',
    'T_conv_p90',
    'T_conv_p95',
    'T_conv_min',
    'T_conv_max',
    'T_cens_mean',
    'T_cens_median',
    'T_cens_p75',
    'T_cens_p90',
    'T_cens_p95',
    'T_cens_min',
    'T_cens_max',
    'final_RB_mean',
    'final_RB_median',
    'final_RB_min',
    'final_RB_max',
    'total_edges_mean',
    'total_edges_median',
    'mean_degree_mean',
    'mean_degree_median',
    'max_degree_mean',
    'max_degree_median',
    'boundary_edges_mean',
    'boundary_edges_median'
  };

  write_csv_line(fid, header);

  % -----------------------------
  % Rows
  % -----------------------------
  for i = 1:length(all_summaries)
    S = all_summaries{i};

    row = {
      S.architecture,
      S.seed,
      S.NG,
      S.NT,
      S.n_runs,
      S.n_converged,
      S.n_nonconverged,
      S.convergence_rate,
      S.nonconvergence_rate,
      S.T_conv_mean,
      S.T_conv_median,
      S.T_conv_p75,
      S.T_conv_p90,
      S.T_conv_p95,
      S.T_conv_min,
      S.T_conv_max,
      S.T_cens_mean,
      S.T_cens_median,
      S.T_cens_p75,
      S.T_cens_p90,
      S.T_cens_p95,
      S.T_cens_min,
      S.T_cens_max,
      S.final_RB_mean,
      S.final_RB_median,
      S.final_RB_min,
      S.final_RB_max,
      S.total_edges_mean,
      S.total_edges_median,
      S.mean_degree_mean,
      S.mean_degree_median,
      S.max_degree_mean,
      S.max_degree_median,
      S.boundary_edges_mean,
      S.boundary_edges_median
    };

    write_csv_line(fid, row);
  end

  fclose(fid);
end


function write_csv_line(fid, values)
  % WRITE_CSV_LINE
  % Writes one CSV line from a cell array of values.

  for j = 1:length(values)
    value_str = value_to_csv_string(values{j});

    if j < length(values)
      fprintf(fid, '%s,', value_str);
    else
      fprintf(fid, '%s\n', value_str);
    end
  end
end


function s = value_to_csv_string(value)
  % VALUE_TO_CSV_STRING
  % Converts a value to a CSV-safe string.

  if ischar(value)
    s = ['"', escape_quotes(value), '"'];

  elseif isnumeric(value)
    if isnan(value)
      s = 'NaN';
    else
      s = sprintf('%.10g', value);
    end

  else
    error('Unsupported value type for CSV export.');
  end
end


function out = escape_quotes(in)
  % ESCAPE_QUOTES
  % Escapes double quotes inside a string for CSV.

  out = strrep(in, '"', '""');
end


function validate_inputs(all_summaries, filename)
  % VALIDATE_INPUTS
  % Basic validation.

  assert(iscell(all_summaries), 'all_summaries must be a cell array.');
  assert(length(all_summaries) > 0, 'all_summaries cannot be empty.');
  assert(ischar(filename), 'filename must be a character string.');

  for i = 1:length(all_summaries)
    assert(isstruct(all_summaries{i}), ...
      'Each element of all_summaries must be a structure.');

    assert(isfield(all_summaries{i}, 'architecture'), ...
      'Each summary must contain architecture field.');
  end
end
