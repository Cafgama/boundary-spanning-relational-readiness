function M = negative_binomial_learning_metrics(K, ell)
% NEGATIVE_BINOMIAL_LEARNING_METRICS
% Analytical service requirement for K productive learning events.
%
% If each admitted interaction independently produces useful learning with
% probability ell, the number N of admitted interactions required to obtain
% K productive events follows a negative-binomial stopping-time law:
%
%   E[N]   = K/ell
%   Var[N] = K(1-ell)/ell^2
%
% ell may be scalar or an array. ell=0 yields Inf moments.

  tol = 1e-12;

  assert(isscalar(K) && isfinite(K) && K >= 1, ...
    'K must be a positive finite scalar.');
  assert(abs(K - round(K)) <= tol, ...
    'K must be an integer number of productive events.');
  assert(~isempty(ell), 'ell must be nonempty.');
  assert(all(isfinite(ell(:))) && all(ell(:) >= 0) && all(ell(:) <= 1), ...
    'ell entries must be finite probabilities in [0,1].');

  K = round(K);
  mean_N = Inf(size(ell));
  var_N = Inf(size(ell));

  positive = (ell > 0);
  mean_N(positive) = K ./ ell(positive);
  var_N(positive) = K .* (1 - ell(positive)) ./ (ell(positive) .^ 2);

  M = struct();
  M.K = K;
  M.ell = ell;
  M.mean_admitted = mean_N;
  M.var_admitted = var_N;
  M.sd_admitted = sqrt(var_N);
end
