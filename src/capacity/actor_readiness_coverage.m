function M = actor_readiness_coverage(w, p, theta)
% ACTOR_READINESS_COVERAGE Demand-weighted readiness for one module.
%
% Inputs
%   w     : actor transferable-learning states in [0,1]
%   p     : actor responsibility/demand shares, sum(p)=1
%   theta : actor readiness threshold in [0,1]
%
% Output struct M
%   ready     : logical readiness indicator per actor
%   coverage  : sum_i p_i * I[w_i >= theta]

  tol = 1e-12;

  assert(isvector(w) && isvector(p) && numel(w) == numel(p), ...
    'w and p must be vectors with the same length.');
  assert(~isempty(w), 'At least one actor is required.');

  w = w(:)';
  p = p(:)';

  assert(all(isfinite(w)) && all(w >= 0) && all(w <= 1), ...
    'w must lie in [0,1].');
  assert(all(isfinite(p)) && all(p >= 0), ...
    'p must contain finite nonnegative shares.');
  assert(abs(sum(p) - 1) <= tol, ...
    'Responsibility shares p must sum to one.');
  assert(isscalar(theta) && isfinite(theta) && theta >= 0 && theta <= 1, ...
    'theta must lie in [0,1].');

  ready = (w >= theta);
  coverage = sum(p .* ready);

  if abs(coverage) < tol
    coverage = 0;
  elseif abs(coverage - 1) < tol
    coverage = 1;
  end

  M = struct();
  M.ready = ready;
  M.coverage = coverage;
end
