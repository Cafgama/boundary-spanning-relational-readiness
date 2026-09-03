function run_e5_predata_competence_map(output_path)
% RUN_E5_PREDATA_COMPETENCE_MAP
% Full deterministic Model v0.8/v0.9 competence-switching map for E5.
% No stochastic E5 results are used or generated here.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/processed/e5_predata_competence_map.csv';
  end

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
  omega_grid = [0.6,1.0,1.5];
  ell_grid = [0.70,0.80,0.90,1.00];
  pD = ones(1,n)/n;
  xD = pD;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid,['policy,k,h,H,Omega,C,Lambda,chi,ell_o,regime,ell_star,' ...
    'T_diffuse,T_ell_070,T_ell_080,T_ell_090,T_ell_100,' ...
    'adv_ell_070,adv_ell_080,adv_ell_090,adv_ell_100\n']);

  row_count = 0;
  for k = 1:15
    h = k/15;
    p = one_heavy_responsibility(n,h);
    H = h^2;

    for io = 1:numel(omega_grid)
      Omega = omega_grid(io);
      D = round(Omega*C);
      assert(abs(D/C-Omega) < 1e-12,'Omega must be integer-compatible with C.');

      policies = {'matched','uniform'};
      for ip = 1:2
        policy = policies{ip};
        if ip == 1
          x = p;
        else
          x = xD;
        end

        M = capacity_load_metrics(D,C,p,x);
        S = competence_switching_threshold( ...
          p,x,pD,xD,w0,alpha,ell_o,Theta,C,Omega,max_windows,1e-8);

        Tgrid = zeros(1,numel(ell_grid));
        for ie = 1:numel(ell_grid)
          ell = ell_o * ones(1,n);
          ell(1) = ell_grid(ie);
          F = fluid_learning_readiness_symmetric( ...
            Omega,p,x,w0,alpha,ell,Theta,C,max_windows);
          assert(F.delta == 1,'E5 deterministic grid failed to cross.');
          Tgrid(ie) = F.T_real;
        end

        adv = Tgrid - S.T_diffuse;
        fprintf(fid,['%s,%d,%.15g,%.15g,%.15g,%d,%.15g,%.15g,%.15g,%s,%.15g,' ...
          '%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g\n'], ...
          policy,k,h,H,Omega,C,M.Lambda,M.chi,ell_o,S.regime,S.ell_star, ...
          S.T_diffuse,Tgrid(1),Tgrid(2),Tgrid(3),Tgrid(4), ...
          adv(1),adv(2),adv(3),adv(4));
        row_count = row_count + 1;
      end
    end
  end

  assert(row_count == 90,'Unexpected E5 deterministic map row count.');
  fprintf('Wrote E5 pre-data competence map: %s (%d rows)\n',output_path,row_count);
end
