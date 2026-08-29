function out = run_capacity_window(D, C, pA, pB, xA, xB, seed)
  % RUN_CAPACITY_WINDOW
  % One finite-capacity window with maximum-entropy endpoint demand.
  %
  % This wrapper contains admission only. It has no relational-learning
  % variables or success/failure mechanism.

  tol = 1e-12;

  assert(isscalar(D) && isfinite(D) && D > 0 && ...
         abs(D - round(D)) <= tol, ...
    'D must be a positive integer number of demand attempts.');
  assert(isscalar(C) && isfinite(C) && C > 0 && ...
         abs(C - round(C)) <= tol, ...
    'C must be a positive integer number of capacity units per module.');

  validate_matching_lengths(pA, xA, 'A');
  validate_matching_lengths(pB, xB, 'B');

  D = round(D);
  C = round(C);

  [cA, xA_realized] = allocate_integer_capacity(C, xA);
  [cB, xB_realized] = allocate_integer_capacity(C, xB);

  P_joint = maximum_entropy_pairing(pA, pB);
  pairs = generate_max_entropy_demands(D, pA, pB, seed);
  admission = admit_capacity_sequence(pairs, cA, cB);

  MA = capacity_load_metrics(D, C, pA, xA_realized);
  MB = capacity_load_metrics(D, C, pB, xB_realized);

  out = admission;
  out.C = C;
  out.seed = seed;
  out.pA = pA(:)';
  out.pB = pB(:)';
  out.xA_target = xA(:)';
  out.xB_target = xB(:)';
  out.xA_realized = xA_realized(:)';
  out.xB_realized = xB_realized(:)';
  out.cA = cA(:)';
  out.cB = cB(:)';
  out.P_joint = P_joint;
  out.pairs = pairs;
  out.Omega_realized = D / C;
  out.load_metrics_A = MA;
  out.load_metrics_B = MB;
  out.Lambda_realized = max(MA.Lambda, MB.Lambda);
  out.chi_realized = out.Omega_realized * out.Lambda_realized;
end

function validate_matching_lengths(p, x, module_name)
  assert(isvector(p) && isvector(x) && ~isempty(p) && ~isempty(x), ...
    'p%s and x%s must be nonempty vectors.', module_name, module_name);
  assert(length(p) == length(x), ...
    'p%s and x%s must have the same length.', module_name, module_name);
end
