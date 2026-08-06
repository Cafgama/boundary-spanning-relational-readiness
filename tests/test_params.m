  % TEST_PARAMS
% Basic smoke test for baseline_params.m

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

disp('Baseline parameter set loaded successfully.');
disp(P);

% Additional explicit checks for model interpretation
assert(P.nU == 20, 'Unexpected nU value.');
assert(P.nI == 20, 'Unexpected nI value.');
assert(P.k == 12, 'Unexpected cross-boundary edge budget.');
assert(P.b == 2, 'Unexpected number of boundary spanners per side.');

assert(P.p_in > P.p_out, 'Internal tie probability must exceed cross-boundary tie probability.');
assert(P.pi_in > P.pi_BS && P.pi_BS > P.pi_out, ...
  'Success probabilities must satisfy pi_in > pi_BS > pi_out.');

required_ready_edges = ceil(P.q * P.k);

fprintf('\nReadiness condition under baseline parameters:\n');
fprintf('k = %d cross-boundary ties\n', P.k);
fprintf('q = %.2f\n', P.q);
fprintf('Required ready cross-boundary ties = %d\n', required_ready_edges);

disp('All parameter tests passed.');
