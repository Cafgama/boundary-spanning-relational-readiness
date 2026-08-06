function write_cell_csv(filename, header, rows)
  % WRITE_CELL_CSV
  % Writes a CSV file from a header cell array and a cell matrix.
  %
  % Handles numeric, logical, text, and missing values safely.

  fid = fopen(filename, 'w');

  if fid < 0
    error(['Could not open file for writing: ', filename]);
  end

  n_header = length(header);

  for j = 1:n_header
    fprintf(fid, '%s', csv_escape(header{j}));

    if j < n_header
      fprintf(fid, ',');
    else
      fprintf(fid, '\n');
    end
  end

  [n_rows, n_cols] = size(rows);

  for i = 1:n_rows
    for j = 1:n_cols

      value = rows{i, j};

      if islogical(value)

        out = num2str(double(value), '%.10g');

      elseif isnumeric(value)

        if isempty(value)
          out = '';
        elseif isnan(value)
          out = '';
        else
          out = num2str(value, '%.10g');
        end

      else

        out = csv_escape(value);

      end

      fprintf(fid, '%s', out);

      if j < n_cols
        fprintf(fid, ',');
      else
        fprintf(fid, '\n');
      end
    end
  end

  fclose(fid);
end
