function assert_no_duplicate_rows(X, label)
  % ASSERT_NO_DUPLICATE_ROWS
  % Fails if a numeric matrix contains duplicate rows.

  if nargin < 2
    label = 'matrix';
  end

  assert(isnumeric(X), [label, ' must be numeric.']);
  assert(columns(X) > 0, [label, ' must have at least one column.']);

  U = unique(X, 'rows');

  assert(rows(U) == rows(X), ...
    [label, ' contains duplicate rows.']);
end
