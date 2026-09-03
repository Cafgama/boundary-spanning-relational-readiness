function R = continuous_interface_readiness(wA, pA, wB, pB)
% CONTINUOUS_INTERFACE_READINESS
% Demand-weighted transferable readiness for two interface modules.
%
%   WA = sum_i pA_i * wA_i
%   WB = sum_j pB_j * wB_j
%   Wmin = min(WA, WB)
%   Wpair = WA * WB  (secondary diagnostic only)
%
% Model v0.6 core endpoint uses Wmin.

  validate_state_and_weights(wA, pA, 'A');
  validate_state_and_weights(wB, pB, 'B');

  WA = sum(pA(:) .* wA(:));
  WB = sum(pB(:) .* wB(:));

  R.WA = WA;
  R.WB = WB;
  R.Wmin = min(WA, WB);
  R.Wpair = WA * WB;
end

function validate_state_and_weights(w, p, label)
  assert(isvector(w) && isvector(p) && numel(w) == numel(p) && ~isempty(w), ...
    'w%s and p%s must be nonempty vectors of equal length.', label, label);
  assert(all(isfinite(w(:))) && all(w(:) >= 0) && all(w(:) <= 1), ...
    'w%s entries must lie in [0,1].', label);
  assert(all(isfinite(p(:))) && all(p(:) >= 0), ...
    'p%s entries must be finite and nonnegative.', label);
  assert(abs(sum(p(:)) - 1) <= 1e-10, ...
    'p%s must sum to one.', label);
end
