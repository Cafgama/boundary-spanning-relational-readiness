function M = capacity_load_metrics(D, C, p, x)
% CAPACITY_LOAD_METRICS Deterministic load metrics for Model v0.1.
%
% Inputs
%   D : positive scalar, demand attempts per capacity window
%   C : positive scalar, total capacity per module
%   p : nonnegative responsibility/demand shares, sum(p)=1
%   x : nonnegative capacity shares, sum(x)=1
%
% Output struct M
%   Omega       = D/C
%   H           = normalized Herfindahl concentration of p
%   local_ratio = p./x for positive-demand actors
%   local_load  = Omega*(p./x)
%   Lambda      = max(p./x)
%   chi         = Omega*Lambda
%
% Actors with p_i=0 and x_i=0 carry no load and contribute ratio 0.
% An actor with p_i>0 and x_i=0 creates an infinite mismatch/load.

  tol = 1e-12;

  assert(isscalar(D) && isfinite(D) && D > 0, ...
    'D must be a positive finite scalar.');
  assert(isscalar(C) && isfinite(C) && C > 0, ...
    'C must be a positive finite scalar.');

  p = p(:)';
  x = x(:)';

  assert(length(p) == length(x), ...
    'p and x must have the same length.');
  assert(length(p) >= 2, ...
    'At least two interface-capable actors are required.');
  assert(all(isfinite(p)) && all(p >= 0), ...
    'p must contain finite nonnegative shares.');
  assert(all(isfinite(x)) && all(x >= 0), ...
    'x must contain finite nonnegative shares.');
  assert(abs(sum(p) - 1) <= tol, ...
    'Responsibility shares p must sum to one.');
  assert(abs(sum(x) - 1) <= tol, ...
    'Capacity shares x must sum to one.');

  n = length(p);
  Omega = D / C;

  H_raw = sum(p .^ 2);
  H = (H_raw - 1/n) / (1 - 1/n);

  local_ratio = zeros(size(p));
  positive_demand = (p > 0);
  no_capacity = positive_demand & (x == 0);
  finite_ratio = positive_demand & (x > 0);

  local_ratio(finite_ratio) = p(finite_ratio) ./ x(finite_ratio);
  local_ratio(no_capacity) = Inf;

  local_load = Omega .* local_ratio;
  Lambda = max(local_ratio);
  chi = Omega * Lambda;

  % Clamp tiny floating-point excursions only after exact calculation.
  if abs(H) < tol
    H = 0;
  elseif abs(H - 1) < tol
    H = 1;
  end

  M = struct();
  M.Omega = Omega;
  M.H = H;
  M.local_ratio = local_ratio;
  M.local_load = local_load;
  M.Lambda = Lambda;
  M.chi = chi;
end
