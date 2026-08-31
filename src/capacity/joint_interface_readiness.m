function M = joint_interface_readiness(wA, pA, wB, pB, theta)
% JOINT_INTERFACE_READINESS Joint readiness under product demand pairing.
%
% Under the Model v0.2 maximum-entropy closure P_ij = pA_i*pB_j,
% joint ready-demand coverage factorizes exactly as R = R_A * R_B.

  MA = actor_readiness_coverage(wA, pA, theta);
  MB = actor_readiness_coverage(wB, pB, theta);

  M = struct();
  M.RA = MA.coverage;
  M.RB = MB.coverage;
  M.R = M.RA * M.RB;
  M.readyA = MA.ready;
  M.readyB = MB.ready;
end
