function run_learning_congestion_screening(output_path, R)
% RUN_LEARNING_CONGESTION_SCREENING
% E3: responsibility-learning focus x finite capacity congestion.
%
% Usage:
%   run_learning_congestion_screening('results/raw/e3_learning_congestion.csv', 200)
%
% PRE-DATA design is documented in docs/capacity_experiment_e3_design.md.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/raw/e3_learning_congestion_screening.csv';
  end
  if nargin < 2 || isempty(R)
    R = 200;
  end
  assert(isscalar(R) && R >= 1 && R == floor(R), 'R must be a positive integer.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'src', 'capacity'));

  n = 4;
  w0 = 0.4;
  alpha = 0.08;
  ell = 1.0;
  Theta = 0.8;
  C = 60;
  max_windows = 10;
  k_grid = 0:15;
  omega_grid = [0.4,0.6,0.8,1.0,1.2,1.5,2.0];
  x_uniform = ones(1,n)/n;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end

  fid = fopen(output_path,'w');
  assert(fid >= 0, 'Could not open output file: %s', output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid, ['policy,replication,demand_seed,n,k,h,H,w0,alpha,ell,Theta,C,D,Omega,max_windows,T_max,' ...
    'Lambda,chi,t0_real,t0_integer,Psi,T_capacity,T_capacity_tilde,delta_capacity,' ...
    'T_free,T_free_tilde,delta_free,DeltaT,n_attempted,n_served,n_blocked,blocked_fraction,' ...
    'any_block,first_block_attempt,n_windows_started,Wmin_final\n']);

  row_count = 0;

  for ik = 1:numel(k_grid)
    k = k_grid(ik);
    h = k/15;
    p = one_heavy_responsibility(n,h);
    H = h^2;

    F_real = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta,300,1e-11);
    F_int = no_capacity_mean_first_passage(p,w0,alpha,ell,Theta,300);
    assert(F_real.delta == 1 && F_int.delta == 1, ...
      'Analytical no-capacity readiness failed to cross for h=%g.', h);

    for io = 1:numel(omega_grid)
      Omega = omega_grid(io);
      D = round(Omega*C);
      assert(abs(D/C-Omega) < 1e-12, 'Omega grid must be integer-compatible with C.');
      T_max = D*max_windows;

      for rep = 1:R
        demand_seed = 430000000 + ik*1000000 + io*10000 + rep;

        free = simulate_no_capacity_interface_readiness_fast_ell1( ...
          p,p,w0,alpha,Theta,T_max,demand_seed);

        policies = {'matched','uniform'};
        for ip = 1:2
          policy = policies{ip};
          if ip == 1
            x = p;
          else
            x = x_uniform;
          end

          cap = simulate_capacity_learning_readiness_fast_ell1( ...
            p,p,x,x,w0,alpha,Theta,C,D,max_windows,demand_seed);

          Lambda = cap.Lambda_realized;
          chi = cap.chi_realized;
          Psi = Lambda*F_real.t_cross/C;

          if cap.delta == 1
            assert(free.delta == 1, ...
              'Capacity trajectory cannot reach readiness if its paired free trajectory is censored.');
            DeltaT = cap.T-free.T;
            assert(DeltaT >= 0, ...
              'Pathwise monotonicity violated: capacity trajectory reached readiness before free trajectory.');
          else
            DeltaT = NaN;
          end

          any_block = double(cap.n_blocked > 0);

          fprintf(fid, ['%s,%d,%d,%d,%d,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%d,%d,%.15g,%d,%d,' ...
            '%.15g,%.15g,%.15g,%d,%.15g,%.15g,%d,%d,%.15g,%d,%d,%.15g,%d,%d,%d,%d,%.15g,%d,%.15g,%d,%.15g\n'], ...
            policy,rep,demand_seed,n,k,h,H,w0,alpha,ell,Theta,C,D,Omega,max_windows,T_max, ...
            Lambda,chi,F_real.t_cross,F_int.T_mean_cross,Psi,cap.T,cap.T_tilde,cap.delta, ...
            free.T,free.T_tilde,free.delta,DeltaT,cap.n_attempted,cap.n_served,cap.n_blocked, ...
            cap.blocked_fraction,any_block,cap.first_block_attempt,cap.n_windows_started,cap.Wmin);

          row_count = row_count+1;
        end
      end
    end
  end

  expected_rows = numel(k_grid)*numel(omega_grid)*2*R;
  assert(row_count == expected_rows, 'Unexpected E3 row count.');
  fprintf('Wrote E3 learning-congestion screening: %s (%d rows)\n', output_path, row_count);
end
