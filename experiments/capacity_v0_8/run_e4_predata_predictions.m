function run_e4_predata_predictions(output_path)
% RUN_E4_PREDATA_PREDICTIONS
% Deterministic Model v0.8 predictions for the preregistered E4 grid.
% This file contains no stochastic E4 results.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/processed/e4_predata_predictions.csv';
  end

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
  x_uniform = ones(1,n)/n;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid,['policy,k,h,H,alpha,primary_oos,C,D,Omega,e3_omega_index,' ...
    'Lambda,chi,t0_real,t0_integer,Psi,first_exhaustion_attempt,' ...
    'T_fluid,fluid_delay_vs_t0\n']);

  e3_omega_index = [2,4,6];
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
        assert(abs(D/C-Omega) < 1e-12,'E4 Omega must be integer-compatible with C.');

        policies = {'matched','uniform'};
        for ip = 1:2
          policy = policies{ip};
          if ip == 1
            x = p;
          else
            x = x_uniform;
          end

          M = capacity_load_metrics(D,C,p,x);
          F = fluid_learning_readiness_symmetric( ...
            Omega,p,x,w0,alpha,ell,Theta,C,max_windows);
          assert(F.delta == 1, ...
            'v0.8 E4 prediction did not cross: k=%d alpha=%g Omega=%g %s.', ...
            k,alpha,Omega,policy);

          Psi = M.Lambda*N0.t_cross/C;
          fluid_delay = F.T_real-N0.t_cross;
          if abs(fluid_delay) < 1e-10
            fluid_delay = 0;
          end
          assert(fluid_delay >= -1e-8, ...
            'Deterministic capacity prediction cannot accelerate no-capacity learning.');

          fprintf(fid,['%s,%d,%.15g,%.15g,%.15g,%d,%d,%d,%.15g,%d,' ...
            '%.15g,%.15g,%.15g,%d,%.15g,%.15g,%.15g,%.15g\n'], ...
            policy,k,h,H,alpha,primary_oos,C,D,Omega,e3_omega_index(io), ...
            M.Lambda,M.chi,N0.t_cross,I0.T_mean_cross,Psi, ...
            F.first_exhaustion_attempt,F.T_real,fluid_delay);
          row_count = row_count+1;
        end
      end
    end
  end

  assert(row_count == 168,'Unexpected E4 pre-data prediction row count.');
  fprintf('Wrote E4 pre-data predictions: %s (%d rows)\n',output_path,row_count);
end
