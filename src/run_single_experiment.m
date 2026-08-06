function results = run_single_experiment(P, architecture, NG, NT, seed)
  % RUN_SINGLE_EXPERIMENT
  % Runs multiple graph realizations and multiple dynamic trajectories
  % for one network architecture.
  %
  % Inputs:
  %   P             parameter structure from baseline_params()
  %   architecture  'baseline', 'random_bridging', or 'boundary_spanning'
  %   NG            number of graph realizations
  %   NT            number of trajectories per graph
  %   seed          optional random seed
  %
  % Output:
  %   results structure with one row per trajectory:
  %     architecture
  %     graph_id
  %     trajectory_id
  %     T
  %     converged
  %     final_RB
  %     final_ready
  %     total_boundary_edges
  %     total_edges
  %     mean_degree
  %     max_degree

  if nargin < 5
    seed = P.seed;
  end

  validate_inputs(P, architecture, NG, NT, seed);

  rand('seed', seed);

  total_runs = NG * NT;

  % -----------------------------
  % Preallocate result arrays
  % -----------------------------
  graph_id = zeros(total_runs, 1);
  trajectory_id = zeros(total_runs, 1);

  T = NaN(total_runs, 1);
  converged = zeros(total_runs, 1);
  final_RB = NaN(total_runs, 1);
  final_ready = NaN(total_runs, 1);
  total_boundary_edges = NaN(total_runs, 1);

  total_edges = NaN(total_runs, 1);
  mean_degree = NaN(total_runs, 1);
  max_degree = NaN(total_runs, 1);

  row = 0;

  % -----------------------------
  % Main experiment loop
  % -----------------------------
  for g = 1:NG

    G = safe_generate_network(P, architecture);

    graph_total_edges = sum(sum(G.A)) / 2;
    degrees = sum(G.A, 2);
    graph_mean_degree = mean(degrees);
    graph_max_degree = max(degrees);

    for r = 1:NT
      row = row + 1;

     out = run_dynamics_fast(G, P, false);

      graph_id(row) = g;
      trajectory_id(row) = r;

      T(row) = out.T;
      converged(row) = out.converged;
      final_RB(row) = out.final_RB;
      final_ready(row) = out.final_ready;
      total_boundary_edges(row) = out.total_boundary_edges;

      total_edges(row) = graph_total_edges;
      mean_degree(row) = graph_mean_degree;
      max_degree(row) = graph_max_degree;
    end

    fprintf('Architecture: %s | Graph %d/%d completed.\n', ...
      architecture, g, NG);
  end

  % -----------------------------
  % Package results
  % -----------------------------
  results.architecture = architecture;
  results.NG = NG;
  results.NT = NT;
  results.seed = seed;

  results.graph_id = graph_id;
  results.trajectory_id = trajectory_id;

  results.T = T;
  results.converged = converged;
  results.final_RB = final_RB;
  results.final_ready = final_ready;
  results.total_boundary_edges = total_boundary_edges;

  results.total_edges = total_edges;
  results.mean_degree = mean_degree;
  results.max_degree = max_degree;

  % Useful summary fields
  results.n_runs = total_runs;
  results.n_converged = sum(converged == 1);
  results.n_nonconverged = sum(converged == 0);
  results.nonconvergence_rate = results.n_nonconverged / total_runs;
end


function G = safe_generate_network(P, architecture)
  % SAFE_GENERATE_NETWORK
  % Attempts to generate a valid network.
  %
  % This protects the experiment loop from rare invalid random graphs,
  % especially in the baseline architecture where cross-boundary ties
  % are generated probabilistically.

  max_attempts = 100;

  for attempt = 1:max_attempts
    try
      G = generate_network(P, architecture);
      return;
    catch err
      if attempt == max_attempts
        rethrow(err);
      end
    end
  end

  error('Network generation failed after maximum attempts.');
end


function validate_inputs(P, architecture, NG, NT, seed)
  % VALIDATE_INPUTS
  % Checks experiment-level inputs.

  assert(isstruct(P), 'P must be a structure.');

  valid_architecture = strcmp(architecture, 'baseline') || ...
                       strcmp(architecture, 'random_bridging') || ...
                       strcmp(architecture, 'boundary_spanning');

  assert(valid_architecture, ...
    'architecture must be baseline, random_bridging, or boundary_spanning.');

  assert(is_positive_integer(NG), 'NG must be a positive integer.');
  assert(is_positive_integer(NT), 'NT must be a positive integer.');
  assert(is_positive_integer(seed), 'seed must be a positive integer.');
end


function tf = is_positive_integer(x)
  tf = isnumeric(x) && isscalar(x) && x == floor(x) && x > 0;
end
