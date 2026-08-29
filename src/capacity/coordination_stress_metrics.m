function M = coordination_stress_metrics(load_metrics, ordinary_service, specialist_service)
% COORDINATION_STRESS_METRICS Combine load and competence reductions.
%
% Inputs are structs returned by:
%   capacity_load_metrics()
%   relational_service_metrics()
%
% Outputs
%   G  = s_theta(pi_o) / s_theta(pi_s)
%   Xi = chi / G
%
% Xi is a candidate reduced control number, not a hard-coded switching rule.

  assert(isstruct(load_metrics) && isfield(load_metrics, 'chi'), ...
    'load_metrics must contain chi.');
  assert(isstruct(ordinary_service) && isfield(ordinary_service, 's_theta'), ...
    'ordinary_service must contain s_theta.');
  assert(isstruct(specialist_service) && isfield(specialist_service, 's_theta'), ...
    'specialist_service must contain s_theta.');

  s_o = ordinary_service.s_theta;
  s_s = specialist_service.s_theta;

  assert(isfinite(s_o) && s_o > 0, ...
    'Ordinary competence must have finite positive s_theta.');
  assert(isfinite(s_s) && s_s > 0, ...
    'Specialist competence must have finite positive s_theta.');

  G = s_o / s_s;
  Xi = load_metrics.chi / G;

  M = struct();
  M.G = G;
  M.Xi = Xi;
end
