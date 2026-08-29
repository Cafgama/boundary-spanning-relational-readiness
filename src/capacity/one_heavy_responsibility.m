function p = one_heavy_responsibility(n, h)
% ONE_HEAVY_RESPONSIBILITY Minimal one-parameter concentration family.
%
% p_1     = [1 + (n-1)h]/n
% p_i>1   = (1-h)/n
%
% h=0 gives uniform responsibility; h=1 gives complete concentration.

  assert(isscalar(n) && isfinite(n) && n == floor(n) && n >= 2, ...
    'n must be an integer >= 2.');
  assert(isscalar(h) && isfinite(h) && h >= 0 && h <= 1, ...
    'h must lie in [0,1].');

  p = ((1 - h) / n) * ones(1, n);
  p(1) = (1 + (n - 1) * h) / n;
end
