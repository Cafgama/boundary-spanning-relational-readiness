% TEST_DYNAMICS_SMALL
% Smoke tests for run_dynamics.m

clear;
clc;

addpath('../src');

P = baseline_params();
rand('seed', P.seed);

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

for a = 1:length(architectures)
  arch = architectures{a};

  fprintf('\nTesting dynamics for architecture: %s\n', arch);

  G = generate_network(P, arch);

  out = run_dynamics(G, P, true);

  % Basic output checks
  assert(isfield(out, 'T'), 'Output must contain T.');
  assert(isfield(out, 'converged'), 'Output must contain converged.');
  assert(isfield(out, 'final_RB'), 'Output must contain final_RB.');
  assert(isfield(out, 'final_W'), 'Output must contain final_W.');

  assert(out.converged == 0 || out.converged == 1, ...
    'converged must be 0 or 1.');

  assert(out.final_RB >= 0 && out.final_RB <= 1, ...
    'final_RB must be in [0,1].');

  assert(isequal(out.final_W, out.final_W'), ...
    'final_W must be symmetric.');

  assert(min(out.final_W(:)) >= 0, ...
    'final_W cannot contain values below 0.');

  assert(max(out.final_W(:)) <= 1, ...
    'final_W cannot contain values above 1.');

  if out.converged == 1
    assert(!isnan(out.T), 'T cannot be NaN if converged.');
    assert(out.T >= 0, 'T must be non-negative.');
    assert(out.final_RB >= P.q, ...
      'final_RB must be at least q if converged.');
  else
    assert(isnan(out.T), 'T must be NaN if not converged.');
    assert(out.final_RB < P.q, ...
      'final_RB must be below q if not converged.');
  end

  % History checks
  assert(length(out.RB_history) >= 1, ...
    'RB_history must contain at least the initial readiness.');

  assert(min(out.RB_history) >= 0 && max(out.RB_history) <= 1, ...
    'RB_history values must be in [0,1].');

  fprintf('Converged: %d | T: ', out.converged);

  if out.converged == 1
    fprintf('%d', out.T);
  else
    fprintf('NaN');
  end

  fprintf(' | Final RB: %.4f\n', out.final_RB);
end

disp('');
disp('All small dynamics tests passed.');
