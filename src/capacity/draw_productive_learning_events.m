function flags = draw_productive_learning_events(ell, seed)
% DRAW_PRODUCTIVE_LEARNING_EVENTS
% Independent Bernoulli productive-learning draws for supplied probabilities.
%
% ell  : scalar/vector/matrix with entries in [0,1]. Each entry is the
%        probability that one admitted interaction produces useful
%        transferable learning for the corresponding actor/event.
% seed : explicit nonnegative integer RNG seed.
%
% The function restores the caller RNG state. This keeps the learning RNG
% stream separate from demand generation and admission.

  tol = 1e-12;

  assert(~isempty(ell), 'ell must be nonempty.');
  assert(all(isfinite(ell(:))) && all(ell(:) >= 0) && all(ell(:) <= 1), ...
    'ell entries must be finite probabilities in [0,1].');
  assert(isscalar(seed) && isfinite(seed) && seed >= 0, ...
    'seed must be a finite nonnegative scalar.');
  assert(abs(seed - round(seed)) <= tol, ...
    'seed must be an integer.');

  seed = round(seed);
  old_state = rng();
  rng(seed, 'twister');
  u = rand(size(ell));
  rng(old_state);

  flags = (u < ell);
end
