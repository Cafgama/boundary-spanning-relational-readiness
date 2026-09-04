function run_capacity_v0_10_tests()
% RUN_CAPACITY_V0_10_TESTS
% Pre-data E6 tests: exact total shock severity and transient recovery.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  tol = 1e-12;

  %% 1. Exact helper boundary cases.
  c = [15,15,15,15];
  [c1,g1] = transient_shock_capacity(c,1.0);
  assert(isequal(c1,c));
  assert(abs(g1-1) <= tol);

  [c0,g0] = transient_shock_capacity(c,0.0);
  assert(isequal(c0,[0,0,0,0]));
  assert(g0 == 0);

  [c06,g06] = transient_shock_capacity(c,0.6);
  assert(isequal(c06,[9,9,9,9]));
  assert(abs(g06-0.6) <= tol);

  %% 2. Largest-remainder shock preserves exact module-level severity.
  c = [39,7,7,7];
  gammas = [1.0,0.8,0.6,0.5,0.4];
  for ig = 1:numel(gammas)
    [cs,gr] = transient_shock_capacity(c,gammas(ig));
    assert(sum(cs) == round(gammas(ig)*sum(c)));
    assert(abs(gr-gammas(ig)) <= tol);
    assert(all(cs <= c));
  end
  [c08,~] = transient_shock_capacity(c,0.8);
  assert(isequal(c08,[31,6,6,5]));

  %% 3. gamma=1 must reproduce Model v0.7 exactly on relevant outputs.
  p = one_heavy_responsibility(4,9/15);
  x = ones(1,4)/4;
  ell = 0.7*ones(1,4);
  ell(1) = 0.9;
  w0 = 0.4;
  alpha = 0.08;
  Theta = 0.8;
  C = 60;
  D = 36;
  max_windows = 20;
  dseed = 769010001;
  lseed = 869010001;

  base = simulate_capacity_learning_readiness( ...
    p,p,x,x,w0,alpha,ell,ell,Theta,C,D,max_windows,dseed,lseed);
  shock1 = simulate_transient_capacity_shock_readiness( ...
    p,p,x,x,w0,alpha,ell,ell,Theta,C,D,max_windows,1.0,dseed,lseed);

  assert(isequaln(base.T,shock1.T));
  assert(base.T_tilde == shock1.T_tilde);
  assert(base.delta == shock1.delta);
  assert(base.n_attempted == shock1.n_attempted);
  assert(base.n_served == shock1.n_served);
  assert(base.n_blocked == shock1.n_blocked);
  assert(base.n_productive_A == shock1.n_productive_A);
  assert(base.n_productive_B == shock1.n_productive_B);
  assert(abs(base.Wmin-shock1.Wmin) <= tol);
  assert(isequal(shock1.cA_shock,shock1.cA));
  assert(isequal(shock1.cB_shock,shock1.cB));

  %% 4. gamma=0: first window blocks all demand; next window recovers baseline capacity.
  % D=1 creates an exact two-attempt toy: attempt 1 belongs to the zero-capacity
  % shock window, attempt 2 belongs to the restored baseline window.
  p = ones(1,4)/4;
  x = p;
  out = simulate_transient_capacity_shock_readiness( ...
    p,p,x,x,0.4,0.08,0,0,0.8,4,1,2,0.0,12345,54321);

  assert(out.delta == 0);
  assert(out.n_attempted == 2);
  assert(out.n_attempted_shock == 1);
  assert(out.n_served_shock == 0);
  assert(out.n_blocked_shock == 1);
  assert(out.n_productive_A_shock == 0);
  assert(out.n_productive_B_shock == 0);
  assert(out.n_served == 1);  % second-window service proves capacity recovery
  assert(out.n_blocked == 1);
  assert(out.n_windows_started == 2);

  %% 5. E6 grid shock severities are exact at module level for a matched case.
  p = one_heavy_responsibility(4,4/15);
  [cb,~] = allocate_integer_capacity(60,p);
  for gamma = [1.0,0.8,0.6,0.5,0.4]
    [cs,gr] = transient_shock_capacity(cb,gamma);
    assert(sum(cs) == round(gamma*60));
    assert(abs(gr-gamma) <= tol);
  end

  fprintf('PASS: Model v0.10 transient capacity-shock tests\n');
end
