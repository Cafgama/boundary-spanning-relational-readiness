function run_capacity_v0_10_tests()
% RUN_CAPACITY_V0_10_TESTS
% Pre-data E6 tests: integer shock capacity and transient recovery semantics.

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

  %% 2. Floor rounding and nested capacity vectors.
  c = [39,7,7,7];
  gammas = [1.0,0.8,0.6,0.5,0.4];
  Cshock = zeros(numel(gammas),numel(c));
  for ig = 1:numel(gammas)
    [Cshock(ig,:),gr] = transient_shock_capacity(c,gammas(ig));
    assert(gr <= gammas(ig) + tol);
  end
  for ig = 1:(numel(gammas)-1)
    assert(all(Cshock(ig+1,:) <= Cshock(ig,:)));
  end
  assert(isequal(Cshock(2,:),[31,5,5,5]));

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

  %% 5. Stronger shocks produce componentwise smaller capacity, but no T ordering is asserted.
  s08 = simulate_transient_capacity_shock_readiness( ...
    p,p,x,x,0.4,0.08,0.7,0.7,0.8,60,36,10,0.8,22222,33333);
  s04 = simulate_transient_capacity_shock_readiness( ...
    p,p,x,x,0.4,0.08,0.7,0.7,0.8,60,36,10,0.4,22222,33333);
  assert(all(s04.cA_shock <= s08.cA_shock));
  assert(all(s04.cB_shock <= s08.cB_shock));

  fprintf('PASS: Model v0.10 transient capacity-shock tests\n');
end
