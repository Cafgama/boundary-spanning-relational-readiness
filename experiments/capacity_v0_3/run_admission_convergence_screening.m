function output_file = run_admission_convergence_screening(output_file, R)
  % RUN_ADMISSION_CONVERGENCE_SCREENING
  % E1 screening experiment: finite-window admission versus fluid theory.
  %
  % Octave generates raw replication-level data only. Statistical summaries
  % and figures are produced separately in Python.

  if nargin < 2 || isempty(R)
    R = 200;
  end

  tol = 1e-12;
  assert(isscalar(R) && isfinite(R) && R >= 1 && ...
         abs(R - round(R)) <= tol, ...
    'R must be a positive integer replication count.');
  R = round(R);

  this_file = mfilename('fullpath');
  this_dir = fileparts(this_file);
  repo_root = fileparts(fileparts(this_dir));
  addpath(fullfile(repo_root, 'src', 'capacity'));

  if nargin < 1 || isempty(output_file)
    output_dir = fullfile(repo_root, 'results', 'raw', 'capacity_v0_3');
    if ~exist(output_dir, 'dir')
      mkdir(output_dir);
    end
    output_file = fullfile(output_dir, 'e1_admission_convergence_screening.csv');
  else
    [output_dir, ~, ~] = fileparts(output_file);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
      mkdir(output_dir);
    end
  end

  condition_names = {
    'diffuse_matched',
    'concentrated_matched',
    'concentrated_uniform'
  };

  p_diffuse = [1/4, 1/4, 1/4, 1/4];
  p_concentrated = [1/2, 1/6, 1/6, 1/6];
  x_uniform = [1/4, 1/4, 1/4, 1/4];

  p_conditions = {
    p_diffuse,
    p_concentrated,
    p_concentrated
  };

  x_conditions = {
    p_diffuse,
    p_concentrated,
    x_uniform
  };

  C_values = [60, 300, 1500];
  Omega_values = [0.4, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5];
  seed_base = 20260829;

  fid = fopen(output_file, 'w');
  assert(fid >= 0, 'Could not open E1 raw output file.');

  fprintf(fid, ['condition,replication,seed,C,D,Omega,H,Lambda,chi,' ...
                'n_served,n_blocked,blocked_fraction,fluid_blocked_fraction\n']);

  n_conditions = length(condition_names);

  for cidx = 1:n_conditions
    p = p_conditions{cidx};
    x = x_conditions{cidx};

    for sidx = 1:length(C_values)
      C = C_values(sidx);

      for oidx = 1:length(Omega_values)
        Omega_target = Omega_values(oidx);
        D = round(Omega_target * C);
        Omega_realized = D / C;

        assert(abs(Omega_realized - Omega_target) <= tol, ...
          'E1 design requires exact integer D at every target Omega.');

        F = fluid_capacity_symmetric(Omega_realized, p, x);

        for rep = 1:R
          seed = seed_base + ...
                 (cidx - 1) * 10000000 + ...
                 (sidx - 1) * 100000 + ...
                 (oidx - 1) * 1000 + rep;

          out = run_capacity_window(D, C, p, p, x, x, seed);

          fprintf(fid, '%s,%d,%d,%d,%d,%.10g,%.10g,%.10g,%.10g,%d,%d,%.10g,%.10g\n', ...
            condition_names{cidx}, rep, seed, C, D, ...
            out.Omega_realized, out.load_metrics_A.H, ...
            out.Lambda_realized, out.chi_realized, ...
            out.n_served, out.n_blocked, out.blocked_fraction, ...
            F.blocked_fraction);
        end
      end
    end
  end

  fclose(fid);

  fprintf('E1 screening raw data written to:\n%s\n', output_file);
  fprintf('Replications per cell: %d\n', R);
  fprintf('Total rows: %d\n', ...
    n_conditions * length(C_values) * length(Omega_values) * R);
end
