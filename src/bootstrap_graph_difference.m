function B = bootstrap_graph_difference(x, y, n_boot, paired)
  % BOOTSTRAP_GRAPH_DIFFERENCE
  % Bootstrap comparison of graph-level metric vectors.
  %
  % Difference is always:
  %   mean(x) - mean(y)
  %
  % Positive difference means y is lower than x.
  % In our interpretation, positive means condition y is faster.

  if nargin < 3
    n_boot = 5000;
  end

  if nargin < 4
    paired = true;
  end

  x = x(:);
  y = y(:);

  x = x(~isnan(x));
  y = y(~isnan(y));

  if paired
    if length(x) ~= length(y)
      error('Paired bootstrap requires x and y to have the same length.');
    end
  end

  boot_values = NaN(n_boot, 1);

  if paired

    d = x - y;
    n = length(d);

    for b = 1:n_boot
      idx = ceil(rand(n, 1) * n);
      boot_values(b) = mean(d(idx));
    end

    estimate = mean(d);
    y_faster_graphs = sum(d > 0);
    y_faster_share = y_faster_graphs / n;

  else

    nx = length(x);
    ny = length(y);

    for b = 1:n_boot
      ix = ceil(rand(nx, 1) * nx);
      iy = ceil(rand(ny, 1) * ny);

      boot_values(b) = mean(x(ix)) - mean(y(iy));
    end

    estimate = mean(x) - mean(y);
    y_faster_graphs = NaN;
    y_faster_share = NaN;
  end

  ci_low = prctile(boot_values, 2.5);
  ci_high = prctile(boot_values, 97.5);

  B.x_value = mean(x);
  B.y_value = mean(y);
  B.difference = estimate;
  B.ci_low = ci_low;
  B.ci_high = ci_high;

  if mean(x) ~= 0
    B.reduction_pct = 100 * estimate / mean(x);
  else
    B.reduction_pct = NaN;
  end

  B.n_boot = n_boot;
  B.paired = paired;
  B.y_faster_graphs = y_faster_graphs;
  B.y_faster_share = y_faster_share;
end
