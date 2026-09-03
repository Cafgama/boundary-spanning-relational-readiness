function run_e5_competence_switching_screening(output_path, R)
% RUN_E5_COMPETENCE_SWITCHING_SCREENING
% E5: heterogeneous specialist competence under scarce interface capacity.
%
% PRE-DATA design:
%   docs/capacity_experiment_e5_design.md
%   docs/capacity_experiment_e5_execution_lock.md

  if nargin < 1 || isempty(output_path)
    output_path = 'results/raw/e5_competence_switching_screening.csv';
  end
  if nargin < 2 || isempty(R)
    R = 200;
  end
  assert(isscalar(R) && R >= 1 && R == floor(R), 'R must be a positive integer.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  n = 4;
  w0 = 0.4;
  alpha = 0.08;
  ell_o = 0.70;
  Theta = 0.8;
  C = 60;
  max_windows = 20;
  k_grid = [4,7,8,9,10,11,13,15];
  ell_s_grid = [0.70,0.80,0.90,1.00];
  omega_grid = [0.6,1.0,1.5];
  pD = ones(1,n)/n;
  xD = pD;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid,['policy,replication,demand_seed,learning_seed,n,k,h,H,ell_o,ell_s,' ...
    'w0,alpha,Theta,C,D,Omega,max_windows,T_max,Lambda,chi,regime,ell_star,' ...
    'T_theory_concentrated,T_theory_diffuse,theory_architecture_advantage,' ...
    'T_capacity,T_capacity_tilde,delta_capacity,T_free,T_free_tilde,delta_free,' ...
    'capacity_penalty_tilde,n_attempted,n_served,n_blocked,blocked_fraction,' ...
    'first_block_attempt,n_windows_started,Wmin_final,' ...
    'T_diffuse_capacity,T_diffuse_capacity_tilde,delta_diffuse_capacity,' ...
    'T_diffuse_free,T_diffuse_free_tilde,delta_diffuse_free,' ...
    'diffuse_capacity_penalty_tilde,architecture_advantage_tilde\n']);

  row_count = 0;

  for io = 1:numel(omega_grid)
    Omega = omega_grid(io);
    D = round(Omega*C);
    T_max = D*max_windows;
    assert(abs(D/C-Omega) < 1e-12,'Omega must be integer-compatible with C.');

    % Deterministic diffuse benchmark for this scarcity level.
    FD = fluid_learning_readiness_symmetric( ...
      Omega,pD,xD,w0,alpha,ell_o,Theta,C,max_windows);
    assert(FD.delta == 1,'Diffuse deterministic benchmark failed to cross.');

    for rep = 1:R
      % Diffuse ordinary benchmark uses the locked k=0 seed family.
      dseedD = 530000000 + io*10000 + rep;
      lseedD = 630000000 + io*10000 + rep;

      diff_cap = simulate_capacity_learning_readiness( ...
        pD,pD,xD,xD,w0,alpha,ell_o,ell_o,Theta,C,D,max_windows,dseedD,lseedD);
      diff_free = simulate_no_capacity_interface_readiness( ...
        pD,pD,w0,alpha,ell_o,ell_o,Theta,T_max,dseedD,lseedD);

      assert(diff_cap.T_tilde + 1e-12 >= diff_free.T_tilde, ...
        'Diffuse capacity trajectory accelerated its free counterfactual.');
      if diff_cap.delta == 1
        assert(diff_free.delta == 1, ...
          'Diffuse constrained trajectory crossed while free counterpart was censored.');
      end

      for ik = 1:numel(k_grid)
        k = k_grid(ik);
        h = k/15;
        H = h^2;
        p = one_heavy_responsibility(n,h);
        dseed = 530000000 + k*1000000 + io*10000 + rep;
        lseed = 630000000 + k*1000000 + io*10000 + rep;

        policies = {'matched','uniform'};
        xpol = {p,xD};
        cap_times = NaN(2,numel(ell_s_grid));
        cap_tildes = NaN(2,numel(ell_s_grid));
        cap_deltas = zeros(2,numel(ell_s_grid));
        free_times = NaN(1,numel(ell_s_grid));
        free_tildes = NaN(1,numel(ell_s_grid));
        free_deltas = zeros(1,numel(ell_s_grid));

        % Precompute deterministic threshold classification for each policy.
        theory = cell(1,2);
        M = cell(1,2);
        for ip = 1:2
          M{ip} = capacity_load_metrics(D,C,p,xpol{ip});
          theory{ip} = competence_switching_threshold( ...
            p,xpol{ip},pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-8);
        end

        for ie = 1:numel(ell_s_grid)
          ell_s = ell_s_grid(ie);
          ell = ell_o*ones(1,n);
          ell(1) = ell_s;

          free = simulate_no_capacity_interface_readiness( ...
            p,p,w0,alpha,ell,ell,Theta,T_max,dseed,lseed);
          free_times(ie) = free.T;
          free_tildes(ie) = free.T_tilde;
          free_deltas(ie) = free.delta;

          for ip = 1:2
            policy = policies{ip};
            x = xpol{ip};
            cap = simulate_capacity_learning_readiness( ...
              p,p,x,x,w0,alpha,ell,ell,Theta,C,D,max_windows,dseed,lseed);

            cap_times(ip,ie) = cap.T;
            cap_tildes(ip,ie) = cap.T_tilde;
            cap_deltas(ip,ie) = cap.delta;

            assert(cap.T_tilde + 1e-12 >= free.T_tilde, ...
              'E5 constrained trajectory accelerated its free counterfactual.');
            if cap.delta == 1
              assert(free.delta == 1, ...
                'E5 constrained trajectory crossed while free counterpart was censored.');
            end

            F = fluid_learning_readiness_symmetric( ...
              Omega,p,x,w0,alpha,ell,Theta,C,max_windows);
            assert(F.delta == 1,'E5 deterministic competence-grid cell failed to cross.');

            capacity_penalty = cap.T_tilde-free.T_tilde;
            diffuse_penalty = diff_cap.T_tilde-diff_free.T_tilde;
            architecture_adv = cap.T_tilde-diff_cap.T_tilde;
            theory_adv = F.T_real-FD.T_real;

            fprintf(fid,['%s,%d,%d,%d,%d,%d,%.15g,%.15g,%.15g,%.15g,' ...
              '%.15g,%.15g,%.15g,%d,%d,%.15g,%d,%d,%.15g,%.15g,%s,%.15g,' ...
              '%.15g,%.15g,%.15g,%.15g,%d,%d,%.15g,%d,%d,%.15g,%d,%d,%d,' ...
              '%.15g,%.15g,%d,%.15g,%.15g,%d,%.15g,%d,%d,%.15g,%.15g\n'], ...
              policy,rep,dseed,lseed,n,k,h,H,ell_o,ell_s,w0,alpha,Theta,C,D,Omega, ...
              max_windows,T_max,M{ip}.Lambda,M{ip}.chi,theory{ip}.regime,theory{ip}.ell_star, ...
              F.T_real,FD.T_real,theory_adv, ...
              cap.T,cap.T_tilde,cap.delta,free.T,free.T_tilde,free.delta,capacity_penalty, ...
              cap.n_attempted,cap.n_served,cap.n_blocked,cap.blocked_fraction, ...
              cap.first_block_attempt,cap.n_windows_started,cap.Wmin, ...
              diff_cap.T,diff_cap.T_tilde,diff_cap.delta, ...
              diff_free.T,diff_free.T_tilde,diff_free.delta,diffuse_penalty,architecture_adv);

            row_count = row_count+1;
          end
        end

        % Exact CRN competence monotonicity audits. T_tilde must weakly fall as
        % specialist competence increases, both with and without capacity.
        for ie = 1:(numel(ell_s_grid)-1)
          assert(free_tildes(ie+1) <= free_tildes(ie) + 1e-12, ...
            'Free E5 trajectory violates competence monotonicity.');
          assert(free_deltas(ie+1) >= free_deltas(ie), ...
            'Free E5 event indicator violates competence monotonicity.');
          for ip = 1:2
            assert(cap_tildes(ip,ie+1) <= cap_tildes(ip,ie) + 1e-12, ...
              'Capacity E5 trajectory violates competence monotonicity.');
            assert(cap_deltas(ip,ie+1) >= cap_deltas(ip,ie), ...
              'Capacity E5 event indicator violates competence monotonicity.');
          end
        end
      end
    end
  end

  expected_rows = numel(omega_grid)*R*numel(k_grid)*numel(ell_s_grid)*2;
  assert(row_count == expected_rows,'Unexpected E5 stochastic row count.');
  fprintf('Wrote E5 competence-switching screening: %s (%d rows)\n',output_path,row_count);
end
