function run_e7_robustness_panel(output_path, R, panel, slice_value)
% RUN_E7_ROBUSTNESS_PANEL
% Frozen stochastic E7 robustness runner.
%
% panel = 'A' size scaling
%         'B' absolute capacity scale
%         'C' readiness threshold
%         'D' pairing robustness
%
% slice_value is execution-only:
%   A -> one n value
%   B -> one C value
%   C -> one Theta value
%   D -> 'product' or 'assortative'

  if nargin < 1 || isempty(output_path), output_path='results/raw/e7_robustness.csv'; end
  if nargin < 2 || isempty(R), R=500; end
  if nargin < 3 || isempty(panel), error('panel is required'); end
  if nargin < 4, slice_value=[]; end
  assert(isscalar(R) && R>=1 && R==floor(R),'R must be a positive integer.');

  panel = upper(strtrim(panel));
  assert(any(strcmp(panel,{'A','B','C','D'})),'Unknown E7 panel.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root,'src','capacity'));

  out_dir=fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir,'dir')~=7, mkdir(out_dir); end
  fid=fopen(output_path,'w');
  assert(fid>=0,'Could not open output file.');
  cleanup_obj=onCleanup(@() fclose(fid));

  header={'panel','pairing','policy','replication','demand_seed','n','C','D','Omega','h','H', ...
    'Theta','K','T','T_tilde','delta','Lambda_realized','chi_realized','n_attempted', ...
    'n_served','n_blocked','blocked_fraction','first_block_attempt'};
  fprintf(fid,'%s\n',strjoin(header,','));

  w0=.4; alpha=.08; max_windows=20;
  row_count=0;

  switch panel
    case 'A'
      ngrid=[4,8,16]; Ogrid=[.6,1,1.5]; hgrid=[0,.25,.5,.75,.9,1]; Theta=.8;
      if ~isempty(slice_value)
        assert(isnumeric(slice_value) && isscalar(slice_value) && any(ngrid==slice_value), ...
          'Panel A slice_value must be a frozen n.');
        nrun=slice_value;
      else
        nrun=ngrid;
      end
      for n=nrun
        in=find(ngrid==n,1); C=15*n; K=productive_events_to_threshold(w0,Theta,alpha).k_required;
        for io=1:numel(Ogrid)
          Omega=Ogrid(io); D=round(Omega*C);
          for ih=1:numel(hgrid)
            h=hgrid(ih); p=one_heavy_responsibility(n,h);
            for rep=1:R
              seed=711000000 + in*1000000 + io*100000 + ih*10000 + rep;
              outs=run_policies_product(p,w0,alpha,Theta,C,D,max_windows,seed);
              if abs(h)<1e-12, assert_same_policy_path(outs{1},outs{2}); end
              if abs(h-1)<1e-12, assert(outs{1}.T==14 && outs{2}.T==14); end
              for ip=1:2
                write_out(fid,header,'A','product',policy_name(ip),rep,seed,n,C,D,Omega,h,Theta,K,outs{ip});
                row_count=row_count+1;
              end
            end
          end
        end
      end

    case 'B'
      n=4; Cgrid=[40,60,120]; Ogrid=[.6,1,1.5]; hgrid=[0,.5,.9,1]; Theta=.8;
      if ~isempty(slice_value)
        assert(isnumeric(slice_value) && isscalar(slice_value) && any(Cgrid==slice_value), ...
          'Panel B slice_value must be a frozen C.');
        Crun=slice_value;
      else
        Crun=Cgrid;
      end
      K=productive_events_to_threshold(w0,Theta,alpha).k_required;
      for C=Crun
        ic=find(Cgrid==C,1);
        for io=1:numel(Ogrid)
          Omega=Ogrid(io); D=round(Omega*C);
          for ih=1:numel(hgrid)
            h=hgrid(ih); p=one_heavy_responsibility(n,h);
            for rep=1:R
              seed=712000000 + ic*1000000 + io*100000 + ih*10000 + rep;
              outs=run_policies_product(p,w0,alpha,Theta,C,D,max_windows,seed);
              if abs(h)<1e-12, assert_same_policy_path(outs{1},outs{2}); end
              if abs(h-1)<1e-12
                assert(outs{1}.T==14);
                cap=C/n;
                if K<=cap, expected=K; else, expected=floor((K-1)/cap)*D + (K-floor((K-1)/cap)*cap); end
                assert(outs{2}.T==expected);
              end
              for ip=1:2
                write_out(fid,header,'B','product',policy_name(ip),rep,seed,n,C,D,Omega,h,Theta,K,outs{ip});
                row_count=row_count+1;
              end
            end
          end
        end
      end

    case 'C'
      n=4; C=60; D=60; Omega=1; Tgrid=[.7,.8,.9]; hgrid=[0,.5,.9,1];
      if ~isempty(slice_value)
        assert(isnumeric(slice_value) && isscalar(slice_value) && any(abs(Tgrid-slice_value)<1e-12), ...
          'Panel C slice_value must be a frozen Theta.');
        Trun=slice_value;
      else
        Trun=Tgrid;
      end
      for Theta=Trun
        it=find(abs(Tgrid-Theta)<1e-12,1); K=productive_events_to_threshold(w0,Theta,alpha).k_required;
        for ih=1:numel(hgrid)
          h=hgrid(ih); p=one_heavy_responsibility(n,h);
          for rep=1:R
            seed=713000000 + it*1000000 + ih*10000 + rep;
            outs=run_policies_product(p,w0,alpha,Theta,C,D,max_windows,seed);
            if abs(h)<1e-12, assert_same_policy_path(outs{1},outs{2}); end
            if abs(h-1)<1e-12
              assert(outs{1}.T==K);
              cap=C/n;
              if K<=cap, expected=K; else, expected=floor((K-1)/cap)*D + (K-floor((K-1)/cap)*cap); end
              assert(outs{2}.T==expected);
            end
            for ip=1:2
              write_out(fid,header,'C','product',policy_name(ip),rep,seed,n,C,D,Omega,h,Theta,K,outs{ip});
              row_count=row_count+1;
            end
          end
        end
      end

    case 'D'
      n=4; C=60; Ogrid=[.6,1,1.5]; hgrid=[0,.5,.75,.9,1]; Theta=.8;
      modes={'product','assortative'};
      if ~isempty(slice_value)
        assert(ischar(slice_value) && any(strcmp(slice_value,modes)), ...
          'Panel D slice_value must be product or assortative.');
        moderun={slice_value};
      else
        moderun=modes;
      end
      K=productive_events_to_threshold(w0,Theta,alpha).k_required;
      for io=1:numel(Ogrid)
        Omega=Ogrid(io); D=round(Omega*C);
        for ih=1:numel(hgrid)
          h=hgrid(ih); p=one_heavy_responsibility(n,h);
          for rep=1:R
            seed=714000000 + io*1000000 + ih*10000 + rep;
            for im=1:numel(moderun)
              mode=moderun{im};
              outs=run_policies_pairing(p,w0,alpha,Theta,C,D,max_windows,seed,mode);
              if abs(h)<1e-12, assert_same_policy_path(outs{1},outs{2}); end
              if abs(h-1)<1e-12, assert(outs{1}.T==14 && outs{2}.T==14); end
              for ip=1:2
                write_out(fid,header,'D',mode,policy_name(ip),rep,seed,n,C,D,Omega,h,Theta,K,outs{ip});
                row_count=row_count+1;
              end
            end
          end
        end
      end
  end

  fprintf('Wrote E7 panel %s: %s (%d rows)\n',panel,output_path,row_count);
