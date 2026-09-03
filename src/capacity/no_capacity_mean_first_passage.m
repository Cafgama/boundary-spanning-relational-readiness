function F = no_capacity_mean_first_passage(p, w0, alpha, ell, Theta, T_max)
% NO_CAPACITY_MEAN_FIRST_PASSAGE
% First integer attempt count at which exact mean module readiness reaches Theta.
%
% This is a first-moment benchmark, not E[first-passage time] of the stochastic
% process. It is used as the pre-simulation analytical reference for E2.

  assert(isscalar(Theta) && isfinite(Theta) && Theta > 0 && Theta < 1, ...
    'Theta must lie in (0,1).');
  assert(isscalar(T_max) && isfinite(T_max) && T_max >= 0 && ...
    T_max == floor(T_max), 'T_max must be a nonnegative integer.');

  M = no_capacity_mean_readiness(0:T_max, p, w0, alpha, ell);
  idx = find(M.Wmean >= Theta, 1, 'first');

  if isempty(idx)
    F.T_mean_cross = NaN;
    F.delta = 0;
    F.W_at_cross = M.Wmean(end);
  else
    F.T_mean_cross = idx - 1;
    F.delta = 1;
    F.W_at_cross = M.Wmean(idx);
  end

  F.Theta = Theta;
  F.T_max = T_max;
end
