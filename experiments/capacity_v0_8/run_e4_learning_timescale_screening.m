function run_e4_learning_timescale_screening(output_path, R)
% RUN_E4_LEARNING_TIMESCALE_SCREENING
% E4 out-of-sample learning-timescale validation.
%
% PRE-DATA design: docs/capacity_experiment_e4_design.md
% Primary new alphas: 0.06, 0.10, 0.12. Alpha=0.08 is an E3 bridge layer.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/raw/e4_learning_timescale_screening.csv';
  end
  if nargin < 2 || isempty(R)
    R = 200;
  end
  assert(isscalar(R) && R >= 1 && R == floor(R),'R must be a positive integer.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  n = 4;
  w0 = 0.4;
  ell = 1.0;
  Theta = 0.8;
  C = 60;
  max_windows = 10;
  k_grid = [0,4,7,10,13,14,15];
  alpha_grid = [0.06,0.08,0.10,0.12];
  omega_grid = [0.6,1.0,1.5];
  e3_omega_index = [2,4,6];
  x_uniform = ones(1,n)/n;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid,['policy,replication,demand_seed,n,k,h,H,w0,alpha,primary_oos,ell,Theta,' ...
    'C,D,Omega,e3_omega_index,max_windows,T_max,Lambda,chi,t0_real,t0_integer,Psi,' ...
    'T_fluid,fluid_delay_vs_t0,T_capacity,T_capacity_tilde,delta_capacity,' ...
    'T_free,T_free_tilde,delta_free,DeltaT,n_attempted,n_served,n_blocked,' ...
    'blocked_fraction,any_block,first_block_attempt,n_windows_started,Wmin_final\n']);

  row_count = 0;

  for ik = 1:numel(k_grid)
    k = k_grid(ik);
    h = k/15;
    p = one_heavy_responsibility(n,h);
    H = h^2;

    for ia = 1:numel(alpha_grid)
      alpha = alpha_grid(ia);
      primary_oos = double(abs(alpha-0.08) > 1e-12);
      N0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta,400,1e-11);
      I0 = no_capacity_mean_first_passage(p,w0,alpha,ell,Theta,400);
      assert(N0.delta == 1 && I0.delta == 1, ...
        'No-capacity analytical crossing failed for k=%d alpha=%g.',k,alpha);

      for io = 1:numel(omega_grid)
        Omega = omega_grid(io);
        D = round(Omega*C);
        T_max = D*max_windows;
        assert(abs(D/C-Omega) < 1e-12,'E4 Omega must be integer-compatible with C.');

        % Theory is computed once per cell, before any stochastic replication.
        theory = struct();
        policies = {'matched','uniform'};
        for ip = 1:2
          if ip == 1
            x = p;
          else
            x = x_uniform;
          end
          M = capacity_load_metrics(D,C,p,x);
          F = fluid_learning_readiness_symmetric( ...
            Omega,p,x,w0,alpha,ell,Theta,C,max_windows);
          assert(F.delta == 1,'v0.8 E4 prediction failed to cross.');
          theory(ip).Lambda = M.Lambda;
          theory(ip).chi = M.chi;
          theory(ip).Psi = M.Lambda*N0.t_cross/C;
          theory(ip).T_fluid = F.T_real;
          theory(ip).fluid_delay = max(0,F.T_real-N0.t_cross);
        end

        for rep = 1:R
          % Exact E3 seed schedule for selected cells. Alpha is intentionally absent
          % so trajectories are paired across learning rates.
          demand_seed = 430000000 + (k+1)*1000000 + e3_omega_index(io)*10000 + rep;

          free = simulate_no_capacity_interface_readiness_fast_ell1( ...
            p,p,w0,alpha,Theta,T_max,demand_seed);

          for ip = 1:2
            policy = policies{ip};
            if ip == 1
              x = p;
            else
              x = x_uniform;
            end

            cap = simulate_capacity_learning_readiness_fast_ell1( ...
              p,p,x,x,w0,alpha,Theta,C,D,max_windows,demand_seed);

            assert(abs(cap.Lambda_realized-theory(ip).Lambda) < 1e-12, ...
              'Realized Lambda differs from preregistered E4 prediction.');
            assert(abs(cap.chi_realized-theory(ip).chi) < 1e-12, ...
              'Realized chi differs from preregistered E4 prediction.');

            if cap.delta == 1
              assert(free.delta == 1, ...
                'Capacity trajectory cannot reach readiness if paired free trajectory is censored.');
              DeltaT = cap.T-free.T;
              assert(DeltaT >= 0, ...
                'Pathwise monotonicity violated in E4.');
            else
              DeltaT = NaN;
            end

            any_block = double(cap.n_blocked > 0);

            % 40 fields for 40 declared columns.
            fprintf(fid,['%s,%d,%d,%d,%d,%.15g,%.15g,%.15g,%.15g,%d,%.15g,%.15g,' ...
              '%d,%d,%.15g,%d,%d,%d,%.15g,%.15g,%.15g,%d,%.15g,%.15g,%.15g,' ...
              '%.15g,%d,%d,%.15g,%d,%d,%.15g,%d,%d,%d,%.15g,%d,%.15g,%d,%.15g\n'], ...
              policy,rep,demand_seed,n,k,h,H,w0,alpha,primary_oos,ell,Theta, ...
              C,D,Omega,e3_omega_index(io),max_windows,T_max, ...
              theory(ip).Lambda,theory(ip).chi,N0.t_cross,I0.T_mean_cross,theory(ip).Psi, ...
              theory(ip).T_fluid,theory(ip).fluid_delay, ...
              cap.T,cap.T_tilde,cap.delta,free.T,free.T_tilde,free.delta,DeltaT, ...
              cap.n_attempted,cap.n_served,cap.n_blocked,cap.blocked_fraction,any_block, ...
              cap.first_block_attempt,cap.n_windows_started,cap.Wmin);
            row_count = row_count+1;
          end
        end
      end
    end
  end

  expected_rows = numel(k_grid)*numel(alpha_grid)*numel(omega_grid)*2*R;
  assert(row_count == expected_rows,'Unexpected E4 stochastic row count.');
  fprintf('Wrote E4 learning-timescale screening: %s (%d rows)\n',output_path,row_count);
end
