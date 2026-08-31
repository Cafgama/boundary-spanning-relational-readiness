function N = simulate_no_capacity_learning_requirement(K, ell, n_rep, seed)
% SIMULATE_NO_CAPACITY_LEARNING_REQUIREMENT
% Monte Carlo stopping time for K productive events with no capacity limit.
%
% Each admitted interaction is an independent productive-learning trial with
% probability ell. The returned vector N contains the number of admitted
% interactions required to accumulate exactly K productive events in each
% replication.
%
% This function is deliberately capacity-free. It validates the competence
% layer against the negative-binomial benchmark before competence is coupled
% to the admission model.

  tol = 1e-12;

  assert(isscalar(K) && isfinite(K) && K >= 1, ...
    'K must be a positive finite scalar.');
  assert(abs(K - round(K)) <= tol, 'K must be an integer.');
  assert(isscalar(ell) && isfinite(ell) && ell > 0 && ell <= 1, ...
    'ell must be a scalar in (0,1].');
  assert(isscalar(n_rep) && isfinite(n_rep) && n_rep >= 1, ...
    'n_rep must be a positive finite scalar.');
  assert(abs(n_rep - round(n_rep)) <= tol, 'n_rep must be an integer.');
  assert(isscalar(seed) && isfinite(seed) && seed >= 0, ...
    'seed must be a finite nonnegative scalar.');
  assert(abs(seed - round(seed)) <= tol, 'seed must be an integer.');

  K = round(K);
  n_rep = round(n_rep);
  seed = round(seed);

  N = zeros(n_rep, 1);

  old_state = rng();
  rng(seed, 'twister');

  for r = 1:n_rep
    successes = 0;
    trials = 0;
    while successes < K
      trials = trials + 1;
      if rand() < ell
        successes = successes + 1;
      end
    end
    N(r) = trials;
  end

  rng(old_state);
end
