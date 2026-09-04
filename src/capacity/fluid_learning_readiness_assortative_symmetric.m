function F = fluid_learning_readiness_assortative_symmetric(Omega, p, x, w0, alpha, ell, Theta, C, max_windows)
% FLUID_LEARNING_READINESS_ASSORTATIVE_SYMMETRIC
% Deterministic E7 benchmark for perfect rank-assortative symmetric pairing.
%
% Pair i-i is attempted with probability p_i. While actor i remains active,
% its residual mean-learning state obeys
%
%   r_i(t+dt) = r_i(t) * (1-alpha*p_i*ell_i)^dt.
%
% Actor i exhausts at scaled attempt time s_i=x_i/p_i within each window.
% Unlike product pairing, exhaustion of another rank does not multiply the
% exposure rate of still-active actors by an opposite-module active-mass A.

  tol = 1e-12;
  root_tol = 1e-10;

  assert(isscalar(Omega) && isfinite(Omega) && Omega > 0, ...
    'Omega must be a positive finite scalar.');
  assert(isscalar(C) && isfinite(C) && C > 0, ...
    'C must be a positive finite scalar.');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  assert(isscalar(max_windows) && isfinite(max_windows) && max_windows >= 1 && ...
    abs(max_windows-round(max_windows)) <= tol, ...
    'max_windows must be a positive integer.');
  max_windows = round(max_windows);

  p = p(:)';
  x = x(:)';
  n = numel(p);
  assert(n >= 2 && numel(x) == n, ...
    'p and x must have the same length and contain at least two actors.');
  assert(all(isfinite(p)) && all(p >= 0) && abs(sum(p)-1) <= 1e-10, ...
    'p must be a nonnegative probability vector.');
  assert(all(isfinite(x)) && all(x >= 0) && abs(sum(x)-1) <= 1e-10, ...
    'x must be a nonnegative probability vector.');

  w0 = expand_vector(w0,n,'w0',0,1);
  ell = expand_vector(ell,n,'ell',0,1);

  thresholds = Inf(1,n);
  pos = p > 0;
  thresholds(pos) = x(pos)./p(pos);

  finite_breaks = unique(thresholds(isfinite(thresholds) & thresholds > 0 & thresholds < Omega));
  breaks = [0, finite_breaks, Omega];
  breaks = unique(breaks);
  breaks = sort(breaks);

  residual = 1-w0;
  t_total = 0;
  W = mean_W(p,residual);

  F = struct();
  F.T_real = NaN;
  F.T_tilde = C*Omega*max_windows;
  F.delta = 0;
  F.Omega = Omega;
  F.C = C;
  F.max_windows = max_windows;
  F.Theta = Theta;
  F.p = p;
  F.x = x;
  F.w0 = w0;
  F.alpha = alpha;
  F.ell = ell;
  F.exhaustion_thresholds = thresholds;
  F.first_exhaustion_attempt = C*min(thresholds);
  F.n_windows_started = 0;
  F.W_final = W;
  F.w_final = 1-residual;

  if W >= Theta
    F.T_real = 0;
    F.T_tilde = 0;
    F.delta = 1;
    return;
  end

  for window = 1:max_windows
    F.n_windows_started = window;

    for k = 1:(numel(breaks)-1)
      s0 = breaks(k);
      s1 = breaks(k+1);
      dt = C*(s1-s0);
      if dt <= tol
        continue;
      end

      active = pos & (thresholds > s0 + tol);
      q = zeros(1,n);
      q(active) = p(active).*ell(active);
      base = 1-alpha*q;
      assert(all(base >= -tol) && all(base <= 1+tol), ...
        'Assortative mean-learning multiplier left [0,1].');
      base = min(max(base,0),1);

      W_end = mean_W(p,residual.*(base.^dt));
      if W_end >= Theta
        lo = 0;
        hi = dt;
        while (hi-lo) > root_tol
          mid = 0.5*(lo+hi);
          W_mid = mean_W(p,residual.*(base.^mid));
          if W_mid >= Theta
            hi = mid;
          else
            lo = mid;
          end
        end
        residual = residual.*(base.^hi);
        t_total = t_total+hi;
        F.T_real = t_total;
        F.T_tilde = t_total;
        F.delta = 1;
        F.W_final = mean_W(p,residual);
        F.w_final = 1-residual;
        return;
      end

      residual = residual.*(base.^dt);
      t_total = t_total+dt;
      W = W_end;
    end
  end

  F.W_final = mean_W(p,residual);
  F.w_final = 1-residual;
end

function W = mean_W(p,residual)
  W = sum(p.*(1-residual));
end

function v = expand_vector(v,n,name,lower,upper)
  if isscalar(v)
    v = repmat(v,1,n);
  else
    v = v(:)';
  end
  assert(numel(v) == n && all(isfinite(v)) && all(v >= lower) && all(v <= upper), ...
    '%s must be scalar or a vector in [%g,%g] matching p.', name, lower, upper);
end
