% TEST_COMPUTE_READINESS
% Smoke tests for compute_readiness.m

clear;
clc;

addpath('../src');

P = baseline_params();
rand('seed', P.seed);

G = generate_network(P, 'random_bridging');

% Case 1: baseline initial condition
[RB, ready_edges, total_edges] = compute_readiness(G.W, G.EB, P.theta);

fprintf('\nCase 1: initial readiness\n');
fprintf('RB = %.4f\n', RB);
fprintf('ready_edges = %d\n', ready_edges);
fprintf('total_edges = %d\n', total_edges);

assert(total_edges == P.k, 'Total cross-boundary edges should equal k.');
assert(ready_edges == 0, ...
  'With w0 < theta, no cross-boundary edge should be ready initially.');
assert(RB == 0, ...
  'With w0 < theta, initial readiness should be zero.');

% Case 2: manually set all cross-boundary weights above theta
W2 = G.W;

for r = 1:rows(G.EB)
  u = G.EB(r, 1);
  i = G.EB(r, 2);

  W2(u, i) = P.theta;
  W2(i, u) = P.theta;
end

[RB2, ready_edges2, total_edges2] = compute_readiness(W2, G.EB, P.theta);

fprintf('\nCase 2: all cross-boundary edges at theta\n');
fprintf('RB = %.4f\n', RB2);
fprintf('ready_edges = %d\n', ready_edges2);
fprintf('total_edges = %d\n', total_edges2);

assert(total_edges2 == P.k, 'Total cross-boundary edges should equal k.');
assert(ready_edges2 == P.k, ...
  'All cross-boundary edges should be ready when W >= theta.');
assert(RB2 == 1, ...
  'Readiness should be 1 when all cross-boundary edges are ready.');

% Case 3: manually set half of cross-boundary weights above theta
W3 = G.W;
half_k = floor(P.k / 2);

for r = 1:half_k
  u = G.EB(r, 1);
  i = G.EB(r, 2);

  W3(u, i) = P.theta + 0.01;
  W3(i, u) = P.theta + 0.01;
end

[RB3, ready_edges3, total_edges3] = compute_readiness(W3, G.EB, P.theta);

fprintf('\nCase 3: partial readiness\n');
fprintf('RB = %.4f\n', RB3);
fprintf('ready_edges = %d\n', ready_edges3);
fprintf('total_edges = %d\n', total_edges3);

assert(total_edges3 == P.k, 'Total cross-boundary edges should equal k.');
assert(ready_edges3 == half_k, ...
  'Ready edges should equal the manually assigned half_k value.');
assert(abs(RB3 - half_k / P.k) < 1e-12, ...
  'RB should equal ready_edges / total_edges.');

disp('');
disp('All readiness tests passed.');
