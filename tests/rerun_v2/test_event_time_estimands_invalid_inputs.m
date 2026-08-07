function test_event_time_estimands_invalid_inputs()
  % TEST_EVENT_TIME_ESTIMANDS_INVALID_INPUTS
  % Invalid inputs should fail loudly rather than silently producing outputs.

  setup_rerun_v2_tests();

  did_fail = false;
  try
    compute_event_time_estimands([1; 2], [1; 0; 1]);
  catch
    did_fail = true;
  end
  assert(did_fail, 'Length mismatch should fail.');

  did_fail = false;
  try
    compute_event_time_estimands([1; 2; 3], [1; 2; 0]);
  catch
    did_fail = true;
  end
  assert(did_fail, 'Invalid delta values should fail.');

  did_fail = false;
  try
    compute_event_time_estimands([1; NaN; 3], [1; 0; 1]);
  catch
    did_fail = true;
  end
  assert(did_fail, 'NaN T_tilde values should fail.');

  did_fail = false;
  try
    compute_event_time_estimands([1; 2; 3], [1; 0; 1], [0; 0.5]);
  catch
    did_fail = true;
  end
  assert(did_fail, 'Invalid quantile probabilities should fail.');

  fprintf('test_event_time_estimands_invalid_inputs passed.\n');
end
