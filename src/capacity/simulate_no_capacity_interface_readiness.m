function out = simulate_no_capacity_interface_readiness(pA, pB, w0, alpha, ellA, ellB, Theta, T_max, demand_seed, learning_seed)
% SIMULATE_NO_CAPACITY_INTERFACE_READINESS
% Stochastic first-passage simulator for Model v0.6 with no capacity blocking.
%
% Every attempted pair is admitted. Endpoint demand is sampled under the
% maximum-entropy product closure. Each endpoint independently converts the
% encounter into productive transferable learning using ellA/ellB.
%
% First passage:
%   T = inf{t : min(WA(t),WB(t)) >= Theta}.
%
% T is NaN if censored at T_max; T_tilde=T_max and delta=0 in that case.

  validate_probability_vector(pA, 'pA');
  validate_probability_vector(pB, 'pB');
  nA = numel(pA);
  nB = numel(pB);

  assert(isscalar(w0) && isfinite(w0) && w0 >= 0 && w0 <= 1, ...
    'w0 must be a scalar in [0,1].');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  assert(isscalar(T_max) && isfinite(T_max) && T_max >= 0 && ...
    T_max == floor(T_max), 'T_max must be a nonnegative integer.');

  ellA = expand_probability(ellA, nA, 'ellA');
  ellB = expand_probability(ellB, nB, 'ellB');

  wA = w0 * ones(1, nA);
  wB = w0 * ones(1, nB);
  R0 = continuous_interface_readiness(wA, pA, wB, pB);

  out.T = NaN;
  out.T_tilde = T_max;
  out.delta = 0;
  out.WA = R0.WA;
  out.WB = R0.WB;
  out.Wmin = R0.Wmin;
  out.n_productive_A = 0;
  out.n_productive_B = 0;

  if R0.Wmin >= Theta
    out.T = 0;
    out.T_tilde = 0;
    out.delta = 1;
    return;
  end

  if T_max == 0
    return;
  end

  pairs = generate_max_entropy_demands(T_max, pA, pB, demand_seed);
  ell_events = zeros(T_max, 2);
  for t = 1:T_max
    ell_events(t,1) = ellA(pairs(t,1));
    ell_events(t,2) = ellB(pairs(t,2));
  end
  learn = draw_productive_learning_events(ell_events, learning_seed);

  for t = 1:T_max
    i = pairs(t,1);
    j = pairs(t,2);

    if learn(t,1)
      wA = update_transferable_actor_learning(wA, i, 1, alpha);
      out.n_productive_A = out.n_productive_A + 1;
    end
    if learn(t,2)
      wB = update_transferable_actor_learning(wB, j, 1, alpha);
      out.n_productive_B = out.n_productive_B + 1;
    end

    R = continuous_interface_readiness(wA, pA, wB, pB);
    if R.Wmin >= Theta
      out.T = t;
      out.T_tilde = t;
      out.delta = 1;
      out.WA = R.WA;
      out.WB = R.WB;
      out.Wmin = R.Wmin;
      return;
    end
  end

  R = continuous_interface_readiness(wA, pA, wB, pB);
  out.WA = R.WA;
  out.WB = R.WB;
  out.Wmin = R.Wmin;
end

function validate_probability_vector(p, name)
  assert(isvector(p) && ~isempty(p), '%s must be a nonempty vector.', name);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(p(:)) - 1) <= 1e-10, '%s must sum to one.', name);
end

function v = expand_probability(v, n, name)
  if isscalar(v)
    v = repmat(v, n, 1);
  else
    v = v(:);
  end
  assert(numel(v) == n && all(isfinite(v)) && all(v >= 0) && all(v <= 1), ...
    '%s must be scalar or a probability vector matching its module.', name);
end
