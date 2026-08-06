function assert_event_time_fields(out, P)
  % ASSERT_EVENT_TIME_FIELDS
  % Checks rerun-v2 event-time semantics.
  %
  % Required convention:
  %   T        = first-passage time if event occurred; NaN if censored.
  %   T_tilde  = observed time; T if event occurred; P.T_max if censored.
  %   delta    = 1 if event occurred; 0 if censored.

  assert(isstruct(out), 'out must be a structure.');
  assert(isstruct(P), 'P must be a structure.');

  required_fields = {'T', 'T_tilde', 'delta', 'converged'};

  for i = 1:length(required_fields)
    fname = required_fields{i};
    assert(isfield(out, fname), ['Missing event-time field: ', fname]);
  end

  assert(out.delta == 0 || out.delta == 1, ...
    'delta must be 0 or 1.');

  assert(out.converged == 0 || out.converged == 1, ...
    'converged must be 0 or 1.');

  assert(out.delta == out.converged, ...
    'delta and converged must be identical indicators.');

  if out.delta == 1
    assert(~isnan(out.T), ...
      'T must be observed when delta = 1.');

    assert(out.T >= 0 && out.T <= P.T_max, ...
      'Observed T must lie in [0, T_max].');

    assert(out.T_tilde == out.T, ...
      'T_tilde must equal T when delta = 1.');

  else
    assert(isnan(out.T), ...
      'T must be NaN when delta = 0.');

    assert(out.T_tilde == P.T_max, ...
      'T_tilde must equal P.T_max when delta = 0.');
  end
end
