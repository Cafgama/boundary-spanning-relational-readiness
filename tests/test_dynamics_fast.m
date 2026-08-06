% TEST_DYNAMICS_FAST
% Compares run_dynamics.m and run_dynamics_fast.m under identical seeds.

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

% Keep test fast.
P.T_max = 5000;

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

for a = 1:length(architectures)

  arch = architectures{a};

  fprintf('\nTesting fast dynamics for architecture: %s\n', arch);

  % Generate one fixed network.
  rand('seed', P.seed + a);
  G = generate_network(P, arch);

  % Run slow dynamics with fixed dynamic seed.
  rand('seed', P.seed + 1000 + a);
  out_slow = run_dynamics(G, P, true);

  % Run fast dynamics with the same fixed dynamic seed.
  rand('seed', P.seed + 1000 + a);
  out_fast = run_dynamics_fast(G, P, true);

  % Compare convergence indicators.
  assert(out_slow.converged == out_fast.converged, ...
    'Fast and slow dynamics disagree on convergence.');

  % Compare first-passage time.
  if out_slow.converged == 1
    assert(out_slow.T == out_fast.T, ...
      'Fast and slow dynamics disagree on first-passage time.');
  else
    assert(isnan(out_slow.T) && isnan(out_fast.T), ...
      'Both T values should be NaN when non-converged.');
  end

  % Compare final readiness.
  assert(abs(out_slow.final_RB - out_fast.final_RB) < 1e-12, ...
    'Fast and slow dynamics disagree on final_RB.');

  assert(out_slow.final_ready == out_fast.final_ready, ...
    'Fast and slow dynamics disagree on final_ready.');

  % Compare histories.
  assert(length(out_slow.RB_history) == length(out_fast.RB_history), ...
    'Fast and slow dynamics have different RB_history lengths.');

  assert(max(abs(out_slow.RB_history - out_fast.RB_history)) < 1e-12, ...
    'Fast and slow dynamics disagree on RB_history.');

  % Compare final weights.
  max_weight_diff = max(max(abs(out_slow.final_W - out_fast.final_W)));

  assert(max_weight_diff < 1e-12, ...
    'Fast and slow dynamics disagree on final_W.');

  fprintf('Passed. Converged: %d | T: ', out_fast.converged);

  if out_fast.converged == 1
    fprintf('%d', out_fast.T);
  else
    fprintf('NaN');
  end

  fprintf(' | Final RB: %.4f\n', out_fast.final_RB);
end

disp('');
disp('All fast dynamics tests passed.');
