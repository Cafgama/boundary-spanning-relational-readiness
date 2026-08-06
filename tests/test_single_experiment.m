% TEST_SINGLE_EXPERIMENT
% Smoke tests for run_single_experiment.m

clear;
clc;

addpath('../src');

P = baseline_params();

% Use very small values for testing.
NG = 3;
NT = 5;

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

for a = 1:length(architectures)
  arch = architectures{a};

  fprintf('\nTesting single experiment for architecture: %s\n', arch);

  results = run_single_experiment(P, arch, NG, NT, P.seed + a);

  expected_runs = NG * NT;

  % Basic structure checks
  assert(isstruct(results), 'results must be a structure.');
  assert(strcmp(results.architecture, arch), 'architecture label mismatch.');

  assert(results.NG == NG, 'NG mismatch.');
  assert(results.NT == NT, 'NT mismatch.');
  assert(results.n_runs == expected_runs, 'Wrong number of runs.');

  % Vector length checks
  assert(length(results.graph_id) == expected_runs, 'graph_id length mismatch.');
  assert(length(results.trajectory_id) == expected_runs, 'trajectory_id length mismatch.');
  assert(length(results.T) == expected_runs, 'T length mismatch.');
  assert(length(results.converged) == expected_runs, 'converged length mismatch.');
  assert(length(results.final_RB) == expected_runs, 'final_RB length mismatch.');

  % Logical checks
  assert(all(results.graph_id >= 1 & results.graph_id <= NG), ...
    'graph_id out of range.');

  assert(all(results.trajectory_id >= 1 & results.trajectory_id <= NT), ...
    'trajectory_id out of range.');

  assert(all(results.converged == 0 | results.converged == 1), ...
    'converged must contain only 0 or 1.');

  assert(all(results.final_RB >= 0 & results.final_RB <= 1), ...
    'final_RB must be in [0,1].');

  assert(results.n_converged + results.n_nonconverged == expected_runs, ...
    'Converged and non-converged counts do not sum to total runs.');

  assert(results.nonconvergence_rate >= 0 && results.nonconvergence_rate <= 1, ...
    'nonconvergence_rate must be in [0,1].');

  % T consistency
  for r = 1:expected_runs
    if results.converged(r) == 1
      assert(!isnan(results.T(r)), ...
        'T cannot be NaN when trajectory converged.');
      assert(results.T(r) >= 0, ...
        'T must be non-negative when trajectory converged.');
      assert(results.final_RB(r) >= P.q, ...
        'final_RB must be at least q when trajectory converged.');
    else
      assert(isnan(results.T(r)), ...
        'T must be NaN when trajectory did not converge.');
      assert(results.final_RB(r) < P.q, ...
        'final_RB must be below q when trajectory did not converge.');
    end
  end

  % Controlled architecture checks
  if strcmp(arch, 'random_bridging') || strcmp(arch, 'boundary_spanning')
    assert(all(results.total_boundary_edges == P.k), ...
      'Controlled architectures must have exactly k boundary edges.');
  end

  fprintf('Runs: %d | Converged: %d | Non-convergence rate: %.3f\n', ...
    results.n_runs, results.n_converged, results.nonconvergence_rate);
end

disp('');
disp('All single-experiment tests passed.');
