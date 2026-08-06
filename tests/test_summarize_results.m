% TEST_SUMMARIZE_RESULTS
% Smoke tests for summarize_results.m

clear;
clc;

addpath('../src');

P = baseline_params();

NG = 3;
NT = 5;

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

for a = 1:length(architectures)
  arch = architectures{a};

  fprintf('\nTesting summary for architecture: %s\n', arch);

  results = run_single_experiment(P, arch, NG, NT, P.seed + a);
  S = summarize_results(results, P);

  expected_runs = NG * NT;

  % Basic summary checks
  assert(isstruct(S), 'Summary S must be a structure.');
  assert(strcmp(S.architecture, arch), 'Architecture label mismatch.');

  assert(S.NG == NG, 'NG mismatch.');
  assert(S.NT == NT, 'NT mismatch.');
  assert(S.n_runs == expected_runs, 'Wrong number of runs.');

  assert(S.n_converged + S.n_nonconverged == expected_runs, ...
    'Converged and non-converged counts do not sum to total runs.');

  assert(S.convergence_rate >= 0 && S.convergence_rate <= 1, ...
    'convergence_rate must be in [0,1].');

  assert(S.nonconvergence_rate >= 0 && S.nonconvergence_rate <= 1, ...
    'nonconvergence_rate must be in [0,1].');

  assert(abs(S.convergence_rate + S.nonconvergence_rate - 1) < 1e-12, ...
    'Convergence and non-convergence rates must sum to 1.');

  % Censored statistics should always exist
  assert(!isnan(S.T_cens_mean), 'Censored mean should not be NaN.');
  assert(!isnan(S.T_cens_median), 'Censored median should not be NaN.');
  assert(S.T_cens_min >= 0, 'Censored min must be non-negative.');
  assert(S.T_cens_max <= P.T_max, 'Censored max cannot exceed T_max.');

  % Final readiness checks
  assert(S.final_RB_mean >= 0 && S.final_RB_mean <= 1, ...
    'final_RB_mean must be in [0,1].');

  assert(S.final_RB_median >= 0 && S.final_RB_median <= 1, ...
    'final_RB_median must be in [0,1].');

  % If at least one trajectory converged, converged-only stats should exist.
  if S.n_converged > 0
    assert(!isnan(S.T_conv_median), ...
      'Converged-only median should not be NaN when convergence exists.');

    assert(S.T_conv_min >= 0, ...
      'Converged-only min must be non-negative.');
  else
    assert(isnan(S.T_conv_median), ...
      'Converged-only median should be NaN when no convergence exists.');
  end

  fprintf('Runs: %d | Conv. rate: %.3f | Non-conv. rate: %.3f\n', ...
    S.n_runs, S.convergence_rate, S.nonconvergence_rate);

  fprintf('T censored median: %.2f | T censored p95: %.2f\n', ...
    S.T_cens_median, S.T_cens_p95);
end

disp('');
disp('All summary tests passed.');
