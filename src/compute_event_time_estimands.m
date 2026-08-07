function S = compute_event_time_estimands(input_data, delta, quantile_probs)
  % COMPUTE_EVENT_TIME_ESTIMANDS
  % Computes manuscript-facing event-time estimands for administrative
  % right-censored first-passage simulations.
  %
  % Accepted calls:
  %   S = compute_event_time_estimands(results)
  %   S = compute_event_time_estimands(T_tilde, delta)
  %   S = compute_event_time_estimands(T_tilde, delta, quantile_probs)
  %
  % Required semantics:
  %   T        = event time if readiness was reached; NaN otherwise
  %   T_tilde  = observed time; T if event, T_max if censored
  %   delta    = event indicator; 1 if readiness was reached, 0 if censored
  %
  % Main estimands:
  %   RMST                  mean observed time, mean(T_tilde)
  %   readiness_probability mean(delta)
  %   T50/T90/T95           event-time quantiles, only when estimable
  %
  % Quantile rule:
  %   The p-th event-time quantile is estimable only if at least p of the
  %   empirical marginal distribution has observed events before censoring.
  %   With n trajectories, this requires at least ceil(p*n) events. If this
  %   condition is not met, the quantile is returned as NaN and its
  %   estimability flag is zero. This prevents T_max from being reported as
  %   an artificial event time.

  if nargin < 3
    quantile_probs = [0.50; 0.90; 0.95];
  end

  if isstruct(input_data)
    assert(isfield(input_data, 'T_tilde'), ...
      'Results structure must contain T_tilde.');

    assert(isfield(input_data, 'delta'), ...
      'Results structure must contain delta.');

    T_tilde = input_data.T_tilde;
    delta = input_data.delta;

  else
    assert(nargin >= 2, ...
      'Provide either a results structure or T_tilde and delta vectors.');

    T_tilde = input_data;
  end

  validate_inputs(T_tilde, delta, quantile_probs);

  T_tilde = T_tilde(:);
  delta = delta(:);
  quantile_probs = quantile_probs(:);

  n = length(T_tilde);
  n_events = sum(delta == 1);
  n_censored = sum(delta == 0);

  S.n = n;
  S.n_events = n_events;
  S.n_censored = n_censored;

  S.readiness_probability = n_events / n;
  S.censoring_probability = n_censored / n;

  S.RMST = mean(T_tilde);
  S.rmst = S.RMST;

  S.min_observed_time = min(T_tilde);
  S.max_observed_time = max(T_tilde);

  event_times = sort(T_tilde(delta == 1));

  q_values = NaN(length(quantile_probs), 1);
  q_estimable = zeros(length(quantile_probs), 1);
  q_ranks = NaN(length(quantile_probs), 1);

  for j = 1:length(quantile_probs)
    p = quantile_probs(j);
    rank_j = ceil(p * n);

    q_ranks(j) = rank_j;

    if n_events >= rank_j
      q_values(j) = event_times(rank_j);
      q_estimable(j) = 1;
    else
      q_values(j) = NaN;
      q_estimable(j) = 0;
    end

    label = ['T', sprintf('%02d', round(100 * p))];

    S.(label) = q_values(j);
    S.([label, '_estimable']) = q_estimable(j);
    S.([label, '_rank']) = rank_j;
  end

  S.quantile_probs = quantile_probs;
  S.quantile_values = q_values;
  S.quantile_estimable = q_estimable;
  S.quantile_ranks = q_ranks;
end


function validate_inputs(T_tilde, delta, quantile_probs)
  % VALIDATE_INPUTS
  % Defensive checks for event-time estimand inputs.

  assert(isnumeric(T_tilde), 'T_tilde must be numeric.');
  assert(isnumeric(delta), 'delta must be numeric or logical.');
  assert(isnumeric(quantile_probs), 'quantile_probs must be numeric.');

  T_tilde = T_tilde(:);
  delta = delta(:);
  quantile_probs = quantile_probs(:);

  assert(length(T_tilde) == length(delta), ...
    'T_tilde and delta must have the same length.');

  assert(length(T_tilde) > 0, ...
    'T_tilde and delta cannot be empty.');

  assert(all(~isnan(T_tilde)), ...
    'T_tilde cannot contain NaN values.');

  assert(all(isfinite(T_tilde)), ...
    'T_tilde must contain finite values.');

  assert(all(T_tilde >= 0), ...
    'T_tilde must be non-negative.');

  assert(all(delta == 0 | delta == 1), ...
    'delta must contain only zero or one.');

  assert(all(~isnan(quantile_probs)), ...
    'quantile_probs cannot contain NaN values.');

  assert(all(quantile_probs > 0 & quantile_probs < 1), ...
    'quantile_probs must be inside the open interval (0,1).');
end
