function M = relational_service_metrics(pi_value, alpha, beta, w0, theta)
% RELATIONAL_SERVICE_METRICS Mean-field service requirement per admitted interaction.
%
% Retains the validated relational update law:
%   success: w' = w + alpha(1-w)
%   failure: w' = (1-beta)w
%
% The function returns analytical quantities only. It performs no simulation.

  assert(isscalar(pi_value) && isfinite(pi_value) && ...
    pi_value >= 0 && pi_value <= 1, ...
    'pi must lie in [0,1].');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');
  assert(isscalar(beta) && isfinite(beta) && beta >= 0 && beta <= 1, ...
    'beta must lie in [0,1].');
  assert(isscalar(w0) && isfinite(w0) && w0 >= 0 && w0 <= 1, ...
    'w0 must lie in [0,1].');
  assert(isscalar(theta) && isfinite(theta) && theta > 0 && theta <= 1, ...
    'theta must lie in (0,1].');
  assert(w0 < theta, ...
    'Model v0.1 service requirement assumes w0 < theta.');

  kappa = alpha * pi_value + beta * (1 - pi_value);

  if kappa == 0
    w_star = w0;
  else
    w_star = alpha * pi_value / kappa;
  end

  denom_pi_c = alpha * (1 - theta) + theta * beta;
  if denom_pi_c == 0
    pi_c = 0;
  else
    pi_c = theta * beta / denom_pi_c;
  end

  feasible = (w_star > theta);

  if feasible
    contraction = 1 - kappa;

    if contraction == 0
      % Mean state jumps to w_star in one admitted interaction.
      s_theta = 1;
    else
      numerator = log((w_star - theta) / (w_star - w0));
      denominator = log(contraction);
      s_theta = numerator / denominator;
    end
  else
    s_theta = Inf;
  end

  M = struct();
  M.kappa = kappa;
  M.w_star = w_star;
  M.pi_c = pi_c;
  M.feasible = feasible;
  M.s_theta = s_theta;
end
