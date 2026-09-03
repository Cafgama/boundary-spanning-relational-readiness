function F = no_capacity_mean_crossing_real(p, w0, alpha, ell, Theta, t_upper, tol)
% NO_CAPACITY_MEAN_CROSSING_REAL
% Real-valued crossing of the exact no-capacity first-moment readiness law.
%
% Solve for the smallest real t >= 0 satisfying
%
%   E[W(t)] = sum_i p_i [1-(1-w0_i)(1-alpha*p_i*ell_i)^t] >= Theta.
%
% The stochastic process evolves at integer attempts; this real-valued root
% is an analytical timescale diagnostic used in Psi = Lambda*t0/C.
% It is not a stochastic first-passage expectation.

  if nargin < 7
    tol = 1e-10;
  end

  assert(isvector(p) && ~isempty(p) && all(isfinite(p(:))) && all(p(:) >= 0), ...
    'p must be a nonempty nonnegative vector.');
  assert(abs(sum(p(:))-1) <= 1e-10, 'p must sum to one.');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  assert(isscalar(t_upper) && isfinite(t_upper) && t_upper > 0, ...
    't_upper must be a positive finite scalar.');
  assert(isscalar(tol) && isfinite(tol) && tol > 0, ...
    'tol must be a positive finite scalar.');

  n = numel(p);
  p = p(:);
  w0 = expand_vector(w0, n, 'w0', 0, 1);
  ell = expand_vector(ell, n, 'ell', 0, 1);
  base = 1 - alpha .* p .* ell;

  f0 = mean_W(0, p, w0, base) - Theta;
  fhi = mean_W(t_upper, p, w0, base) - Theta;

  F.t_cross = NaN;
  F.delta = 0;
  F.Theta = Theta;
  F.t_upper = t_upper;
  F.W_at_cross = mean_W(t_upper, p, w0, base);

  if f0 >= 0
    F.t_cross = 0;
    F.delta = 1;
    F.W_at_cross = mean_W(0, p, w0, base);
    return;
  end

  if fhi < 0
    return;
  end

  lo = 0;
  hi = t_upper;
  while (hi-lo) > tol
    mid = 0.5*(lo+hi);
    if mean_W(mid, p, w0, base) >= Theta
      hi = mid;
    else
      lo = mid;
    end
  end

  F.t_cross = hi;
  F.delta = 1;
  F.W_at_cross = mean_W(hi, p, w0, base);
end

function W = mean_W(t, p, w0, base)
  Ew = zeros(size(p));
  for i = 1:numel(p)
    if t == 0
      Ew(i) = w0(i);
    elseif base(i) == 0
      Ew(i) = 1;
    else
      Ew(i) = 1 - (1-w0(i)) * base(i)^t;
    end
  end
  W = sum(p .* Ew);
end

function v = expand_vector(v, n, name, lower, upper)
  if isscalar(v)
    v = repmat(v, n, 1);
  else
    v = v(:);
  end
  assert(numel(v) == n && all(isfinite(v)) && all(v >= lower) && all(v <= upper), ...
    '%s must be scalar or a vector in [%g,%g] matching p.', name, lower, upper);
end
