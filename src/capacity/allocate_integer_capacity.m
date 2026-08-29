function [c, x_realized] = allocate_integer_capacity(C, x)
  % ALLOCATE_INTEGER_CAPACITY
  % Convert target capacity shares x into integer actor capacities that sum
  % exactly to total capacity C using the largest-remainder method.
  %
  % Tie-breaking is deterministic: lower actor index wins equal remainders.

  tol = 1e-12;

  assert(isscalar(C) && isfinite(C) && C >= 0, ...
    'C must be a finite nonnegative scalar.');
  assert(abs(C - round(C)) <= tol, ...
    'C must be an integer number of interaction-capacity units.');
  assert(isvector(x) && ~isempty(x), ...
    'x must be a nonempty capacity-share vector.');
  assert(all(isfinite(x(:))) && all(x(:) >= 0), ...
    'x must contain finite nonnegative values.');
  assert(abs(sum(x(:)) - 1) <= 1e-10, ...
    'Capacity shares x must sum to one.');

  original_size = size(x);
  x_row = x(:)';
  C = round(C);

  raw = C .* x_row;
  c_row = floor(raw);
  remainder_units = C - sum(c_row);
  fractional = raw - c_row;

  for r = 1:remainder_units
    max_fraction = max(fractional);
    idx = find(abs(fractional - max_fraction) <= tol, 1, 'first');
    c_row(idx) = c_row(idx) + 1;
    fractional(idx) = -Inf;
  end

  assert(sum(c_row) == C, ...
    'Integer allocation failed to conserve total capacity.');
  assert(all(c_row >= 0) && all(abs(c_row - round(c_row)) <= tol), ...
    'Integer allocation produced invalid actor capacities.');

  if C > 0
    x_realized_row = c_row ./ C;
  else
    x_realized_row = zeros(size(c_row));
  end

  c = reshape(c_row, original_size);
  x_realized = reshape(x_realized_row, original_size);
end
