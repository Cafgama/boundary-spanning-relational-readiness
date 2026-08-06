function [P2, architecture, condition_label] = configure_mechanism_condition(P, condition_label)
  % CONFIGURE_MECHANISM_CONDITION
  % Returns parameter settings and network architecture for the
  % mechanism-decomposition experiment.
  %
  % Conditions:
  %   RB_low   = random bridging with ordinary cross-boundary success
  %   BS_low   = boundary spanning with no translation advantage
  %   BS_high  = boundary spanning with translation advantage

  assert(isstruct(P), 'P must be a structure.');
  assert(ischar(condition_label), 'condition_label must be a character string.');

  P2 = P;

  if strcmp(condition_label, 'RB_low')

    architecture = 'random_bridging';

    % Random bridging has ordinary cross-boundary success probability.
    % pi_BS is irrelevant because there are no type-3 edges, but we set it
    % equal to pi_out for clarity.
    P2.pi_out = 0.55;
    P2.pi_BS = 0.55;

  elseif strcmp(condition_label, 'BS_low')

    architecture = 'boundary_spanning';

    % Boundary-spanning allocation exists, but there is no translation
    % advantage. Boundary-spanning ties are no more successful than ordinary
    % cross-boundary ties.
    P2.pi_out = 0.55;
    P2.pi_BS = 0.55;

  elseif strcmp(condition_label, 'BS_high')

    architecture = 'boundary_spanning';

    % Boundary-spanning allocation plus translation advantage.
    P2.pi_out = 0.55;
    P2.pi_BS = 0.65;

  else
    error('Unknown mechanism condition. Use RB_low, BS_low, or BS_high.');
  end

  % Basic checks.
  assert(P2.pi_out >= 0 && P2.pi_out <= 1, ...
    'pi_out must be in [0,1].');

  assert(P2.pi_BS >= 0 && P2.pi_BS <= 1, ...
    'pi_BS must be in [0,1].');

  if strcmp(condition_label, 'BS_high')
    assert(P2.pi_BS > P2.pi_out, ...
      'BS_high requires pi_BS > pi_out.');
  end

  if strcmp(condition_label, 'BS_low')
    assert(abs(P2.pi_BS - P2.pi_out) < 1e-12, ...
      'BS_low requires pi_BS = pi_out.');
  end
end
