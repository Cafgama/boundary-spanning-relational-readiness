function diagnostics = analyze_production_pilot(processed_file)
  % ANALYZE_PRODUCTION_PILOT
  % Reads a rerun_v2 production-pilot processed file and produces a compact
  % diagnostic report before final-production design is locked.
  %
  % Usage:
  %   diagnostics = analyze_production_pilot()
  %   diagnostics = analyze_production_pilot(processed_file)
  %
  % If processed_file is omitted, the latest
  % results/processed/rerun_v2/pilot/production_pilot_processed_*.mat file is
  % used. This script does not run simulations and does not overwrite old
  % outputs. It only reads a processed pilot file and writes a diagnostic
  % report under results/processed/rerun_v2/pilot/.

  this_dir = fileparts(mfilename('fullpath'));
  repo_root = fileparts(fileparts(this_dir));

  addpath(fullfile(repo_root, 'src'));

  pilot_dir = fullfile(repo_root, 'results', 'processed', 'rerun_v2', 'pilot');
  ensure_dir(pilot_dir);

  if nargin < 1 || isempty(processed_file)
    processed_file = latest_pilot_processed_file(pilot_dir);
  end

  assert(ischar(processed_file), 'processed_file must be a character string.');
  assert(exist(processed_file, 'file') == 2, ...
    ['Processed pilot file not found: ', processed_file]);

  loaded = load(processed_file);

  assert(isfield(loaded, 'pilot'), ...
    'Processed pilot file must contain a pilot structure.');

  pilot = loaded.pilot;
  validate_pilot_structure(pilot);

  diagnostics = struct();
  diagnostics.run_type = pilot.run_type;
  diagnostics.timestamp = pilot.timestamp;
  diagnostics.processed_file = processed_file;
  diagnostics.NG = pilot.NG;
  diagnostics.NT = pilot.NT;
  diagnostics.T_max = pilot.T_max;
  diagnostics.n_boot = pilot.n_boot;
  diagnostics.seed_base = pilot.seed_base;
  diagnostics.bootstrap_seed = pilot.bootstrap_seed;

  fprintf('\n============================================\n');
  fprintf('RERUN V2 PILOT DIAGNOSTICS\n');
  fprintf('============================================\n');
  fprintf('processed_file: %s\n', processed_file);
  fprintf('NG: %d | NT: %d | T_max: %d | n_boot: %d\n', ...
    pilot.NG, pilot.NT, pilot.T_max, pilot.n_boot);

  condition_names = fieldnames(pilot.estimands);
  condition_diagnostics = struct();
  alerts = {};

  fprintf('\nCondition-level diagnostics\n');
  fprintf('--------------------------------------------\n');

  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = pilot.estimands.(cname);

    condition_diagnostics.(cname) = condition_summary(S);

    fprintf('%s | readiness %.3f | censoring %.3f | RMST %.2f', ...
      cname, S.readiness_probability, S.censoring_probability, S.RMST);

    fprintf(' | T50: ');
    print_estimability(S.T50, S.T50_estimable);
    fprintf(' | T90: ');
    print_estimability(S.T90, S.T90_estimable);
    fprintf(' | T95: ');
    print_estimability(S.T95, S.T95_estimable);
    fprintf('\n');

    if S.readiness_probability < 0.95
      alerts{end + 1} = ...
        ['LOW_READINESS_PROBABILITY: ', cname, ...
         ' readiness probability is below 0.95 in the pilot.'];
    end

    if S.T50_estimable == 0
      alerts{end + 1} = ['T50_NOT_ESTIMABLE: ', cname, ' T50 is not estimable.'];
    end

    if S.T90_estimable == 0
      alerts{end + 1} = ['T90_NOT_ESTIMABLE: ', cname, ' T90 is not estimable.'];
    end

    if S.T95_estimable == 0
      alerts{end + 1} = ['T95_NOT_ESTIMABLE: ', cname, ' T95 is not estimable.'];
    end
  end

  diagnostics.conditions = condition_diagnostics;

  bootstrap_names = fieldnames(pilot.bootstraps);
  bootstrap_diagnostics = struct();

  fprintf('\nContrast-level bootstrap diagnostics\n');
  fprintf('--------------------------------------------\n');

  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    B = pilot.bootstraps.(bname);

    bootstrap_diagnostics.(bname) = bootstrap_summary(B);

    fprintf('%s\n', bname);
    fprintf('  RMST difference %.2f | CI [%.2f, %.2f]\n', ...
      B.observed_difference.rmst, B.ci_low.rmst, B.ci_high.rmst);
    fprintf('  readiness probability difference %.3f | CI [%.3f, %.3f]\n', ...
      B.observed_difference.readiness_probability, ...
      B.ci_low.readiness_probability, B.ci_high.readiness_probability);
    fprintf('  T95 difference ');
    print_numeric_or_nan(B.observed_difference.T95);
    fprintf(' | CI [');
    print_numeric_or_nan(B.ci_low.T95);
    fprintf(', ');
    print_numeric_or_nan(B.ci_high.T95);
    fprintf('] | valid share %.3f\n', B.bootstrap_valid_share.T95);

    if B.bootstrap_valid_share.T50 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T50: ', bname];
    end

    if B.bootstrap_valid_share.T90 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T90: ', bname];
    end

    if B.bootstrap_valid_share.T95 < 0.50
      alerts{end + 1} = ['LOW_BOOTSTRAP_VALID_SHARE_T95: ', bname];
    end
  end

  diagnostics.bootstraps = bootstrap_diagnostics;
  diagnostics.alerts = alerts(:);
  diagnostics.n_alerts = length(alerts);

  timestamp = datestr(now, 'yyyymmdd_HHMMSS');
  report_file = fullfile(pilot_dir, ['production_pilot_diagnostics_', timestamp, '.txt']);
  diagnostics.report_file = report_file;

  write_diagnostic_report(report_file, diagnostics, pilot, condition_names, bootstrap_names);

  fprintf('\nDiagnostic alerts\n');
  fprintf('--------------------------------------------\n');
  if isempty(alerts)
    fprintf('No diagnostic alerts.\n');
  else
    for i = 1:length(alerts)
      fprintf('- %s\n', alerts{i});
    end
  end

  fprintf('\nPilot diagnostic report:\n%s\n', report_file);

  fprintf('\n============================================\n');
  fprintf('RERUN V2 PILOT DIAGNOSTICS PASSED\n');
  fprintf('============================================\n');
