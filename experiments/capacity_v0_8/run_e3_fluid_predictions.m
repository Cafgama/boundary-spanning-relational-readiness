function run_e3_fluid_predictions(output_path)
% RUN_E3_FLUID_PREDICTIONS
% Generate deterministic Model v0.8 predictions on the already-completed E3 grid.
% This is a post-E3 mechanistic validation, not a preregistered E3 prediction.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/processed/e3_fluid_learning_predictions.csv';
  end

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

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
  assert(fid >= 0, 'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid,['policy,k,h,H,C,D,Omega,Lambda,chi,t0_real,Psi,' ...
    'first_exhaustion_attempt,T_fluid,fluid_delay_vs_t0\n']);

  row_count = 0;
  for ik = 1:numel(k_grid)
    k = k_grid(ik);
    h = k/15;
    p = one_heavy_responsibility(n,h);
    H = h^2;
    N0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta,300,1e-11);
    assert(N0.delta == 1, 'No-capacity mean crossing failed for h=%g.',h);

    for io = 1:numel(omega_grid)
      Omega = omega_grid(io);
      D = round(Omega*C);
      policies = {'matched','uniform'};

      for ip = 1:2
        policy = policies{ip};
        if ip == 1
          x = p;
        else
          x = x_uniform;
        end

        M = capacity_load_metrics(D,C,p,x);
        F = fluid_learning_readiness_symmetric(Omega,p,x,w0,alpha,ell,Theta,C,max_windows);
        assert(F.delta == 1, 'Fluid-learning crossing failed for h=%g Omega=%g %s.',h,Omega,policy);

        Psi = M.Lambda*N0.t_cross/C;
        fluid_delay = F.T_real-N0.t_cross;
        if abs(fluid_delay) < 1e-10
          fluid_delay = 0;
        end
        assert(fluid_delay >= -1e-8, 'Fluid capacity cannot accelerate the no-capacity mean trajectory.');

        fprintf(fid,'%s,%d,%.15g,%.15g,%d,%d,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g\n', ...
          policy,k,h,H,C,D,Omega,M.Lambda,M.chi,N0.t_cross,Psi, ...
          F.first_exhaustion_attempt,F.T_real,fluid_delay);
        row_count = row_count+1;
      end
    end
  end

  assert(row_count == 224, 'Unexpected v0.8 E3-grid prediction row count.');
  fprintf('Wrote v0.8 E3-grid predictions: %s (%d rows)\n',output_path,row_count);
end
