function [c_shock, gamma_real] = transient_shock_capacity(c_baseline, gamma)
% TRANSIENT_SHOCK_CAPACITY
% Deterministic integer capacity reduction for the first E6 shock window.
%
% For baseline integer actor capacities c_i and retained-capacity fraction
% gamma in [0,1], define
%
%   c_i^shock = floor(gamma * c_i).
%
% The function preserves the input shape. gamma_real is the realized total
% retained module capacity divided by the baseline total capacity.

  tol = 1e-12;

  assert(isvector(c_baseline) && ~isempty(c_baseline), ...
    'c_baseline must be a nonempty vector.');
  assert(all(isfinite(c_baseline(:))) && all(c_baseline(:) >= 0), ...
    'c_baseline must contain finite nonnegative values.');
  assert(all(abs(c_baseline(:) - round(c_baseline(:))) <= tol), ...
    'c_baseline must contain integer capacities.');
  assert(isscalar(gamma) && isfinite(gamma) && gamma >= 0 && gamma <= 1, ...
    'gamma must lie in [0,1].');

  c_baseline = round(c_baseline);
  c_shock = floor(gamma .* c_baseline);

  C = sum(c_baseline(:));
  if C > 0
    gamma_real = sum(c_shock(:)) / C;
  else
    gamma_real = 0;
  end

  assert(all(c_shock(:) >= 0), ...
    'Shock capacity produced a negative actor capacity.');
  assert(all(c_shock(:) <= c_baseline(:)), ...
    'Shock capacity cannot exceed baseline capacity.');
end