end


function processed_file = latest_pilot_processed_file(pilot_dir)
  files = dir(fullfile(pilot_dir, 'production_pilot_processed_*.mat'));

  assert(~isempty(files), ...
    ['No production pilot processed file found in ', pilot_dir]);

  datenums = zeros(length(files), 1);

  for i = 1:length(files)
    datenums(i) = files(i).datenum;
  end

  [~, idx] = max(datenums);
  processed_file = fullfile(pilot_dir, files(idx).name);
end


function validate_pilot_structure(pilot)
  required_fields = {
    'run_type', 'timestamp', 'NG', 'NT', 'T_max', 'n_boot', ...
    'seed_base', 'bootstrap_seed', 'estimands', 'bootstraps'
  };

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(pilot, fname), ['pilot missing field: ', fname]);
  end

  assert(strcmp(pilot.run_type, 'production_pilot'), ...
    'pilot.run_type must be production_pilot.');

  assert(pilot.NG > 0 && pilot.NT > 0, ...
    'pilot.NG and pilot.NT must be positive.');

  assert(pilot.T_max > 0, 'pilot.T_max must be positive.');
  assert(pilot.n_boot > 0, 'pilot.n_boot must be positive.');
end


function C = condition_summary(S)
  C.readiness_probability = S.readiness_probability;
  C.censoring_probability = S.censoring_probability;
  C.RMST = S.RMST;
  C.T50 = S.T50;
  C.T50_estimable = S.T50_estimable;
  C.T90 = S.T90;
  C.T90_estimable = S.T90_estimable;
  C.T95 = S.T95;
  C.T95_estimable = S.T95_estimable;
end


