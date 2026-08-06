% TEST_NETWORK_GENERATION
% Smoke tests for generate_network.m

clear;
clc;

addpath('../src');

P = baseline_params();
rand('seed', P.seed);

architectures = {'baseline', 'random_bridging', 'boundary_spanning'};

for a = 1:length(architectures)
  arch = architectures{a};

  fprintf('\nTesting architecture: %s\n', arch);

  G = generate_network(P, arch);

  % Basic matrix checks
  assert(isequal(G.A, G.A'), 'A must be symmetric.');
  assert(isequal(G.W, G.W'), 'W must be symmetric.');
  assert(isequal(G.edge_type, G.edge_type'), 'edge_type must be symmetric.');

  assert(all(diag(G.A) == 0), 'A must not contain self-loops.');
  assert(all(diag(G.W) == 0), 'W must not contain self-loop weights.');

  % Module checks
  assert(length(G.module) == P.N, 'module vector has wrong size.');
  assert(sum(G.module == 1) == P.nU, 'wrong number of university nodes.');
  assert(sum(G.module == 2) == P.nI, 'wrong number of industry nodes.');

  % Edge-weight consistency
  edge_positions = find(G.A == 1);
  assert(all(G.W(edge_positions) == P.w0), ...
    'All existing edges must start with weight w0.');

  no_edge_positions = find(G.A == 0);
  assert(all(G.W(no_edge_positions) == 0), ...
    'Non-edges must have zero weight.');

  % Cross-boundary checks
  if strcmp(arch, 'random_bridging') || strcmp(arch, 'boundary_spanning')
    assert(rows(G.EB) == P.k, ...
      'Controlled architecture must have exactly k cross-boundary edges.');
  end

  if strcmp(arch, 'boundary_spanning')
    assert(length(G.BU) == P.b, 'Wrong number of university boundary spanners.');
    assert(length(G.BI) == P.b, 'Wrong number of industry boundary spanners.');

    for r = 1:rows(G.EB)
      u = G.EB(r, 1);
      i = G.EB(r, 2);

      involves_spanner = any(G.BU == u) || any(G.BI == i);

      assert(involves_spanner, ...
        'Every boundary-spanning cross-boundary tie must involve at least one spanner.');

      assert(G.edge_type(u, i) == 3, ...
        'Boundary-spanning cross-boundary ties must have edge_type 3.');
    end
  end

  fprintf('Passed. Total edges: %d | Cross-boundary edges: %d\n', ...
    sum(sum(G.A)) / 2, rows(G.EB));
end

disp('');
disp('All network-generation tests passed.');
