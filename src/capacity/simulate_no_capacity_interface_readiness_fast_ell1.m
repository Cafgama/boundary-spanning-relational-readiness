function out = simulate_no_capacity_interface_readiness_fast_ell1(pA, pB, w0, alpha, Theta, T_max, demand_seed)
% SIMULATE_NO_CAPACITY_INTERFACE_READINESS_FAST_ELL1
% Exact fast-path for Model v0.6 when ellA=ellB=1 and there is no blocking.
%
% After N_i productive encounters,
%   w_i = 1 - (1-w0)*(1-alpha)^N_i.
%
% Therefore the sequential actor-state updates can be replaced exactly by
% exposure counts while preserving the same first-passage rule. This function
% is an optimization only; the transparent generic simulator remains the
% reference implementation.

  validate_probability_vector(pA, 'pA');
  validate_probability_vector(pB, 'pB');
  assert(isscalar(w0) && isfinite(w0) && w0 >= 0 && w0 <= 1, ...
    'w0 must lie in [0,1].');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  assert(isscalar(T_max) && isfinite(T_max) && T_max >= 0 && ...
    T_max == floor(T_max), 'T_max must be a nonnegative integer.');

  pA = pA(:)';
  pB = pB(:)';
  countA = zeros(size(pA));
  countB = zeros(size(pB));
  r = 1-alpha;

  WA = w0;
  WB = w0;
  out.T = NaN;
  out.T_tilde = T_max;
  out.delta = 0;
  out.TA = NaN;
  out.TB = NaN;

  if WA >= Theta
    out.TA = 0;
    out.TB = 0;
    out.T = 0;
    out.T_tilde = 0;
    out.delta = 1;
  end

  if out.delta == 0 && T_max > 0
    pairs = generate_max_entropy_demands(T_max, pA, pB, demand_seed);

    for t = 1:T_max
      countA(pairs(t,1)) = countA(pairs(t,1)) + 1;
      countB(pairs(t,2)) = countB(pairs(t,2)) + 1;

      wA = 1 - (1-w0) .* (r .^ countA);
      wB = 1 - (1-w0) .* (r .^ countB);
      WA = sum(pA .* wA);
      WB = sum(pB .* wB);

      if isnan(out.TA) && WA >= Theta
        out.TA = t;
      end
      if isnan(out.TB) && WB >= Theta
        out.TB = t;
      end

      if ~isnan(out.TA) && ~isnan(out.TB)
        out.T = t;
        out.T_tilde = t;
        out.delta = 1;
        break;
      end
    end
  end

  if ~exist('wA', 'var')
    wA = w0 * ones(size(pA));
    wB = w0 * ones(size(pB));
  end
  out.WA = sum(pA .* wA);
  out.WB = sum(pB .* wB);
  out.Wmin = min(out.WA, out.WB);
  out.n_productive_A = sum(countA);
  out.n_productive_B = sum(countB);
end

function validate_probability_vector(p, name)
  assert(isvector(p) && ~isempty(p), '%s must be a nonempty vector.', name);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(p(:)) - 1) <= 1e-10, '%s must sum to one.', name);
end
