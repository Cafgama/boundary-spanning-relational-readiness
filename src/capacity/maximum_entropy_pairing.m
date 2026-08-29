function P = maximum_entropy_pairing(pA, pB)
  % MAXIMUM_ENTROPY_PAIRING
  % Joint endpoint distribution with no structure beyond the prescribed
  % module-level marginals:
  %
  %   P(i,j) = pA(i) * pB(j)
  %
  % This is the product/independent maximum-entropy closure.

  validate_probability_vector(pA, 'pA');
  validate_probability_vector(pB, 'pB');

  P = pA(:) * pB(:)';

  assert(abs(sum(P(:)) - 1) <= 1e-10, ...
    'Joint pairing probabilities must sum to one.');
end

function validate_probability_vector(p, name)
  assert(isvector(p) && ~isempty(p), ...
    '%s must be a nonempty vector.', name);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(p(:)) - 1) <= 1e-10, ...
    '%s must sum to one.', name);
end