end

function outs=run_policies_product(p,w0,alpha,Theta,C,D,max_windows,seed)
  n=numel(p); xu=ones(1,n)/n;
  outs=cell(1,2);
  outs{1}=simulate_capacity_learning_readiness_fast_ell1(p,p,p,p,w0,alpha,Theta,C,D,max_windows,seed);
  outs{2}=simulate_capacity_learning_readiness_fast_ell1(p,p,xu,xu,w0,alpha,Theta,C,D,max_windows,seed);
end

function outs=run_policies_pairing(p,w0,alpha,Theta,C,D,max_windows,seed,mode)
  n=numel(p); xu=ones(1,n)/n; lseed=seed+100000000;
  outs=cell(1,2);
  outs{1}=simulate_capacity_learning_readiness_pairing(p,p,p,p,w0,alpha,1,1,Theta,C,D,max_windows,seed,lseed,mode);
  outs{2}=simulate_capacity_learning_readiness_pairing(p,p,xu,xu,w0,alpha,1,1,Theta,C,D,max_windows,seed,lseed,mode);
end

function assert_same_policy_path(a,b)
  assert(isequaln(a.T,b.T));
  assert(a.T_tilde==b.T_tilde && a.delta==b.delta);
  assert(a.n_served==b.n_served && a.n_blocked==b.n_blocked);
end

function s=policy_name(ip)
  if ip==1, s='matched'; else, s='uniform'; end
end

function write_out(fid,header,panel,pairing,policy,rep,seed,n,C,D,Omega,h,Theta,K,o)
  vals={panel,pairing,policy,rep,seed,n,C,D,Omega,h,h^2,Theta,K,o.T,o.T_tilde,o.delta, ...
    o.Lambda_realized,o.chi_realized,o.n_attempted,o.n_served,o.n_blocked,o.blocked_fraction,o.first_block_attempt};
  assert(numel(vals)==numel(header));
  fields=cell(size(vals));
  for i=1:numel(vals)
    v=vals{i};
    if ischar(v), fields{i}=v;
    elseif isnan(v), fields{i}='NaN';
    elseif isinf(v), if v>0, fields{i}='Inf'; else, fields{i}='-Inf'; end
    else, fields{i}=sprintf('%.15g',v); end
  end
  fprintf(fid,'%s\n',strjoin(fields,','));
end
