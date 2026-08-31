function M = productive_events_to_threshold(w0, theta, alpha)
% PRODUCTIVE_EVENTS_TO_THRESHOLD Exact deterministic Model v0.4 requirement.
%
% After k productive learning events,
%   w_k = 1 - (1-w0)*(1-alpha)^k.
%
% Returns the continuous threshold crossing k_star and the smallest integer
% number of productive events k_required that reaches w >= theta.

  assert(isscalar(w0) && isfinite(w0) && w0 >= 0 && w0 <= 1, ...
    'w0 must lie in [0,1].');
  assert(isscalar(theta) && isfinite(theta) && theta >= 0 && theta <= 1, ...
    'theta must lie in [0,1].');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');

  if w0 >= theta
    k_star = 0;
    k_required = 0;
  elseif alpha == 1
    k_star = 1;
    k_required = 1;
  elseif theta == 1
    k_star = Inf;
    k_required = Inf;
  else
    k_star = log((1-theta)/(1-w0)) / log(1-alpha);
    k_required = ceil(k_star - 1e-12);
  end

  M = struct();
  M.k_star = k_star;
  M.k_required = k_required;
end
