function out = admit_capacity_sequence(pairs, cA, cB)
  % ADMIT_CAPACITY_SEQUENCE
  % Deterministic admission kernel for one capacity window.
  %
  % Each row of pairs is [i,j], identifying one attempted interaction
  % between actor i in module A and actor j in module B.
  %
  % A demand is served iff both endpoint actors have remaining capacity.
  % Served demands consume one unit from each endpoint. Blocked demands
  % consume no capacity. Every row is processed and therefore advances
  % the external attempt clock.

  tol = 1e-12;

  assert(isnumeric(pairs) && ndims(pairs) == 2 && size(pairs, 2) == 2, ...
    'pairs must be a D-by-2 numeric matrix of endpoint indices.');
  validate_capacity_vector(cA, 'cA', tol);
  validate_capacity_vector(cB, 'cB', tol);

  cA0 = cA(:)';
  cB0 = cB(:)';
  remainingA = cA0;
  remainingB = cB0;

  D = size(pairs, 1);
  served_mask = false(D, 1);
  blocked_mask = false(D, 1);
  usedA = zeros(size(cA0));
  usedB = zeros(size(cB0));
  demandA = zeros(size(cA0));
  demandB = zeros(size(cB0));

  for t = 1:D
    i = pairs(t, 1);
    j = pairs(t, 2);

    assert(isfinite(i) && isfinite(j) && ...
           abs(i - round(i)) <= tol && abs(j - round(j)) <= tol, ...
      'Endpoint indices must be finite integers.');

    i = round(i);
    j = round(j);

    assert(i >= 1 && i <= length(cA0), ...
      'Module-A endpoint index out of range.');
    assert(j >= 1 && j <= length(cB0), ...
      'Module-B endpoint index out of range.');

    demandA(i) = demandA(i) + 1;
    demandB(j) = demandB(j) + 1;

    if remainingA(i) > 0 && remainingB(j) > 0
      served_mask(t) = true;
      remainingA(i) = remainingA(i) - 1;
      remainingB(j) = remainingB(j) - 1;
      usedA(i) = usedA(i) + 1;
      usedB(j) = usedB(j) + 1;
    else
      blocked_mask(t) = true;
    end
  end

  n_served = sum(served_mask);
  n_blocked = sum(blocked_mask);

  assert(n_served + n_blocked == D, ...
    'Every demand attempt must be served or blocked.');
  assert(sum(usedA) == n_served && sum(usedB) == n_served, ...
    'Each served demand must consume exactly one unit per module.');
  assert(all(remainingA >= 0) && all(remainingB >= 0), ...
    'Remaining capacity cannot be negative.');
  assert(all(cA0 - remainingA == usedA) && ...
         all(cB0 - remainingB == usedB), ...
    'Capacity conservation failed.');

  utilA = NaN(size(cA0));
  utilB = NaN(size(cB0));
  positiveA = cA0 > 0;
  positiveB = cB0 > 0;
  utilA(positiveA) = usedA(positiveA) ./ cA0(positiveA);
  utilB(positiveB) = usedB(positiveB) ./ cB0(positiveB);

  out = struct();
  out.D = D;
  out.served_mask = served_mask;
  out.blocked_mask = blocked_mask;
  out.n_served = n_served;
  out.n_blocked = n_blocked;
  out.blocked_fraction = safe_fraction(n_blocked, D);
  out.initial_capacity_A = cA0;
  out.initial_capacity_B = cB0;
  out.remaining_capacity_A = remainingA;
  out.remaining_capacity_B = remainingB;
  out.used_capacity_A = usedA;
  out.used_capacity_B = usedB;
  out.utilization_A = utilA;
  out.utilization_B = utilB;
  out.demand_count_A = demandA;
  out.demand_count_B = demandB;
end

function validate_capacity_vector(c, name, tol)
  assert(isvector(c) && ~isempty(c), ...
    '%s must be a nonempty capacity vector.', name);
  assert(all(isfinite(c(:))) && all(c(:) >= 0), ...
    '%s must contain finite nonnegative values.', name);
  assert(all(abs(c(:) - round(c(:))) <= tol), ...
    '%s must contain integer capacity counts.', name);
end

function value = safe_fraction(num, den)
  if den > 0
    value = num / den;
  else
    value = 0;
  end
end
