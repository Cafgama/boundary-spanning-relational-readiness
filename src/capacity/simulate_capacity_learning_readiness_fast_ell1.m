function out = simulate_capacity_learning_readiness_fast_ell1(pA, pB, xA, xB, w0, alpha, Theta, C, D, max_windows, demand_seed)
% SIMULATE_CAPACITY_LEARNING_READINESS_FAST_ELL1
% Exact fast-path for Model v0.7 when ellA=ellB=1.
%
% The admission semantics and capacity resets are identical to
% simulate_capacity_learning_readiness. Because every served interaction is
% productive when ell=1, actor states can be reconstructed exactly from the
% number of served exposures:
%
%   w_i = 1 - (1-w0)*(1-alpha)^N_i.
%
% This is an optimization only. The generic simulator is the reference model.

  tol = 1e-12;
  validate_probability_vector(pA, 'pA');
  validate_probability_vector(pB, 'pB');
  validate_probability_vector(xA, 'xA');
  validate_probability_vector(xB, 'xB');
  assert(numel(pA) == numel(xA), 'pA and xA must have equal length.');
  assert(numel(pB) == numel(xB), 'pB and xB must have equal length.');
  assert(numel(pA) >= 2 && numel(pB) >= 2, ...
    'Each module must contain at least two interface-capable actors.');
  assert(isscalar(w0) && isfinite(w0) && w0 >= 0 && w0 <= 1, ...
    'w0 must lie in [0,1].');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  validate_positive_integer(C, 'C', tol);
  validate_positive_integer(D, 'D', tol);
  validate_positive_integer(max_windows, 'max_windows', tol);
  validate_nonnegative_integer(demand_seed, 'demand_seed', tol);

  C = round(C);
  D = round(D);
  max_windows = round(max_windows);
  demand_seed = round(demand_seed);

  pA = pA(:)';
  pB = pB(:)';
  [cA, xA_realized] = allocate_integer_capacity(C, xA);
  [cB, xB_realized] = allocate_integer_capacity(C, xB);
  MA = capacity_load_metrics(D, C, pA, xA_realized);
  MB = capacity_load_metrics(D, C, pB, xB_realized);

  T_max = D * max_windows;
  pairs = generate_max_entropy_demands(T_max, pA, pB, demand_seed);

  countA = zeros(size(pA));
  countB = zeros(size(pB));
  r = 1-alpha;
  wA = w0 * ones(size(pA));
  wB = w0 * ones(size(pB));
  WA = w0;
  WB = w0;

  out = struct();
  out.T = NaN;
  out.T_tilde = T_max;
  out.delta = 0;
  out.C = C;
  out.D = D;
  out.max_windows = max_windows;
  out.T_max = T_max;
  out.Omega_realized = D/C;
  out.Lambda_realized = max(MA.Lambda, MB.Lambda);
  out.chi_realized = out.Omega_realized * out.Lambda_realized;
  out.H_A = MA.H;
  out.H_B = MB.H;
  out.xA_realized = xA_realized(:)';
  out.xB_realized = xB_realized(:)';
  out.cA = cA(:)';
  out.cB = cB(:)';
  out.demand_seed = demand_seed;
  out.n_windows_started = 0;
  out.n_attempted = 0;
  out.n_served = 0;
  out.n_blocked = 0;
  out.blocked_fraction = 0;
  out.first_block_attempt = NaN;
  out.n_productive_A = 0;
  out.n_productive_B = 0;
  out.WA = WA;
  out.WB = WB;
  out.Wmin = min(WA,WB);
  out.Wpair = WA*WB;

  if out.Wmin >= Theta
    out.T = 0;
    out.T_tilde = 0;
    out.delta = 1;
    return;
  end

  remainingA = cA(:)';
  remainingB = cB(:)';

  for t = 1:T_max
    if mod(t-1,D) == 0
      remainingA = cA(:)';
      remainingB = cB(:)';
      out.n_windows_started = out.n_windows_started + 1;
    end

    i = pairs(t,1);
    j = pairs(t,2);
    out.n_attempted = out.n_attempted + 1;

    if remainingA(i) > 0 && remainingB(j) > 0
      remainingA(i) = remainingA(i)-1;
      remainingB(j) = remainingB(j)-1;
      out.n_served = out.n_served + 1;
      countA(i) = countA(i)+1;
      countB(j) = countB(j)+1;

      wA(i) = 1 - (1-w0) * r^countA(i);
      wB(j) = 1 - (1-w0) * r^countB(j);
      WA = sum(pA .* wA);
      WB = sum(pB .* wB);
    else
      out.n_blocked = out.n_blocked + 1;
      if isnan(out.first_block_attempt)
        out.first_block_attempt = t;
      end
    end

    if min(WA,WB) >= Theta
      out.T = t;
      out.T_tilde = t;
      out.delta = 1;
      break;
    end
  end

  out.n_productive_A = sum(countA);
  out.n_productive_B = sum(countB);
  out.WA = WA;
  out.WB = WB;
  out.Wmin = min(WA,WB);
  out.Wpair = WA*WB;
  if out.n_attempted > 0
    out.blocked_fraction = out.n_blocked/out.n_attempted;
  end
  out.wA = wA;
  out.wB = wB;
  out.remaining_capacity_A = remainingA;
  out.remaining_capacity_B = remainingB;
end

function validate_probability_vector(v, name)
  assert(isvector(v) && ~isempty(v), '%s must be a nonempty vector.', name);
  assert(all(isfinite(v(:))) && all(v(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(v(:))-1) <= 1e-10, '%s must sum to one.', name);
end

function validate_positive_integer(v, name, tol)
  assert(isscalar(v) && isfinite(v) && v > 0 && abs(v-round(v)) <= tol, ...
    '%s must be a positive integer.', name);
end

function validate_nonnegative_integer(v, name, tol)
  assert(isscalar(v) && isfinite(v) && v >= 0 && abs(v-round(v)) <= tol, ...
    '%s must be a nonnegative integer.', name);
end
