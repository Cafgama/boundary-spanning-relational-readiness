function [RB, ready_edges, total_edges] = compute_readiness(W, EB, theta)
  % COMPUTE_READINESS
  % Computes cross-boundary relational readiness.
  %
  % Inputs:
  %   W      relational-confidence matrix
  %   EB     list of cross-boundary edges, each row = [u, i]
  %   theta  tie-level readiness threshold
  %
  % Outputs:
  %   RB           cross-boundary readiness fraction
  %   ready_edges  number of cross-boundary edges with w_ui >= theta
  %   total_edges  total number of cross-boundary edges

  validate_inputs(W, EB, theta);

  total_edges = rows(EB);
  ready_edges = 0;

  for r = 1:total_edges
    u = EB(r, 1);
    i = EB(r, 2);

    if W(u, i) >= theta
      ready_edges = ready_edges + 1;
    end
  end

  RB = ready_edges / total_edges;
end


function validate_inputs(W, EB, theta)
  % Validate weight matrix
  assert(isnumeric(W), 'W must be numeric.');
  assert(rows(W) == columns(W), 'W must be a square matrix.');
  assert(isequal(W, W'), 'W must be symmetric.');

  % Validate EB
  assert(isnumeric(EB), 'EB must be numeric.');
  assert(columns(EB) == 2, 'EB must have exactly two columns.');
  assert(rows(EB) > 0, 'EB must contain at least one cross-boundary edge.');

  % Validate theta
  assert(isnumeric(theta) && isscalar(theta), 'theta must be a scalar.');
  assert(theta >= 0 && theta <= 1, 'theta must be in [0,1].');

  % Validate EB indices
  N = rows(W);

  for r = 1:rows(EB)
    u = EB(r, 1);
    i = EB(r, 2);

    assert(u == floor(u) && i == floor(i), ...
      'EB must contain integer node indices.');

    assert(u >= 1 && u <= N && i >= 1 && i <= N, ...
      'EB contains node indices outside matrix dimensions.');
  end
end
