function B = paired_bootstrap_difference(x, y, n_boot, seed)
  % PAIRED_BOOTSTRAP_DIFFERENCE
  % Estimates the paired mean difference x - y and its bootstrap interval.
  %
  % Inputs:
  %   x       first paired vector
  %   y       second paired vector
  %   n_boot  number of bootstrap samples
  %   seed    random seed
  %
  % Output:
  %   B structure containing paired differences and confidence interval.

  assert(isnumeric(x) && isnumeric(y), ...
    'x and y must be numeric vectors.');

  x = x(:);
  y = y(:);

  assert(length(x) == length(y), ...
    'x and y must have equal length.');

  assert(length(x) > 1, ...
    'At least two paired observations are required.');

  assert(all(~isnan(x)) && all(~isnan(y)), ...
    'x and y cannot contain NaN values.');

  assert(n_boot > 0 && n_boot == floor(n_boot), ...
    'n_boot must be a positive integer.');

  assert(seed > 0 && seed == floor(seed), ...
    'seed must be a positive integer.');

  rand('seed', seed);

  d = x - y;
  n = length(d);

  bootstrap_means = zeros(n_boot, 1);

  for b = 1:n_boot
    sampled_indices = randi(n, n, 1);
    bootstrap_means(b) = mean(d(sampled_indices));
  end

  bootstrap_means = sort(bootstrap_means);

  lower_index = max(1, ceil(0.025 * n_boot));
  upper_index = min(n_boot, floor(0.975 * n_boot));

  B.n_pairs = n;
  B.mean_x = mean(x);
  B.mean_y = mean(y);

  B.mean_difference = mean(d);
  B.median_difference = median(d);

  B.relative_reduction = ...
    (mean(x) - mean(y)) / mean(x);

  B.ci_lower = bootstrap_means(lower_index);
  B.ci_upper = bootstrap_means(upper_index);

  B.n_positive = sum(d > 0);
  B.n_negative = sum(d < 0);
  B.n_equal = sum(d == 0);

  B.min_difference = min(d);
  B.max_difference = max(d);
end