function Bsum = bootstrap_summary(B)
  Bsum.rmst_difference = B.observed_difference.rmst;
  Bsum.rmst_ci_low = B.ci_low.rmst;
  Bsum.rmst_ci_high = B.ci_high.rmst;

  Bsum.readiness_probability_difference = ...
    B.observed_difference.readiness_probability;
  Bsum.readiness_probability_ci_low = B.ci_low.readiness_probability;
  Bsum.readiness_probability_ci_high = B.ci_high.readiness_probability;

  Bsum.T50_difference = B.observed_difference.T50;
  Bsum.T50_valid_share = B.bootstrap_valid_share.T50;

  Bsum.T90_difference = B.observed_difference.T90;
  Bsum.T90_valid_share = B.bootstrap_valid_share.T90;

  Bsum.T95_difference = B.observed_difference.T95;
  Bsum.T95_ci_low = B.ci_low.T95;
  Bsum.T95_ci_high = B.ci_high.T95;
  Bsum.T95_valid_share = B.bootstrap_valid_share.T95;
end


function print_estimability(value, flag)
  if flag == 1
    fprintf('%.2f', value);
  else
    fprintf('not estimable');
  end
end


function print_numeric_or_nan(value)
  if isnan(value)
    fprintf('NaN');
  else
    fprintf('%.2f', value);
  end
end


function write_diagnostic_report(report_file, diagnostics, pilot, condition_names, bootstrap_names)
  fid = fopen(report_file, 'w');
  assert(fid > 0, ['Could not open diagnostic report file: ', report_file]);

  fprintf(fid, 'RERUN V2 PRODUCTION PILOT DIAGNOSTICS\n');
  fprintf(fid, 'timestamp: %s\n', diagnostics.timestamp);
  fprintf(fid, 'processed_file: %s\n', diagnostics.processed_file);
  fprintf(fid, 'NG: %d\n', pilot.NG);
  fprintf(fid, 'NT: %d\n', pilot.NT);
  fprintf(fid, 'T_max: %d\n', pilot.T_max);
  fprintf(fid, 'n_boot: %d\n', pilot.n_boot);
  fprintf(fid, 'seed_base: %d\n', pilot.seed_base);
  fprintf(fid, 'bootstrap_seed: %d\n', pilot.bootstrap_seed);

  fprintf(fid, '\nCONDITIONS\n');
  for i = 1:length(condition_names)
    cname = condition_names{i};
    S = pilot.estimands.(cname);

    fprintf(fid, '\n%s\n', cname);
    fprintf(fid, 'readiness_probability: %.6f\n', S.readiness_probability);
    fprintf(fid, 'censoring_probability: %.6f\n', S.censoring_probability);
    fprintf(fid, 'RMST: %.6f\n', S.RMST);
    fprintf(fid, 'T50: %.6f | estimable: %d\n', S.T50, S.T50_estimable);
    fprintf(fid, 'T90: %.6f | estimable: %d\n', S.T90, S.T90_estimable);
    fprintf(fid, 'T95: %.6f | estimable: %d\n', S.T95, S.T95_estimable);
  end

  fprintf(fid, '\nCONTRASTS\n');
  for i = 1:length(bootstrap_names)
    bname = bootstrap_names{i};
    B = pilot.bootstraps.(bname);

    fprintf(fid, '\n%s\n', bname);
    fprintf(fid, 'rmst_difference: %.6f | CI [%.6f, %.6f]\n', ...
      B.observed_difference.rmst, B.ci_low.rmst, B.ci_high.rmst);
    fprintf(fid, 'readiness_probability_difference: %.6f | CI [%.6f, %.6f]\n', ...
      B.observed_difference.readiness_probability, ...
      B.ci_low.readiness_probability, B.ci_high.readiness_probability);
    fprintf(fid, 'T50_difference: %.6f | valid_share %.6f\n', ...
      B.observed_difference.T50, B.bootstrap_valid_share.T50);
    fprintf(fid, 'T90_difference: %.6f | valid_share %.6f\n', ...
      B.observed_difference.T90, B.bootstrap_valid_share.T90);
    fprintf(fid, 'T95_difference: %.6f | CI [%.6f, %.6f] | valid_share %.6f\n', ...
      B.observed_difference.T95, B.ci_low.T95, B.ci_high.T95, ...
      B.bootstrap_valid_share.T95);
  end

  fprintf(fid, '\nALERTS\n');
  if isempty(diagnostics.alerts)
    fprintf(fid, 'No diagnostic alerts.\n');
  else
    for i = 1:length(diagnostics.alerts)
      fprintf(fid, '- %s\n', diagnostics.alerts{i});
    end
  end

  fclose(fid);
end
