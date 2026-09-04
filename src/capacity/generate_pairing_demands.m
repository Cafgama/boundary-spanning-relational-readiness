function pairs = generate_pairing_demands(D, pA, pB, seed, pairing_mode)
% GENERATE_PAIRING_DEMANDS
% E7 robustness demand generator with frozen pairing alternatives.
%
% pairing_mode = 'product'
%   Independent maximum-entropy mixing: P_ij = pA_i pB_j.
%
% pairing_mode = 'assortative'
%   Perfect rank-assortative coupling for symmetric modules:
%   P_ij = p_i I(i=j). Requires pA and pB to be equal vectors.
%
% The function uses an explicit seed and restores caller RNG state.

  if nargin < 5 || isempty(pairing_mode)
    pairing_mode = 'product';
  end

  assert(ischar(pairing_mode), 'pairing_mode must be a character string.');
  mode = lower(strtrim(pairing_mode));

  switch mode
    case 'product'
      pairs = generate_max_entropy_demands(D, pA, pB, seed);

    case 'assortative'
      tol = 1e-12;
      assert(numel(pA) == numel(pB), ...
        'Assortative pairing requires equal module sizes.');
      assert(max(abs(pA(:)-pB(:))) <= tol, ...
        'Assortative pairing requires identical symmetric responsibility vectors.');
      validate_probability_vector(pA, 'pA');
      assert(isscalar(D) && isfinite(D) && D >= 0 && abs(D-round(D)) <= tol, ...
        'D must be a nonnegative integer.');
      assert(isscalar(seed) && isfinite(seed) && seed >= 0 && abs(seed-round(seed)) <= tol, ...
        'seed must be a nonnegative integer.');

      D = round(D);
      seed = round(seed);
      old_state = rng();
      rng(seed, 'twister');
      u = rand(D,1);
      rng(old_state);

      cdf = cumsum(pA(:));
      cdf(end) = 1;
      idx = zeros(D,1);
      for t = 1:D
        k = find(u(t) < cdf, 1, 'first');
        if isempty(k)
          k = numel(cdf);
        end
        idx(t) = k;
      end
      pairs = [idx,idx];

    otherwise
      error('Unknown pairing_mode: %s', pairing_mode);
  end
end

function validate_probability_vector(p, name)
  assert(isvector(p) && ~isempty(p), '%s must be a nonempty vector.', name);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(p(:))-1) <= 1e-10, '%s must sum to one.', name);
end
