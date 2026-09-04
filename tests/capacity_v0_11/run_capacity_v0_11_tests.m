function run_capacity_v0_11_tests()
% RUN_CAPACITY_V0_11_TESTS
% E7 pre-data robustness tests: pairing extension and exact scaling identities.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));
  tol = 1e-10;

  %% 1. Product pairing wrapper must reproduce validated v0.7 exactly.
  p = one_heavy_responsibility(4,0.75);
  x = ones(1,4)/4;
  args = {p,p,x,x,0.4,0.08,1,1,0.8,60,60,20,711001,811001};
  base = simulate_capacity_learning_readiness(args{:});
  prod = simulate_capacity_learning_readiness_pairing(args{:},'product');
  assert(isequaln(base.T,prod.T));
  assert(base.T_tilde == prod.T_tilde);
  assert(base.delta == prod.delta);
  assert(base.n_attempted == prod.n_attempted);
  assert(base.n_served == prod.n_served);
  assert(base.n_blocked == prod.n_blocked);
  assert(base.n_productive_A == prod.n_productive_A);
  assert(base.n_productive_B == prod.n_productive_B);
  assert(abs(base.Wmin-prod.Wmin) <= tol);
  assert(isequal(base.wA,prod.wA));
  assert(isequal(base.wB,prod.wB));

  %% 2. Assortative demand generator is reproducible, symmetric, and preserves RNG.
  old = rng();
  p = [0.5,1/6,1/6,1/6];
  pairs1 = generate_pairing_demands(100000,p,p,123456,'assortative');
  after = rng();
  assert(isequal(old,after));
  pairs2 = generate_pairing_demands(100000,p,p,123456,'assortative');
  assert(isequal(pairs1,pairs2));
  assert(all(pairs1(:,1) == pairs1(:,2)));
  counts = accumarray(pairs1(:,1),1,[4,1])/100000;
  assert(max(abs(counts-p(:))) < 0.01);

  %% 3. h=0: matched and uniform are the same capacity policy in either mode.
  p = ones(1,4)/4;
  for mode = {'product','assortative'}
    a = simulate_capacity_learning_readiness_pairing( ...
      p,p,p,p,0.4,0.08,1,1,0.8,60,60,10,70001,80001,mode{1});
    b = simulate_capacity_learning_readiness_pairing( ...
      p,p,ones(1,4)/4,ones(1,4)/4,0.4,0.08,1,1,0.8,60,60,10,70001,80001,mode{1});
    assert(isequaln(a.T,b.T));
    assert(a.T_tilde == b.T_tilde);
    assert(a.n_blocked == b.n_blocked);
  end

  %% 4. h=1, C=60: 15 uniform slots exceed K_0.8=14, so T=14 exactly.
  p = [1,0,0,0];
  for mode = {'product','assortative'}
    for policy = 1:2
      if policy == 1
        x = p;
      else
        x = ones(1,4)/4;
      end
      for Omega = [0.6,1.0,1.5]
        D = round(Omega*60);
        o = simulate_capacity_learning_readiness_pairing( ...
          p,p,x,x,0.4,0.08,1,1,0.8,60,D,5,71000+D,81000+D,mode{1});
        assert(o.T == 14);
      end
    end
  end

  %% 5. Capacity-scale exact endpoint switch at h=1, C=40.
  x = ones(1,4)/4;
  expected = [14,30,50];
  Omegas = [0.6,1.0,1.5];
  for q = 1:3
    D = round(Omegas(q)*40);
    o = simulate_capacity_learning_readiness_pairing( ...
      p,p,x,x,0.4,0.08,1,1,0.8,40,D,5,72000+D,82000+D,'product');
    assert(o.T - 14 == expected(q));
  end

  %% 6. Readiness-threshold exact switch at h=1, C=60, Omega=1.
  K07 = productive_events_to_threshold(0.4,0.7,0.08).k_required;
  K08 = productive_events_to_threshold(0.4,0.8,0.08).k_required;
  K09 = productive_events_to_threshold(0.4,0.9,0.08).k_required;
  assert(K07 == 9 && K08 == 14 && K09 == 22);
  for Theta = [0.7,0.8]
    o = simulate_capacity_learning_readiness_pairing( ...
      p,p,x,x,0.4,0.08,1,1,Theta,60,60,5,73000,83000,'product');
    K = productive_events_to_threshold(0.4,Theta,0.08).k_required;
    assert(o.T == K);
  end
  o = simulate_capacity_learning_readiness_pairing( ...
    p,p,x,x,0.4,0.08,1,1,0.9,60,60,5,73001,83001,'product');
  assert(o.T == 67);
  assert(o.T - K09 == 45);

  %% 7. Assortative fluid benchmark: no-exhaustion endpoint equals no-capacity real crossing.
  N0 = no_capacity_mean_crossing_real(p,0.4,0.08,1,0.8,1000);
  t0 = N0.t_cross;
  Fa = fluid_learning_readiness_assortative_symmetric(1,p,ones(1,4)/4,0.4,0.08,1,0.8,60,5);
  assert(abs(Fa.T_real-t0) < 1e-7);
  assert(abs(Fa.first_exhaustion_attempt-15) < tol);

  %% 8. Assortative fluid C=40 endpoint delays crossing until second window.
  Fa40 = fluid_learning_readiness_assortative_symmetric(1,p,ones(1,4)/4,0.4,0.08,1,0.8,40,5);
  assert(abs(Fa40.first_exhaustion_attempt-10) < tol);
  assert(abs(Fa40.T_real-(40 + (t0-10))) < 1e-7);

  fprintf('PASS: Model v0.11 E7 robustness tests\n');
end
