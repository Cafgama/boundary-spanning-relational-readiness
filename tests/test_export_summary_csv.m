% TEST_EXPORT_SUMMARY_CSV
% Smoke test for export_summary_csv.m

if ~exist('RUNNING_ALL_TESTS', 'var')
  clear;
  clc;
end

addpath('../src');

% Create synthetic summaries to keep the test fast.
S1.architecture = 'random_bridging';
S1.seed = 12345;
S1.NG = 2;
S1.NT = 3;
S1.n_runs = 6;
S1.n_converged = 5;
S1.n_nonconverged = 1;
S1.convergence_rate = 5 / 6;
S1.nonconvergence_rate = 1 / 6;

S1.T_conv_mean = 100;
S1.T_conv_median = 90;
S1.T_conv_p75 = 120;
S1.T_conv_p90 = 150;
S1.T_conv_p95 = 180;
S1.T_conv_min = 40;
S1.T_conv_max = 200;

S1.T_cens_mean = 300;
S1.T_cens_median = 110;
S1.T_cens_p75 = 160;
S1.T_cens_p90 = 5000;
S1.T_cens_p95 = 5000;
S1.T_cens_min = 40;
S1.T_cens_max = 5000;

S1.final_RB_mean = 0.82;
S1.final_RB_median = 0.83;
S1.final_RB_min = 0.50;
S1.final_RB_max = 1.00;

S1.total_edges_mean = 80;
S1.total_edges_median = 81;
S1.mean_degree_mean = 4.0;
S1.mean_degree_median = 4.1;
S1.max_degree_mean = 9;
S1.max_degree_median = 9;
S1.boundary_edges_mean = 12;
S1.boundary_edges_median = 12;

S2 = S1;
S2.architecture = 'boundary_spanning';
S2.seed = 12346;

all_summaries = {S1, S2};

outfile = [tempname(), '.csv'];

export_summary_csv(all_summaries, outfile);

assert(exist(outfile, 'file') == 2, ...
  'CSV output file was not created.');

fid = fopen(outfile, 'r');
assert(fid != -1, 'Could not open generated CSV file.');

content = char(fread(fid, Inf, 'char')');
fclose(fid);

assert(!isempty(strfind(content, 'architecture')), ...
  'CSV header must contain architecture.');

assert(!isempty(strfind(content, 'random_bridging')), ...
  'CSV content must contain random_bridging row.');

assert(!isempty(strfind(content, 'boundary_spanning')), ...
  'CSV content must contain boundary_spanning row.');

delete(outfile);

disp('CSV export test passed.');
