function M = no_capacity_mean_readiness(t, p, w0, alpha, ell)
% NO_CAPACITY_MEAN_READINESS
% Exact first moment of continuous demand-weighted readiness with no blocking.
%
% For actor i:
% E[w_i(t)] = 1 - (1-w0_i) * (1-alpha*p_i*ell_i)^t
%
% Module readiness:
% E[W(t)] = sum_i p_i E[w_i(t)].
%
% Inputs
%   t     : nonnegative integer scalar or vector of global demand attempts
%   p     : responsibility shares summing to one
%   w0    : scalar initial state or vector matching p
%   alpha : reinforcement fraction in (0,1]
%   ell   : scalar learning effectiveness or vector matching p

  tol = 1e-12;
  assert(isvector(t) && ~isempty(t) && all(isfinite(t(:))) && all(t(:) >= 0), ...
    't must contain finite nonnegative values.');
  assert(all(abs(t(:) - round(t(:))) <= tol), ...
    't must contain integer attempt counts.');
  assert(isvector(p) && ~isempty(p) && all(isfinite(p(:))) && all(p(:) >= 0), ...
    'p must be a nonempty nonnegative vector.');
  assert(abs(sum(p(:)) - 1) <= 1e-10, 'p must sum to one.');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');

  n = numel(p);
  p = p(:);

  if isscalar(w0)
    w0 = repmat(w0, n, 1);
  else
    w0 = w0(:);
  end
  if isscalar(ell)
    ell = repmat(ell, n, 1);
  else
    ell = ell(:);
  end

  assert(numel(w0) == n && all(isfinite(w0)) && all(w0 >= 0) && all(w0 <= 1), ...
    'w0 must be scalar or a vector in [0,1] matching p.');
  assert(numel(ell) == n && all(isfinite(ell)) && all(ell >= 0) && all(ell <= 1), ...
    'ell must be scalar or a probability vector matching p.');

  base = 1 - alpha .* p .* ell;
  trow = round(t(:))';
  Ew = zeros(n, numel(trow));
  for i = 1:n
    Ew(i,:) = 1 - (1-w0(i)) .* (base(i) .^ trow);
  end

  Wmean = (p' * Ew);

  M.t = trow;
  M.Ew = Ew;
  M.Wmean = Wmean;
  M.initial_increment = sum(p .* (alpha .* p .* ell .* (1-w0)));
end
