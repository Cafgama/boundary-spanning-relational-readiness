function F = fluid_capacity_symmetric(Omega, p, x)
  % FLUID_CAPACITY_SYMMETRIC
  % Piecewise-exact fluid-limit admission solution for two symmetric modules
  % under maximum-entropy endpoint pairing.
  %
  % Both modules share responsibility shares p and capacity shares x.
  % Scaled attempt time is s=t/C, so the capacity window ends at s=Omega.

  tol = 1e-12;

  assert(isscalar(Omega) && isfinite(Omega) && Omega > 0, ...
    'Omega must be a positive finite scalar.');

  p = p(:)';
  x = x(:)';

  assert(length(p) == length(x) && length(p) >= 2, ...
    'p and x must have the same length and contain at least two actors.');
  assert(all(isfinite(p)) && all(p >= 0), ...
    'p must contain finite nonnegative shares.');
  assert(all(isfinite(x)) && all(x >= 0), ...
    'x must contain finite nonnegative shares.');
  assert(abs(sum(p) - 1) <= 1e-10, 'p must sum to one.');
  assert(abs(sum(x) - 1) <= 1e-10, 'x must sum to one.');

  n = length(p);
  r = Inf(1, n);
  positive_demand = p > 0;
  r(positive_demand) = x(positive_demand) ./ p(positive_demand);

  local_ratio = zeros(1, n);
  finite_capacity = positive_demand & (x > 0);
  zero_capacity = positive_demand & (x == 0);
  local_ratio(finite_capacity) = p(finite_capacity) ./ x(finite_capacity);
  local_ratio(zero_capacity) = Inf;
  Lambda = max(local_ratio);
  chi = Omega * Lambda;

  if any(zero_capacity)
    onset_s = 0;
  else
    onset_s = min(r(positive_demand));
  end

  % Actors with r=0 have no usable capacity and are inactive immediately.
  active = positive_demand & (r > tol);
  A = sum(p(active));
  u = 0;
  s = 0;
  exhaustion_u = [];
  exhaustion_s = [];

  while s < Omega - tol && A > tol
    next_r = min(r(active));
    du = next_r - u;
    if du < 0 && abs(du) <= tol
      du = 0;
    end
    assert(du >= 0, 'Fluid threshold ordering failed.');

    ds = du / A;

    if s + ds >= Omega - tol
      u = u + A * (Omega - s);
      s = Omega;
      break;
    end

    s = s + ds;
    u = next_r;
    exhausting = active & (r <= u + tol);
    exhaustion_u(end+1) = u; %#ok<AGROW>
    exhaustion_s(end+1) = s; %#ok<AGROW>
    active(exhausting) = false;
    A = sum(p(active));
  end

  used = min(x, p .* u);
  used = max(used, 0);
  used_total = sum(used);

  served_fraction = used_total / Omega;
  served_fraction = min(max(served_fraction, 0), 1);
  blocked_fraction = 1 - served_fraction;

  remaining = x - used;
  remaining(abs(remaining) < tol) = 0;

  F = struct();
  F.Omega = Omega;
  F.p = p;
  F.x = x;
  F.r = r;
  F.Lambda = Lambda;
  F.chi = chi;
  F.onset_s = onset_s;
  F.u_final = u;
  F.s_final = s;
  F.used_capacity_share = used;
  F.remaining_capacity_share = remaining;
  F.used_total = used_total;
  F.served_fraction = served_fraction;
  F.blocked_fraction = blocked_fraction;
  F.exhaustion_u = exhaustion_u;
  F.exhaustion_s = exhaustion_s;
end
