function run_e6_transient_shock_screening(output_path, R, k_subset)
% RUN_E6_TRANSIENT_SHOCK_SCREENING
% E6 transient first-window capacity shock under fixed Omega=0.6.
%
% PRE-DATA design:
%   docs/capacity_experiment_e6_design.md
%
% Optional k_subset exists only for execution slicing. It must be a subset of
% the frozen k grid and does not alter seeds or cell definitions.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/raw/e6_transient_shock_screening.csv';
  end
  if nargin < 2 || isempty(R)
    R = 1000;
  end

  frozen_k = [4,7,9,15];
  if nargin < 3 || isempty(k_subset)
    k_grid = frozen_k;
  else
    k_grid = k_subset(:)';
    assert(all(ismember(k_grid,frozen_k)), ...
      'k_subset must be drawn from the frozen E6 grid.');
    assert(numel(unique(k_grid)) == numel(k_grid), ...
      'k_subset must not contain duplicates.');
  end

  assert(isscalar(R) && R >= 1 && R == floor(R), ...
    'R must be a positive integer.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  n = 4;
  w0 = 0.4;
  alpha = 0.08;
  ell_o = 0.70;
  ell_s_grid = [0.70,0.90,1.00];
  Theta = 0.8;
  C = 60;
  Omega = 0.6;
  D = round(Omega*C);
  max_windows = 20;
  T_max = D*max_windows;
  gamma_grid = [1.0,0.8,0.6,0.5,0.4];

  assert(abs(D/C-Omega) < 1e-12);
  for gamma = gamma_grid
    assert(abs(gamma*C-round(gamma*C)) < 1e-12, ...
      'Every frozen E6 gamma must retain an integer module total capacity.');
  end

  pD = ones(1,n)/n;
  xD = pD;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file: %s',output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  header = { ...
    'policy','replication','demand_seed','learning_seed','n','k','h','H', ...
    'ell_o','ell_s','w0','alpha','Theta','C','D','Omega','max_windows','T_max', ...
    'Lambda','chi','gamma','gamma_real','C_shock','chi_shock_fluid', ...
    'T_shock','T_shock_tilde','delta_shock','T_noshock','T_noshock_tilde', ...
    'delta_noshock','shock_delay_tilde','negative_delay_indicator', ...
    'n_attempted','n_served','n_blocked','blocked_fraction', ...
    'n_attempted_shock','n_served_shock','n_blocked_shock','shock_blocked_fraction', ...
    'first_block_attempt_shock','n_productive_A_shock','n_productive_B_shock','Wmin_final', ...
    'diffuse_T_shock','diffuse_T_shock_tilde','diffuse_delta_shock', ...
    'diffuse_T_noshock_tilde','diffuse_shock_delay_tilde', ...
    'diffuse_shock_blocked_fraction','architecture_advantage_tilde'};
  fprintf(fid,'%s\n',strjoin(header,','));

  row_count = 0;

  for rep = 1:R
    % Diffuse benchmark uses a frozen seed family independent of k and ell_s.
    dseedD = 760000000 + rep;
    lseedD = 860000000 + rep;
    diff_runs = cell(1,numel(gamma_grid));
    for ig = 1:numel(gamma_grid)
      diff_runs{ig} = simulate_transient_capacity_shock_readiness( ...
        pD,pD,xD,xD,w0,alpha,ell_o,ell_o,Theta,C,D,max_windows, ...
        gamma_grid(ig),dseedD,lseedD);
      assert(abs(diff_runs{ig}.gamma_real_A-gamma_grid(ig)) < 1e-12);
      assert(abs(diff_runs{ig}.gamma_real_B-gamma_grid(ig)) < 1e-12);
    end
    diff_base = diff_runs{1};

    for ik = 1:numel(k_grid)
      k = k_grid(ik);
      h = k/15;
      H = h^2;
      p = one_heavy_responsibility(n,h);

      for ie = 1:numel(ell_s_grid)
        ell_s = ell_s_grid(ie);
        ell = ell_o*ones(1,n);
        ell(1) = ell_s;

        dseed = 760000000 + k*1000000 + ie*10000 + rep;
        lseed = 860000000 + k*1000000 + ie*10000 + rep;

        policies = {'matched','uniform'};
        xpol = {p,xD};

        for ip = 1:2
          policy = policies{ip};
          x = xpol{ip};
          M = capacity_load_metrics(D,C,p,x);

          shock_runs = cell(1,numel(gamma_grid));
          for ig = 1:numel(gamma_grid)
            shock_runs{ig} = simulate_transient_capacity_shock_readiness( ...
              p,p,x,x,w0,alpha,ell,ell,Theta,C,D,max_windows, ...
              gamma_grid(ig),dseed,lseed);
            assert(abs(shock_runs{ig}.gamma_real_A-gamma_grid(ig)) < 1e-12);
            assert(abs(shock_runs{ig}.gamma_real_B-gamma_grid(ig)) < 1e-12);
          end
          base = shock_runs{1};

          for ig = 1:numel(gamma_grid)
            gamma = gamma_grid(ig);
            s = shock_runs{ig};
            d = diff_runs{ig};

            shock_delay = s.T_tilde-base.T_tilde;
            diff_delay = d.T_tilde-diff_base.T_tilde;
            arch_adv = s.T_tilde-d.T_tilde;
            neg = double(shock_delay < 0);
            if gamma > 0
              chi_shock = M.chi/gamma;
            else
              chi_shock = Inf;
            end

            fields = { ...
              policy, csv_num(rep), csv_num(dseed), csv_num(lseed), csv_num(n), ...
              csv_num(k), csv_num(h), csv_num(H), csv_num(ell_o), csv_num(ell_s), ...
              csv_num(w0), csv_num(alpha), csv_num(Theta), csv_num(C), csv_num(D), ...
              csv_num(Omega), csv_num(max_windows), csv_num(T_max), ...
              csv_num(M.Lambda), csv_num(M.chi), csv_num(gamma), ...
              csv_num(s.gamma_real_A), csv_num(sum(s.cA_shock)), csv_num(chi_shock), ...
              csv_num(s.T), csv_num(s.T_tilde), csv_num(s.delta), ...
              csv_num(base.T), csv_num(base.T_tilde), csv_num(base.delta), ...
              csv_num(shock_delay), csv_num(neg), ...
              csv_num(s.n_attempted), csv_num(s.n_served), csv_num(s.n_blocked), ...
              csv_num(s.blocked_fraction), csv_num(s.n_attempted_shock), ...
              csv_num(s.n_served_shock), csv_num(s.n_blocked_shock), ...
              csv_num(s.shock_blocked_fraction), csv_num(s.first_block_attempt_shock), ...
              csv_num(s.n_productive_A_shock), csv_num(s.n_productive_B_shock), ...
              csv_num(s.Wmin), csv_num(d.T), csv_num(d.T_tilde), csv_num(d.delta), ...
              csv_num(diff_base.T_tilde), csv_num(diff_delay), ...
              csv_num(d.shock_blocked_fraction), csv_num(arch_adv)};

            assert(numel(fields) == numel(header));
            fprintf(fid,'%s\n',strjoin(fields,','));
            row_count = row_count + 1;
          end
        end
      end
    end
  end

  expected_rows = R*numel(k_grid)*numel(ell_s_grid)*2*numel(gamma_grid);
  assert(row_count == expected_rows,'Unexpected E6 raw row count.');
  fprintf('Wrote E6 transient shock screening: %s (%d rows)\n',output_path,row_count);
end

function s = csv_num(v)
  if isnan(v)
    s = 'NaN';
  elseif isinf(v)
    if v > 0
      s = 'Inf';
    else
      s = '-Inf';
    end
  else
    s = sprintf('%.15g',v);
  end
end
