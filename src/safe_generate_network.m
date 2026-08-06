function G = safe_generate_network(P, architecture)
  % SAFE_GENERATE_NETWORK
  % Attempts to generate a valid network.
  %
  % This protects experiment scripts from rare invalid random graphs,
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
