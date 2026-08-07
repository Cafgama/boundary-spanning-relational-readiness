function assert_close(actual, expected, tolerance, message)
  % ASSERT_CLOSE
  % Small numeric assertion helper for rerun_v2 tests.

  if nargin < 3
    tolerance = 1e-10;
  end

  if nargin < 4
    message = 'Values are not sufficiently close.';
  end

  assert(abs(actual - expected) <= tolerance, message);
end
