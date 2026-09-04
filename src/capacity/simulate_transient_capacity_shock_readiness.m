function out = simulate_transient_capacity_shock_readiness( ...
    pA, pB, xA, xB, w0, alpha, ellA, ellB, Theta, C, D, max_windows, ...
    gamma, demand_seed, learning_seed)
% SIMULATE_TRANSIENT_CAPACITY_SHOCK_READINESS
% E6 first-passage simulator with one transient capacity-loss window.
%
% Semantics:
%   - Baseline integer capacities are allocated exactly as Model v0.7.
%   - During window 1 only, actor capacity is floor(gamma*c_i).
%   - From window 2 onward, baseline capacities are fully restored.
%   - Demand, admission, learning, readiness and clock semantics are otherwise
%     identical to simulate_capacity_learning_readiness.
%   - Blocked attempts consume no capacity and produce no learning.
%   - Learning states persist through the shock and recovery windows.
%
% Important: componentwise nested shock capacities do NOT imply nested
% admitted-pair sets because admission consumes capacity at both endpoints.
% E6 therefore imposes no pathwise monotonicity of first-passage time in gamma.

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
  assert(isscalar(gamma) && isfinite(gamma) && gamma >= 0 && gamma <= 1, ...
    'gamma must lie in [0,1].');

  validate_positive_integer(C, 'C', tol);
  validate_positive_integer(D, 'D', tol);
  validate_positive_integer(max_windows, 'max_windows', tol);
  validate_nonnegative_integer(demand_seed, 'demand_seed', tol);
  validate_nonnegative_integer(learning_seed, 'learning_seed', tol);

  C = round(C);
  D = round(D);
  max_windows = round(max_windows);
  demand_seed = round(demand_seed);
  learning_seed = round(learning_seed);

  nA = numel(pA);
  nB = numel(pB);
  ellA = expand_probability(ellA, nA, 'ellA');
  ellB = expand_probability(ellB, nB, 'ellB');

  [cA, xA_realized] = allocate_integer_capacity(C, xA);
  [cB, xB_realized] = allocate_integer_capacity(C, xB);
  [cA_shock, gamma_real_A] = transient_shock_capacity(cA, gamma);
  [cB_shock, gamma_real_B] = transient_shock_capacity(cB, gamma);

  T_max = D * max_windows;
  pairs = generate_max_entropy_demands(T_max, pA, pB, demand_seed);

  ell_events = zeros(T_max, 2);
  ell_events(:,1) = ellA(pairs(:,1));
  ell_events(:,2) = ellB(pairs(:,2));
  learning_marks = draw_productive_learning_events(ell_events, learning_seed);

  wA = w0 * ones(1, nA);
  wB = w0 * ones(1, nB);
  R = continuous_interface_readiness(wA, pA, wB, pB);

  out = initialize_output(pA, pB, xA, xB, xA_realized, xB_realized, ...
    cA, cB, cA_shock, cB_shock, gamma, gamma_real_A, gamma_real_B, ...
    C, D, max_windows, T_max, demand_seed, learning_seed, R);

  if R.Wmin >= Theta
    out.T = 0;
    out.T_tilde = 0;
    out.delta = 1;
    out.wA = wA;
    out.wB = wB;
    return;
  end

  remainingA = cA_shock(:)';
  remainingB = cB_shock(:)';

  for t = 1:T_max
    if mod(t-1, D) == 0
      window_idx = floor((t-1)/D) + 1;
      out.n_windows_started = out.n_windows_started + 1;
      if window_idx == 1
        remainingA = cA_shock(:)';
        remainingB = cB_shock(:)';
      else
        remainingA = cA(:)';
        remainingB = cB(:)';
      end
    else
      window_idx = floor((t-1)/D) + 1;
    end

    in_shock_window = (window_idx == 1);
    i = pairs(t,1);
    j = pairs(t,2);

    out.n_attempted = out.n_attempted + 1;
    if in_shock_window
      out.n_attempted_shock = out.n_attempted_shock + 1;
    end

    if remainingA(i) > 0 && remainingB(j) > 0
      out.n_served = out.n_served + 1;
      if in_shock_window
        out.n_served_shock = out.n_served_shock + 1;
      end

      remainingA(i) = remainingA(i) - 1;
      remainingB(j) = remainingB(j) - 1;

      if learning_marks(t,1)
        wA = update_transferable_actor_learning(wA, i, 1, alpha);
        out.n_productive_A = out.n_productive_A + 1;
        if in_shock_window
          out.n_productive_A_shock = out.n_productive_A_shock + 1;
        end
      end
      if learning_marks(t,2)
        wB = update_transferable_actor_learning(wB, j, 1, alpha);
        out.n_productive_B = out.n_productive_B + 1;
        if in_shock_window
          out.n_productive_B_shock = out.n_productive_B_shock + 1;
        end
      end
    else
      out.n_blocked = out.n_blocked + 1;
      if isnan(out.first_block_attempt)
        out.first_block_attempt = t;
      end
      if in_shock_window
        out.n_blocked_shock = out.n_blocked_shock + 1;
        if isnan(out.first_block_attempt_shock)
          out.first_block_attempt_shock = t;
        end
      end
    end

    R = continuous_interface_readiness(wA, pA, wB, pB);
    if R.Wmin >= Theta
      out.T = t;
      out.T_tilde = t;
      out.delta = 1;
      out.WA = R.WA;
      out.WB = R.WB;
      out.Wmin = R.Wmin;
      out.Wpair = R.Wpair;
      out.wA = wA;
      out.wB = wB;
      out.remaining_capacity_A = remainingA;
      out.remaining_capacity_B = remainingB;
      out.blocked_fraction = out.n_blocked / out.n_attempted;
      if out.n_attempted_shock > 0
        out.shock_blocked_fraction = out.n_blocked_shock / out.n_attempted_shock;
      end
      return;
    end
  end

  out.WA = R.WA;
  out.WB = R.WB;
  out.Wmin = R.Wmin;
  out.Wpair = R.Wpair;
  out.wA = wA;
  out.wB = wB;
  out.remaining_capacity_A = remainingA;
  out.remaining_capacity_B = remainingB;
  out.blocked_fraction = out.n_blocked / out.n_attempted;
  if out.n_attempted_shock > 0
    out.shock_blocked_fraction = out.n_blocked_shock / out.n_attempted_shock;
  end
