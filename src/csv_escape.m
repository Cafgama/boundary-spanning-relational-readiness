function out = csv_escape(value)
  % CSV_ESCAPE
  % Escapes text fields for CSV output.

  if islogical(value)
    out = num2str(double(value), '%.10g');
    return;
  end

  if isnumeric(value)
    if isempty(value)
      out = '';
    elseif isnan(value)
      out = '';
    else
      out = num2str(value, '%.10g');
    end
    return;
  end

  if ~ischar(value)
    value = char(value);
  end

  value = strrep(value, '"', '""');

  needs_quotes = false;

  if any(value == ',') || any(value == '"') || any(value == sprintf('\n'))
    needs_quotes = true;
  end

  if needs_quotes
    out = ['"', value, '"'];
  else
    out = value;
  end
end
