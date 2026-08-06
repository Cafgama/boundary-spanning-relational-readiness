function filename = latest_file(pattern)
  % LATEST_FILE
  % Returns the most recent file matching a pattern.

  files = dir(pattern);

  if isempty(files)
    error(['No files found for pattern: ', pattern]);
  end

  datenums = [files.datenum];
  [~, idx] = max(datenums);

  filename = fullfile(files(idx).folder, files(idx).name);
end
