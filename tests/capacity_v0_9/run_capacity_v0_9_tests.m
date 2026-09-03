function run_capacity_v0_9_tests()
% RUN_CAPACITY_V0_9_TESTS
% Deterministic competence-switching tests for E5 pre-data theory.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  n = 4;
  w0 = 0.4;
  alpha = 0.08;
  ell_o = 0.70;
  Theta = 0.8;
  C = 60;
  Omega = 1.0;
  max_windows = 20;
  pD = ones(1,n)/n;
  xD = pD;

  % Identity: an architecture identical to the diffuse benchmark must be a
  % structural win at exactly the ordinary competence floor.
  A = competence_switching_threshold( ...
    pD,xD,pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-9);
  assert(strcmp(A.regime,'structural_win'));
  assert(abs(A.ell_star-ell_o) < 1e-12);
  assert(abs(A.T_at_ell_o-A.T_diffuse) < 1e-10);

  % Low concentration with uniform capacity is deliberately chosen from the
  % preregistered deterministic map as an unrescuable example.
  p4 = one_heavy_responsibility(n,4/15);
  U = competence_switching_threshold( ...
    p4,xD,pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-8);
  assert(strcmp(U.regime,'unrescuable'));
  assert(isnan(U.ell_star));
  assert(U.T_at_one > U.T_diffuse);

  % k=10 at Omega=1 is a preregistered competence-rescuable example. The
  % threshold should lie between the ordinary floor and 0.80.
  p10 = one_heavy_responsibility(n,10/15);
  R = competence_switching_threshold( ...
    p10,xD,pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-9);
  assert(strcmp(R.regime,'competence_rescuable'));
  assert(R.ell_star > ell_o && R.ell_star < 0.80);
  assert(R.T_at_ell_o > R.T_diffuse);
  assert(R.T_at_one <= R.T_diffuse + 1e-8);

  % High concentration is already a structural win without specialist premium.
  p13 = one_heavy_responsibility(n,13/15);
  S = competence_switching_threshold( ...
    p13,xD,pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-9);
  assert(strcmp(S.regime,'structural_win'));
  assert(abs(S.ell_star-ell_o) < 1e-12);

  % Matching capacity cannot make the concentrated deterministic trajectory
  % slower than the same architecture under uniform capacity at fixed ell.
  ell = [0.90,ell_o,ell_o,ell_o];
  Fm = fluid_learning_readiness_symmetric(Omega,p10,p10,w0,alpha,ell,Theta,C,max_windows);
  Fu = fluid_learning_readiness_symmetric(Omega,p10,xD,w0,alpha,ell,Theta,C,max_windows);
  assert(Fm.delta == 1 && Fu.delta == 1);
  assert(Fm.T_real <= Fu.T_real + 1e-10);

  fprintf('PASS: Model v0.9 competence-switching threshold tests\n');
end
