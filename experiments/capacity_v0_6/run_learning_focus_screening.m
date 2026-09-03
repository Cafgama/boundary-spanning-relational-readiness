function run_learning_focus_screening(output_path, R)
% RUN_LEARNING_FOCUS_SCREENING
% E2: responsibility concentration -> learning focus, without capacity blocking.
%
% Usage:
%   run_learning_focus_screening('results/raw/e2_learning_focus.csv', 1000)

  if nargin < 1 || isempty(output_path)
    output_path = 'results/raw/e2_learning_focus_screening.csv';
  end
  if nargin < 2 || isempty(R)
    R = 1000;
  end

  assert(isscalar(R) && R >= 1 && R == floor(R), ...
    'R must be a positive integer.');

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'src', 'capacity'));

  n = 4;
  w0 = 0.4;
  alpha = 0.08;
  ell = 1.0;
  Theta = 0.8;
  T_max = 300;
  h_grid = 0:0.1:0.9;

  out_dir = fileparts(output_path);
  if ~isempty(out_dir) && exist(out_dir, 'dir') ~= 7
    mkdir(out_dir);
  end

  fid = fopen(output_path, 'w');
  assert(fid >= 0, 'Could not open output file: %s', output_path);
  cleanup_obj = onCleanup(@() fclose(fid));

  fprintf(fid, ['replication,demand_seed,learning_seed,n,h,H,S2,w0,alpha,ell,Theta,T_max,' ...
    'initial_increment,T_mean_cross,TA,TB,T,T_tilde,delta,WA_final,WB_final,Wmin_final\n']);

  for ih = 1:numel(h_grid)
    h = h_grid(ih);
    p = one_heavy_responsibility(n, h);
    H = h^2;
    S2 = sum(p.^2);
    M1 = no_capacity_mean_readiness(1, p, w0, alpha, ell);
    initial_increment = M1.initial_increment;
    F = no_capacity_mean_first_passage(p, w0, alpha, ell, Theta, T_max);

    assert(F.delta == 1, 'Analytical mean readiness failed to cross for h=%g.', h);

    for rep = 1:R
      demand_seed = 220000000 + ih * 100000 + rep;
      learning_seed = 320000000 + ih * 100000 + rep;

      out = simulate_no_capacity_interface_readiness( ...
        p, p, w0, alpha, ell, ell, Theta, T_max, demand_seed, learning_seed);

      fprintf(fid, ['%d,%d,%d,%d,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%d,' ...
        '%.15g,%d,%.15g,%.15g,%.15g,%d,%d,%.15g,%.15g,%.15g\n'], ...
        rep, demand_seed, learning_seed, n, h, H, S2, w0, alpha, ell, Theta, T_max, ...
        initial_increment, F.T_mean_cross, out.TA, out.TB, out.T, out.T_tilde, out.delta, ...
        out.WA, out.WB, out.Wmin);
    end
  end

  fprintf('Wrote E2 learning-focus screening: %s (%d rows)\n', ...
    output_path, numel(h_grid) * R);
end
