function S = fluid_active_segments_symmetric(Omega, p, x)
% FLUID_ACTIVE_SEGMENTS_SYMMETRIC
% Piecewise-constant active-set schedule for the symmetric fluid admission model.
%
% Scaled attempted time is s=t/C. Under maximum-entropy pairing,
% du/ds=A(s), where A is the active responsibility mass. The active set changes
% only when an actor reaches its exposure threshold r_i=x_i/p_i.

  tol = 1e-12;

  assert(isscalar(Omega) && isfinite(Omega) && Omega > 0, ...
    'Omega must be a positive finite scalar.');

  p = p(:)';
  x = x(:)';
  assert(numel(p) == numel(x) && numel(p) >= 2, ...
    'p and x must have the same length and contain at least two actors.');
  assert(all(isfinite(p)) && all(p >= 0) && abs(sum(p)-1) <= 1e-10, ...
    'p must be a nonnegative probability vector.');
  assert(all(isfinite(x)) && all(x >= 0) && abs(sum(x)-1) <= 1e-10, ...
    'x must be a nonnegative probability vector.');

  n = numel(p);
  r = Inf(1,n);
  positive = p > 0;
  r(positive) = x(positive) ./ p(positive);

  active = positive & (r > tol);
  A = sum(p(active));
  u = 0;
  s = 0;

  starts = [];
  ends = [];
  masses = [];
  masks = {};

  while s < Omega - tol
    if A <= tol
      starts(end+1) = s; %#ok<AGROW>
      ends(end+1) = Omega; %#ok<AGROW>
      masses(end+1) = 0; %#ok<AGROW>
      masks{end+1} = active; %#ok<AGROW>
      s = Omega;
      break;
    end

    next_r = min(r(active));
    du = next_r-u;
    if du < 0 && abs(du) <= tol
      du = 0;
    end
    assert(du >= 0, 'Fluid threshold ordering failed.');
    ds = du/A;

    if s + ds >= Omega - tol
      starts(end+1) = s; %#ok<AGROW>
      ends(end+1) = Omega; %#ok<AGROW>
      masses(end+1) = A; %#ok<AGROW>
      masks{end+1} = active; %#ok<AGROW>
      u = u + A*(Omega-s);
      s = Omega;
      break;
    end

    if ds > tol
      starts(end+1) = s; %#ok<AGROW>
      ends(end+1) = s+ds; %#ok<AGROW>
      masses(end+1) = A; %#ok<AGROW>
      masks{end+1} = active; %#ok<AGROW>
    end

    s = s+ds;
    u = next_r;
    exhausting = active & (r <= u+tol);
    active(exhausting) = false;
    A = sum(p(active));
  end

  S = struct();
  S.Omega = Omega;
  S.p = p;
  S.x = x;
  S.r = r;
  S.s_start = starts;
  S.s_end = ends;
  S.A = masses;
  S.active_masks = masks;
  S.n_segments = numel(starts);

  if any(positive)
    S.first_exhaustion_s = min(r(positive));
  else
    S.first_exhaustion_s = Inf;
  end
end
