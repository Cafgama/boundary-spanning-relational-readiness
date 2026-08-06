function P = baseline_params()
  % BASELINE_PARAMS
  % Returns the baseline parameter set for the boundary-spanning
  % relational coordination readiness model.
  %
  % The parameters are computational starting values, not empirical calibration.

  % -----------------------------
  % Population parameters
  % -----------------------------
  P.nU = 20;              % number of university agents
  P.nI = 20;              % number of industry agents
  P.N  = P.nU + P.nI;     % total number of agents

  % -----------------------------
  % Network structure parameters
  % -----------------------------
  P.p_in = 0.20;          % internal tie probability

  % Cross-boundary edge budget for random bridging and boundary spanning.
  P.k = 12;               % number of university-industry ties

  % Baseline modular network uses p_out, chosen so that expected
  % cross-boundary ties are approximately k.
  P.p_out = P.k / (P.nU * P.nI);

  % Boundary spanners per side.
  P.b = 2;

  % -----------------------------
  % Initial relational confidence
  % -----------------------------
  P.w0 = 0.40;

  % -----------------------------
  % Reinforcement-decay dynamics
  % -----------------------------
  P.alpha = 0.08;         % reinforcement rate after success
  P.beta  = 0.02;         % decay rate after failure

  % -----------------------------
  % Interaction success probabilities
  % -----------------------------
  P.pi_in  = 0.80;        % internal tie success probability
  P.pi_out = 0.55;        % ordinary cross-boundary success probability
  P.pi_BS  = 0.65;        % boundary-spanner cross-boundary success probability

  % -----------------------------
  % Readiness thresholds
  % -----------------------------
  P.theta = 0.80;         % tie-level readiness threshold
  P.q     = 0.80;         % boundary-level readiness fraction

  % -----------------------------
  % Simulation horizon
  % -----------------------------
  P.T_max = 50000;

  % -----------------------------
  % Replication parameters
  % -----------------------------
  P.NG_debug = 10;        % graph realizations for debugging
  P.NT_debug = 20;        % trajectories per graph for debugging

  P.NG_full = 100;        % graph realizations for full experiment
  P.NT_full = 100;        % trajectories per graph for full experiment

  % -----------------------------
  % Random seed
  % -----------------------------
  P.seed = 12345;

  % -----------------------------
  % Validate parameters
  % -----------------------------
  validate_params(P);
end


function validate_params(P)
  % VALIDATE_PARAMS
  % Performs basic logical checks on the parameter set.

  % Population checks
  assert(is_positive_integer(P.nU), 'nU must be a positive integer.');
  assert(is_positive_integer(P.nI), 'nI must be a positive integer.');
  assert(P.N == P.nU + P.nI, 'N must equal nU + nI.');

  % Probability checks
  assert(is_probability(P.p_in),  'p_in must be in [0,1].');
  assert(is_probability(P.p_out), 'p_out must be in [0,1].');

  assert(P.p_in > P.p_out, ...
    'Modularity condition violated: p_in must be greater than p_out.');

  % Cross-boundary edge budget checks
  max_cross_edges = P.nU * P.nI;
  assert(is_positive_integer(P.k), 'k must be a positive integer.');
  assert(P.k <= max_cross_edges, ...
    'k cannot exceed the number of possible university-industry pairs.');

  % Boundary-spanner checks for the rerun-v2 exact-one-spanner design.
  assert(is_positive_integer(P.b), 'b must be a positive integer.');

  assert(P.b < P.nU, ...
    'b must be smaller than nU so that university non-spanners exist.');

  assert(P.b < P.nI, ...
    'b must be smaller than nI so that industry non-spanners exist.');

  % Exact-one-spanner candidate pairs:
  %   university-side spanner with industry non-spanner, or
  %   university non-spanner with industry-side spanner.
  max_BS_candidates = P.b * (P.nI - P.b) + P.b * (P.nU - P.b);

  assert(P.k <= max_BS_candidates, ...
    'k is too large for the exact-one-spanner boundary-spanning candidate set.');

  % Side-responsibility capacity checks.
  k_U = ceil(P.k / 2);
  k_I = P.k - k_U;

  assert(k_U <= P.b * (P.nI - P.b), ...
    'k_U exceeds university-side boundary-spanner partner capacity.');

  assert(k_I <= P.b * (P.nU - P.b), ...
    'k_I exceeds industry-side boundary-spanner partner capacity.');

  % Relational confidence checks
  assert(is_probability(P.w0),    'w0 must be in [0,1].');
  assert(is_probability(P.theta), 'theta must be in [0,1].');
  assert(is_probability(P.q),     'q must be in [0,1].');

  % Reinforcement-decay checks
  assert(P.alpha > 0 && P.alpha < 1, 'alpha must be in (0,1).');
  assert(P.beta  > 0 && P.beta  < 1, 'beta must be in (0,1).');

  % Interaction success probability checks
  assert(is_probability(P.pi_in),  'pi_in must be in [0,1].');
  assert(is_probability(P.pi_out), 'pi_out must be in [0,1].');
  assert(is_probability(P.pi_BS),  'pi_BS must be in [0,1].');

  assert(P.pi_in > P.pi_BS, ...
    'Expected ordering violated: pi_in must be greater than pi_BS.');

  assert(P.pi_BS > P.pi_out, ...
    'Expected ordering violated: pi_BS must be greater than pi_out.');

  % Time horizon checks
  assert(is_positive_integer(P.T_max), 'T_max must be a positive integer.');

  % Replication checks
  assert(is_positive_integer(P.NG_debug), 'NG_debug must be a positive integer.');
  assert(is_positive_integer(P.NT_debug), 'NT_debug must be a positive integer.');
  assert(is_positive_integer(P.NG_full),  'NG_full must be a positive integer.');
  assert(is_positive_integer(P.NT_full),  'NT_full must be a positive integer.');

  % Seed check
  assert(is_positive_integer(P.seed), 'seed must be a positive integer.');
end


function tf = is_probability(x)
  tf = isnumeric(x) && isscalar(x) && x >= 0 && x <= 1;
end


function tf = is_positive_integer(x)
  tf = isnumeric(x) && isscalar(x) && x == floor(x) && x > 0;
end
