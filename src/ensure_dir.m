function ensure_dir(pathname)
  % ENSURE_DIR
  % Creates a directory if it does not already exist.
  %
  % Input:
  %   pathname  path to directory

  assert(ischar(pathname), 'pathname must be a character string.');

  if exist(pathname, 'dir') != 7
    [success, message] = mkdir(pathname);

    assert(success, ['Could not create directory: ', pathname, ...
      '. System message: ', message]);
  end
end
