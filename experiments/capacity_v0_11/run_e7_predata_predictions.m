function run_e7_predata_predictions(output_path)
% RUN_E7_PREDATA_PREDICTIONS
% Frozen deterministic predictions for all E7 robustness panels.

  if nargin < 1 || isempty(output_path)
    output_path = 'results/predata/e7/e7_theory_predictions.csv';
  end

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir') ~= 7
    mkdir(out_dir);
  end
  fid = fopen(output_path,'w');
  assert(fid >= 0,'Could not open output file.');
  cleanup_obj = onCleanup(@() fclose(fid));

  header = {'panel','pairing','policy','n','C','D','Omega','h','H','Theta','K', ...
    'capacity_per_actor_uniform','Lambda_realized','chi_realized', ...
    'T_free_theory','T_theory','delay_theory','first_exhaustion_theory', ...
    'exact_T_expected','exact_delay_expected','exact_identity_note'};
  fprintf(fid,'%s\n',strjoin(header,','));

  w0 = 0.4; alpha = 0.08; ell = 1; max_windows = 20;

  % Panel A: size scaling.
  for n = [4,8,16]
    C = 15*n;
    for Omega = [0.6,1.0,1.5]
      D = round(Omega*C);
      for h = [0,0.25,0.50,0.75,0.90,1.00]
        p = one_heavy_responsibility(n,h);
        Theta = 0.8;
        K = productive_events_to_threshold(w0,alpha,Theta).K_integer;
        for policy = {'matched','uniform'}
          if strcmp(policy{1},'matched'), x = p; else, x = ones(1,n)/n; end
          [~,xr] = allocate_integer_capacity(C,x);
          M = capacity_load_metrics(D,C,p,xr);
          F = fluid_learning_readiness_symmetric(Omega,p,xr,w0,alpha,ell,Theta,C,max_windows);
          T0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta).T_real;
          [exactT,exactD,note] = exact_identity('A',policy{1},n,C,D,h,Theta,K);
          write_row(fid,header,{'A','product',policy{1},n,C,D,Omega,h,h^2,Theta,K,C/n, ...
            M.Lambda,M.chi,T0,F.T_real,F.T_real-T0,F.first_exhaustion_attempt, ...
            exactT,exactD,note});
        end
      end
    end
  end

  % Panel B: absolute capacity scale.
  n = 4; Theta = 0.8; K = productive_events_to_threshold(w0,alpha,Theta).K_integer;
  for C = [40,60,120]
    for Omega = [0.6,1.0,1.5]
      D = round(Omega*C);
      for h = [0,0.50,0.90,1.00]
        p = one_heavy_responsibility(n,h);
        for policy = {'matched','uniform'}
          if strcmp(policy{1},'matched'), x=p; else, x=ones(1,n)/n; end
          [~,xr] = allocate_integer_capacity(C,x);
          M = capacity_load_metrics(D,C,p,xr);
          F = fluid_learning_readiness_symmetric(Omega,p,xr,w0,alpha,ell,Theta,C,max_windows);
          T0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta).T_real;
          [exactT,exactD,note] = exact_identity('B',policy{1},n,C,D,h,Theta,K);
          write_row(fid,header,{'B','product',policy{1},n,C,D,Omega,h,h^2,Theta,K,C/n, ...
            M.Lambda,M.chi,T0,F.T_real,F.T_real-T0,F.first_exhaustion_attempt, ...
            exactT,exactD,note});
        end
      end
    end
  end

  % Panel C: readiness threshold.
  n=4; C=60; Omega=1; D=60;
  for Theta = [0.7,0.8,0.9]
    K = productive_events_to_threshold(w0,alpha,Theta).K_integer;
    for h = [0,0.50,0.90,1.00]
      p = one_heavy_responsibility(n,h);
      for policy = {'matched','uniform'}
        if strcmp(policy{1},'matched'), x=p; else, x=ones(1,n)/n; end
        [~,xr] = allocate_integer_capacity(C,x);
        M = capacity_load_metrics(D,C,p,xr);
        F = fluid_learning_readiness_symmetric(Omega,p,xr,w0,alpha,ell,Theta,C,max_windows);
        T0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta).T_real;
        [exactT,exactD,note] = exact_identity('C',policy{1},n,C,D,h,Theta,K);
        write_row(fid,header,{'C','product',policy{1},n,C,D,Omega,h,h^2,Theta,K,C/n, ...
          M.Lambda,M.chi,T0,F.T_real,F.T_real-T0,F.first_exhaustion_attempt, ...
          exactT,exactD,note});
      end
    end
  end

  % Panel D: pairing robustness.
  n=4; C=60; Theta=0.8; K=productive_events_to_threshold(w0,alpha,Theta).K_integer;
  for Omega = [0.6,1.0,1.5]
    D = round(Omega*C);
    for h = [0,0.50,0.75,0.90,1.00]
      p = one_heavy_responsibility(n,h);
      T0 = no_capacity_mean_crossing_real(p,w0,alpha,ell,Theta).T_real;
      for pairing = {'product','assortative'}
        for policy = {'matched','uniform'}
          if strcmp(policy{1},'matched'), x=p; else, x=ones(1,n)/n; end
          [~,xr] = allocate_integer_capacity(C,x);
          M = capacity_load_metrics(D,C,p,xr);
          if strcmp(pairing{1},'product')
            F = fluid_learning_readiness_symmetric(Omega,p,xr,w0,alpha,ell,Theta,C,max_windows);
          else
            F = fluid_learning_readiness_assortative_symmetric(Omega,p,xr,w0,alpha,ell,Theta,C,max_windows);
          end
          [exactT,exactD,note] = exact_identity('D',policy{1},n,C,D,h,Theta,K);
          write_row(fid,header,{'D',pairing{1},policy{1},n,C,D,Omega,h,h^2,Theta,K,C/n, ...
            M.Lambda,M.chi,T0,F.T_real,F.T_real-T0,F.first_exhaustion_attempt, ...
            exactT,exactD,note});
        end
      end
    end
  end

  fprintf('Wrote frozen E7 theory predictions: %s\n',output_path);
end

function [exactT,exactD,note] = exact_identity(panel,policy,n,C,D,h,Theta,K)
  exactT = NaN; exactD = NaN; note = '';
  if abs(h-1) < 1e-12
    if strcmp(policy,'matched')
      exactT = K; exactD = 0; note = 'h1_matched_single_carrier';
    else
      cap = C/n;
      if K <= cap
        exactT = K; exactD = 0; note = 'h1_uniform_learning_fits_window';
      else
        n_full = floor((K-1)/cap);
        remaining = K - n_full*cap;
        exactT = n_full*D + remaining;
        exactD = exactT-K;
        note = 'h1_uniform_learning_spans_windows';
      end
    end
  elseif abs(h) < 1e-12
    note = 'h0_matched_equals_uniform_pathwise';
  end
end

function write_row(fid,header,vals)
  assert(numel(vals) == numel(header));
  fields = cell(size(vals));
  for i = 1:numel(vals)
    v = vals{i};
    if ischar(v)
      fields{i} = v;
    elseif isnan(v)
      fields{i} = 'NaN';
    elseif isinf(v)
      if v > 0, fields{i}='Inf'; else, fields{i}='-Inf'; end
    else
      fields{i} = sprintf('%.15g',v);
    end
  end
  fprintf(fid,'%s\n',strjoin(fields,','));
end
