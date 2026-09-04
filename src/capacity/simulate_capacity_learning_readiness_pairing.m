function out = simulate_capacity_learning_readiness_pairing(pA, pB, xA, xB, w0, alpha, ellA, ellB, Theta, C, D, max_windows, demand_seed, learning_seed, pairing_mode)
% SIMULATE_CAPACITY_LEARNING_READINESS_PAIRING
% E7 robustness wrapper for the validated v0.7 capacity-learning dynamics.
%
% The dynamics are unchanged. Only the demand-pair generator varies between
% the frozen E7 modes 'product' and 'assortative'.

  if nargin < 15 || isempty(pairing_mode)
    pairing_mode = 'product';
  end

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
  MA = capacity_load_metrics(D, C, pA, xA_realized);
  MB = capacity_load_metrics(D, C, pB, xB_realized);

  T_max = D * max_windows;
  pairs = generate_pairing_demands(T_max, pA, pB, demand_seed, pairing_mode);

  ell_events = zeros(T_max,2);
  ell_events(:,1) = ellA(pairs(:,1));
  ell_events(:,2) = ellB(pairs(:,2));
  learning_marks = draw_productive_learning_events(ell_events, learning_seed);

  wA = w0 * ones(1,nA);
  wB = w0 * ones(1,nB);
  R = continuous_interface_readiness(wA,pA,wB,pB);

  out = initialize_output(C,D,max_windows,T_max,pA,pB,xA,xB, ...
    xA_realized,xB_realized,cA,cB,MA,MB,demand_seed,learning_seed,R,pairing_mode);

  if R.Wmin >= Theta
    out.T = 0;
    out.T_tilde = 0;
    out.delta = 1;
    out.wA = wA;
    out.wB = wB;
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
      out.n_served = out.n_served + 1;
      remainingA(i) = remainingA(i)-1;
      remainingB(j) = remainingB(j)-1;

      if learning_marks(t,1)
        wA = update_transferable_actor_learning(wA,i,1,alpha);
        out.n_productive_A = out.n_productive_A + 1;
      end
      if learning_marks(t,2)
        wB = update_transferable_actor_learning(wB,j,1,alpha);
        out.n_productive_B = out.n_productive_B + 1;
      end
    else
      out.n_blocked = out.n_blocked + 1;
      if isnan(out.first_block_attempt)
        out.first_block_attempt = t;
      end
    end

    R = continuous_interface_readiness(wA,pA,wB,pB);
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
      out.blocked_fraction = out.n_blocked/out.n_attempted;
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
  out.blocked_fraction = out.n_blocked/out.n_attempted;
end

function out = initialize_output(C,D,max_windows,T_max,pA,pB,xA,xB, ...
    xA_realized,xB_realized,cA,cB,MA,MB,demand_seed,learning_seed,R,pairing_mode)
  out = struct();
  out.T = NaN;
  out.T_tilde = T_max;
  out.delta = 0;
  out.C = C;
  out.D = D;
  out.max_windows = max_windows;
  out.T_max = T_max;
  out.Omega_realized = D/C;
  out.Lambda_realized = max(MA.Lambda,MB.Lambda);
  out.chi_realized = out.Omega_realized*out.Lambda_realized;
  out.H_A = MA.H;
  out.H_B = MB.H;
  out.pA = pA(:)';
  out.pB = pB(:)';
  out.xA_target = xA(:)';
  out.xB_target = xB(:)';
  out.xA_realized = xA_realized(:)';
  out.xB_realized = xB_realized(:)';
  out.cA = cA(:)';
  out.cB = cB(:)';
  out.demand_seed = demand_seed;
  out.learning_seed = learning_seed;
  out.pairing_mode = pairing_mode;
  out.n_windows_started = 0;
  out.n_attempted = 0;
  out.n_served = 0;
  out.n_blocked = 0;
  out.blocked_fraction = 0;
  out.first_block_attempt = NaN;
  out.n_productive_A = 0;
  out.n_productive_B = 0;
  out.WA = R.WA;
  out.WB = R.WB;
  out.Wmin = R.Wmin;
  out.Wpair = R.Wpair;
  out.wA = [];
  out.wB = [];
  out.remaining_capacity_A = cA(:)';
  out.remaining_capacity_B = cB(:)';
end

function validate_probability_vector(v,name)
  assert(isvector(v) && ~isempty(v), '%s must be a nonempty vector.', name);
  assert(all(isfinite(v(:))) && all(v(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(abs(sum(v(:))-1) <= 1e-10, '%s must sum to one.', name);
end

function v = expand_probability(v,n,name)
  if isscalar(v)
    v = repmat(v,n,1);
  else
    v = v(:);
  end
  assert(numel(v) == n && all(isfinite(v)) && all(v >= 0) && all(v <= 1), ...
    '%s must be scalar or a probability vector matching its module.', name);
end

function validate_positive_integer(v,name,tol)
  assert(isscalar(v) && isfinite(v) && v > 0 && abs(v-round(v)) <= tol, ...
    '%s must be a positive integer.', name);
end

function validate_nonnegative_integer(v,name,tol)
  assert(isscalar(v) && isfinite(v) && v >= 0 && abs(v-round(v)) <= tol, ...
    '%s must be a nonnegative integer.', name);
end