end

function out = initialize_output(pA, pB, xA, xB, xA_realized, xB_realized, ...
    cA, cB, cA_shock, cB_shock, gamma, gamma_real_A, gamma_real_B, ...
    C, D, max_windows, T_max, demand_seed, learning_seed, R)
  out = struct();
  out.T = NaN;
  out.T_tilde = T_max;
  out.delta = 0;
  out.C = C;
  out.D = D;
  out.Omega_realized = D/C;
  out.max_windows = max_windows;
  out.T_max = T_max;
  out.gamma_target = gamma;
  out.gamma_real_A = gamma_real_A;
  out.gamma_real_B = gamma_real_B;
  out.pA = pA(:)';
  out.pB = pB(:)';
  out.xA_target = xA(:)';
  out.xB_target = xB(:)';
  out.xA_realized = xA_realized(:)';
  out.xB_realized = xB_realized(:)';
  out.cA = cA(:)';
  out.cB = cB(:)';
  out.cA_shock = cA_shock(:)';
  out.cB_shock = cB_shock(:)';
  out.demand_seed = demand_seed;
  out.learning_seed = learning_seed;
  out.n_windows_started = 0;
  out.n_attempted = 0;
  out.n_served = 0;
  out.n_blocked = 0;
  out.blocked_fraction = 0;
  out.first_block_attempt = NaN;
  out.n_attempted_shock = 0;
  out.n_served_shock = 0;
  out.n_blocked_shock = 0;
  out.shock_blocked_fraction = 0;
  out.first_block_attempt_shock = NaN;
  out.n_productive_A = 0;
  out.n_productive_B = 0;
  out.n_productive_A_shock = 0;
  out.n_productive_B_shock = 0;
  out.WA = R.WA;
  out.WB = R.WB;
  out.Wmin = R.Wmin;
  out.Wpair = R.Wpair;
  out.wA = [];
  out.wB = [];
  out.remaining_capacity_A = cA_shock(:)';
  out.remaining_capacity_B = cB_shock(:)';
end

function validate_probability_vector(v, name)
  assert(isvector(v) && ~isempty(v), '%s must be a nonempty vector.', name);
  assert(all(isfinite(v(:))) && all(v(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(v(:)) - 1) <= 1e-10, '%s must sum to one.', name);
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

function validate_positive_integer(v, name, tol)
  assert(isscalar(v) && isfinite(v) && v > 0 && abs(v-round(v)) <= tol, ...
    '%s must be a positive integer.', name);
end

function validate_nonnegative_integer(v, name, tol)
  assert(isscalar(v) && isfinite(v) && v >= 0 && abs(v-round(v)) <= tol, ...
    '%s must be a nonnegative integer.', name);
end
