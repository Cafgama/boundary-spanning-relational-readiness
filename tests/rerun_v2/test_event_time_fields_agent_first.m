function test_event_time_fields_agent_first()
  % TEST_EVENT_TIME_FIELDS_AGENT_FIRST
  % Verifies T, T_tilde, and delta semantics for agent-first dynamics.

  setup_rerun_v2_tests();

  % ------------------------------------------------------------
  % Case 1: readiness already holds at t = 0.
  % ------------------------------------------------------------
  P = baseline_params();
  P.theta = P.w0;
  P.q = 1.0;
  P.T_max = 5;

  rand('seed', P.seed + 5101);
  G = generate_network(P, 'boundary_spanning');

  out = run_dynamics_fast(G, P, false);

  assert_event_time_fields(out, P);

  assert(out.delta == 1, ...
    'Expected event at t = 0 when theta equals w0 and q = 1.');

  assert(out.T == 0, ...
    'Expected T = 0 for initial readiness.');

  assert(out.T_tilde == 0, ...
    'Expected T_tilde = 0 for initial readiness.');

  % ------------------------------------------------------------
  % Case 2: readiness cannot be reached within finite time.
  % ------------------------------------------------------------
  P = baseline_params();
  P.theta = 1.0;
  P.q = 1.0;
  P.T_max = 5;

  rand('seed', P.seed + 5102);
  G = generate_network(P, 'boundary_spanning');

  out = run_dynamics_fast(G, P, false);

  assert_event_time_fields(out, P);

  assert(out.delta == 0, ...
    'Expected censoring when theta = 1 and initial weights are below 1.');

  assert(isnan(out.T), ...
    'Expected T = NaN for censored trajectory.');

  assert(out.T_tilde == P.T_max, ...
    'Expected T_tilde = P.T_max for censored trajectory.');

  fprintf('test_event_time_fields_agent_first passed.\n');
end
