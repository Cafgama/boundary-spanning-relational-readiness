% TEST_ANALYTICAL_REDUCTIONS
% Deterministic tests for the locked Scarce Interaction Capacity Model v0.1.
%
% No stochastic dynamics are exercised here.

this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));
addpath(fullfile(repo_root, 'src', 'capacity'));

tol = 1e-10;

fprintf('\n[1] Uniform responsibility and uniform capacity...\n');
n = 20;
p = ones(1, n) / n;
x = ones(1, n) / n;
M = capacity_load_metrics(40, 40, p, x);
assert(abs(M.Omega - 1) < tol);
assert(abs(M.H) < tol);
assert(abs(M.Lambda - 1) < tol);
assert(abs(M.chi - 1) < tol);
assert(max(abs(M.local_load - 1)) < tol);

fprintf('[2] Exact capacity matching x=p removes mismatch...\n');
for h = [0, 0.2, 0.5, 0.8, 1]
  p = one_heavy_responsibility(n, h);
  M = capacity_load_metrics(40, 32, p, p);
  assert(abs(M.Lambda - 1) < tol, ...
    'x=p must imply Lambda=1 exactly up to floating-point tolerance.');
  assert(abs(M.chi - M.Omega) < tol, ...
    'x=p must imply chi=Omega.');
end

fprintf('[3] One-heavy-carrier identity H=h^2...\n');
for h = [0, 0.1, 0.25, 0.5, 0.75, 1]
  p = one_heavy_responsibility(n, h);
  x = ones(1, n) / n;
  M = capacity_load_metrics(40, 40, p, x);
  assert(abs(M.H - h^2) < tol, ...
    'One-heavy family must satisfy H=h^2.');
end

fprintf('[4] Uniform-capacity formula Lambda=1+(n-1)h...\n');
for h = [0, 0.1, 0.25, 0.5, 0.75, 1]
  p = one_heavy_responsibility(n, h);
  x = ones(1, n) / n;
  M = capacity_load_metrics(40, 40, p, x);
  Lambda_expected = 1 + (n - 1) * h;
  assert(abs(M.Lambda - Lambda_expected) < tol, ...
    'Unexpected Lambda for one-heavy family under uniform capacity.');
end

fprintf('[5] Positive demand with zero capacity produces infinite mismatch...\n');
p = [0.5, 0.5];
x = [1, 0];
M = capacity_load_metrics(10, 10, p, x);
assert(isinf(M.Lambda));
assert(isinf(M.chi));
assert(isinf(M.local_load(2)));

fprintf('[6] Legacy analytical service-requirement sanity check...\n');
alpha = 0.08;
beta = 0.02;
w0 = 0.40;
theta = 0.80;
So = relational_service_metrics(0.55, alpha, beta, w0, theta);
Ss = relational_service_metrics(0.65, alpha, beta, w0, theta);

assert(abs(So.pi_c - 0.5) < tol);
assert(abs(Ss.pi_c - 0.5) < tol);
assert(abs(So.s_theta - 48.787054544443265) < 1e-9);
assert(abs(Ss.s_theta - 29.233854373294870) < 1e-9);

fprintf('[7] Competence gain G and coordination stress Xi...\n');
p = ones(1, n) / n;
x = ones(1, n) / n;
L = capacity_load_metrics(40, 40, p, x);
S = coordination_stress_metrics(L, So, Ss);
assert(abs(S.G - 1.668854675181328) < 1e-9);
assert(abs(S.Xi - (1 / S.G)) < tol);

fprintf('[8] Critical competence pi=pi_c is asymptotically marginal...\n');
Sc = relational_service_metrics(0.5, alpha, beta, w0, theta);
assert(abs(Sc.w_star - theta) < tol);
assert(~Sc.feasible);
assert(isinf(Sc.s_theta));

fprintf('[9] Domain validation: non-normalized shares must fail...\n');
did_fail = false;
try
  capacity_load_metrics(10, 10, [0.6, 0.6], [0.5, 0.5]);
catch
  did_fail = true;
end
assert(did_fail, 'Non-normalized p should raise an error.');

fprintf('[10] Endpoint identities h=0 and h=1...\n');
p0 = one_heavy_responsibility(n, 0);
p1 = one_heavy_responsibility(n, 1);
assert(max(abs(p0 - ones(1, n)/n)) < tol);
assert(abs(p1(1) - 1) < tol);
assert(max(abs(p1(2:end))) < tol);

fprintf('\nAll deterministic Model v0.1 analytical tests passed.\n');
