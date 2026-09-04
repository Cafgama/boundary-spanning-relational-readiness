function [c_shock, gamma_real] = transient_shock_capacity(c_baseline, gamma)
% TRANSIENT_SHOCK_CAPACITY
% Deterministic E6 reduction of total integer capacity while preserving the
% baseline allocation shares as closely as possible.
%
% Let baseline integer capacities sum to C and define baseline realized
% shares x_i = c_i/C. E6 uses shock levels for which gamma*C is an integer.
% The shock window retains exactly
%
%   C_shock = gamma*C
%
% total units, allocated across actors by the same largest-remainder rule
% used by the baseline model with target shares x.
%
% This keeps shock severity identical at module level across architectures.
% Actor-level shares can differ slightly from x because of finite integer
% apportionment; the exact realized vector is therefore stored by the caller.

  tol = 1e-12;

  assert(isvector(c_baseline) && ~isempty(c_baseline), ...
    'c_baseline must be a nonempty vector.');
  assert(all(isfinite(c_baseline(:))) && all(c_baseline(:) >= 0), ...
    'c_baseline must contain finite nonnegative values.');
  assert(all(abs(c_baseline(:) - round(c_baseline(:))) <= tol), ...
    'c_baseline must contain integer capacities.');
  assert(isscalar(gamma) && isfinite(gamma) && gamma >= 0 && gamma <= 1, ...
    'gamma must lie in [0,1].');

  original_size = size(c_baseline);
  c_row = round(c_baseline(:)');
  C = sum(c_row);

  if C == 0
    c_shock = zeros(original_size);
    gamma_real = 0;
    return;
  end

  C_shock_raw = gamma * C;
  assert(abs(C_shock_raw - round(C_shock_raw)) <= tol, ...
    'E6 requires gamma*C to be an integer retained total capacity.');
  C_shock = round(C_shock_raw);

  x_baseline = c_row ./ C;
  [c_shock_row, ~] = allocate_integer_capacity(C_shock, x_baseline);
  c_shock = reshape(c_shock_row, original_size);
  gamma_real = sum(c_shock(:)) / C;

  assert(sum(c_shock(:)) == C_shock, ...
    'Shock allocation failed to conserve retained total capacity.');
  assert(abs(gamma_real-gamma) <= tol, ...
    'Realized module-level shock severity differs from gamma.');
  assert(all(c_shock(:) >= 0), ...
    'Shock capacity produced a negative actor capacity.');
  assert(all(c_shock(:) <= c_baseline(:)), ...
    'Shock actor capacity cannot exceed baseline capacity in the E6 grid.');
end
