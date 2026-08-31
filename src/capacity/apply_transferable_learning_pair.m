function [wA_next, wB_next] = apply_transferable_learning_pair(wA, wB, i, j, learnedA, learnedB, alpha)
% APPLY_TRANSFERABLE_LEARNING_PAIR Apply Model v0.4 learning to an admitted pair.
%
% This function assumes the capacity/admission layer has already declared
% the interaction served. It does not check or consume capacity.
%
% Endpoint learning outcomes are supplied externally so Model v0.4 does not
% impose a competence mechanism.

  wA_next = update_transferable_actor_learning(wA, i, learnedA, alpha);
  wB_next = update_transferable_actor_learning(wB, j, learnedB, alpha);
end
