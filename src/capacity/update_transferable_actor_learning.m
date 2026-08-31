function w_next = update_transferable_actor_learning(w, actor_idx, learned, alpha)
% UPDATE_TRANSFERABLE_ACTOR_LEARNING Update one actor's transferable state.
%
% Model v0.4 deterministic learning kernel.
%
% Inputs
%   w         : row/column vector of actor states in [0,1]
%   actor_idx : integer index of the participating actor
%   learned   : logical or numeric 0/1 productive-learning indicator
%   alpha     : reinforcement fraction in (0,1]
%
% If learned=1:
%   w_i' = w_i + alpha*(1-w_i)
%
% If learned=0:
%   w_i' = w_i
%
% All nonparticipating actors remain unchanged.

  assert(isvector(w) && ~isempty(w), 'w must be a nonempty vector.');
  assert(all(isfinite(w(:))) && all(w(:) >= 0) && all(w(:) <= 1), ...
    'All actor states must lie in [0,1].');
  assert(isscalar(actor_idx) && isfinite(actor_idx) && ...
    actor_idx == floor(actor_idx) && actor_idx >= 1 && actor_idx <= numel(w), ...
    'actor_idx must be a valid integer actor index.');
  assert(isscalar(learned) && (learned == 0 || learned == 1), ...
    'learned must be 0 or 1.');
  assert(isscalar(alpha) && isfinite(alpha) && alpha > 0 && alpha <= 1, ...
    'alpha must lie in (0,1].');

  w_next = w;

  if learned == 1
    w_next(actor_idx) = w(actor_idx) + alpha * (1 - w(actor_idx));
  end
end
