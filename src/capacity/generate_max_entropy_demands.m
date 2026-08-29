function pairs = generate_max_entropy_demands(D, pA, pB, seed)
  % GENERATE_MAX_ENTROPY_DEMANDS
  % Generate D endpoint pairs under independent maximum-entropy mixing.
  %
  % The function uses an explicit seed and restores the caller RNG state,
  % keeping this admission-layer stream isolated from other simulations.

  tol = 1e-12;

  assert(isscalar(D) && isfinite(D) && D >= 0, ...
    'D must be a finite nonnegative scalar.');
  assert(abs(D - round(D)) <= tol, ...
    'D must be an integer number of demand attempts.');
  assert(isscalar(seed) && isfinite(seed) && seed >= 0, ...
    'seed must be a finite nonnegative scalar.');
  assert(abs(seed - round(seed)) <= tol, ...
    'seed must be an integer.');

  validate_probability_vector(pA, 'pA');
  validate_probability_vector(pB, 'pB');

  D = round(D);
  seed = round(seed);

  old_state = rng();
  rng(seed, 'twister');
  uA = rand(D, 1);
  uB = rand(D, 1);
  rng(old_state);

  pairs = zeros(D, 2);
  cdfA = cumsum(pA(:));
  cdfB = cumsum(pB(:));
  cdfA(end) = 1;
  cdfB(end) = 1;

  for t = 1:D
    pairs(t, 1) = inverse_cdf_index(uA(t), cdfA);
    pairs(t, 2) = inverse_cdf_index(uB(t), cdfB);
  end
end

function idx = inverse_cdf_index(u, cdf)
  idx = find(u < cdf, 1, 'first');
  if isempty(idx)
    idx = length(cdf);
  end
end

function validate_probability_vector(p, name)
  assert(isvector(p) && ~isempty(p), ...
    '%s must be a nonempty vector.', name);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(p(:)) - 1) <= 1e-10, ...
    '%s must sum to one.', name);
end
