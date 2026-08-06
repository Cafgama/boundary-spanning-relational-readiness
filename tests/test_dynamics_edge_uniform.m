% TEST_DYNAMICS_EDGE_UNIFORM

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

P = baseline_params();

P.T_max = 3000;

rand('seed', P.seed);

G = safe_generate_network(P, 'boundary_spanning');

out = run_dynamics_fast_edge_uniform(G, P, false);

assert(isstruct(out), 'Output must be a structure.');

assert(isfield(out, 'T'), 'Output must contain T.');
assert(isfield(out, 'converged'), 'Output must contain converged.');
assert(isfield(out, 'final_RB'), 'Output must contain final_RB.');
assert(isfield(out, 'final_ready'), 'Output must contain final_ready.');
assert(isfield(out, 'total_boundary_edges'), ...
  'Output must contain total_boundary_edges.');
assert(isfield(out, 'final_W'), 'Output must contain final_W.');
assert(isfield(out, 'RB_history'), 'Output must contain RB_history.');

assert(out.T >= 0, 'T must be non-negative.');
assert(out.T <= P.T_max, 'T must not exceed T_max.');

assert(out.final_RB >= 0 && out.final_RB <= 1, ...
  'final_RB must be in [0,1].');

assert(out.final_ready >= 0, ...
  'final_ready must be non-negative.');

assert(out.final_ready <= out.total_boundary_edges, ...
  'final_ready cannot exceed total boundary edges.');

assert(all(out.final_W(:) >= -1e-12), ...
  'Final weights must be non-negative.');

assert(all(out.final_W(:) <= 1 + 1e-12), ...
  'Final weights must not exceed 1.');

assert(strcmp(out.selection_rule, 'edge_uniform'), ...
  'Selection rule label should be edge_uniform.');

disp('Edge-uniform dynamics test passed.');
