function out = competence_switching_threshold(p, x, pD, xD, w0, alpha, ell_o, Theta, C, Omega, max_windows, tol)
% COMPETENCE_SWITCHING_THRESHOLD
% Deterministic Model v0.8 threshold for specialist learning effectiveness.
%
% The first actor in p is the specialist/heavy carrier. Ordinary actors have
% competence ell_o. The benchmark pD/xD has homogeneous competence ell_o.
%
% Regimes:
%   structural_win       T_C(ell_o) <= T_D
%   competence_rescuable T_C(ell_o) > T_D and T_C(1) <= T_D
%   unrescuable          T_C(1) > T_D
%
% In a rescuable cell, ell_star is the smallest ell_s in [ell_o,1] such that
% the deterministic concentrated first-passage time is no larger than the
% deterministic diffuse benchmark time.

  if nargin < 12 || isempty(tol)
    tol = 1e-8;
  end

  assert(isvector(p) && numel(p) >= 2, 'p must contain at least two actors.');
  assert(isvector(x) && numel(x) == numel(p), 'x must match p.');
  assert(isvector(pD) && numel(pD) >= 2, 'pD must contain at least two actors.');
  assert(isvector(xD) && numel(xD) == numel(pD), 'xD must match pD.');
  assert(isscalar(ell_o) && ell_o >= 0 && ell_o <= 1, 'ell_o must lie in [0,1].');
  assert(isscalar(tol) && isfinite(tol) && tol > 0, 'tol must be positive.');

  ellD = ell_o * ones(1,numel(pD));
  FD = fluid_learning_readiness_symmetric( ...
    Omega,pD,xD,w0,alpha,ellD,Theta,C,max_windows);
  assert(FD.delta == 1, 'Diffuse benchmark did not cross within max_windows.');
  TD = FD.T_real;

  ell_low = ell_o * ones(1,numel(p));
  F_low = fluid_learning_readiness_symmetric( ...
    Omega,p,x,w0,alpha,ell_low,Theta,C,max_windows);
  assert(F_low.delta == 1, 'Concentrated low-competence case did not cross.');

  ell_high = ell_low;
  ell_high(1) = 1;
  F_high = fluid_learning_readiness_symmetric( ...
    Omega,p,x,w0,alpha,ell_high,Theta,C,max_windows);
  assert(F_high.delta == 1, 'Concentrated high-competence case did not cross.');

  out = struct();
  out.T_diffuse = TD;
  out.T_at_ell_o = F_low.T_real;
  out.T_at_one = F_high.T_real;
  out.ell_o = ell_o;
  out.ell_star = NaN;
  out.regime = '';
  out.root_iterations = 0;

  if F_low.T_real <= TD + tol
    out.regime = 'structural_win';
    out.ell_star = ell_o;
    return;
  end

  if F_high.T_real > TD + tol
    out.regime = 'unrescuable';
    return;
  end

  out.regime = 'competence_rescuable';
  lo = ell_o;
  hi = 1;

  % Monotone bisection: larger specialist competence cannot increase the
  % deterministic learning time because it only increases the specialist's
  % productive-learning rate on every active segment.
  while (hi-lo) > tol
    mid = 0.5*(lo+hi);
    ell_mid = ell_low;
    ell_mid(1) = mid;
    F_mid = fluid_learning_readiness_symmetric( ...
      Omega,p,x,w0,alpha,ell_mid,Theta,C,max_windows);
    assert(F_mid.delta == 1, 'Midpoint competence case did not cross.');
    out.root_iterations = out.root_iterations + 1;

    if F_mid.T_real <= TD
      hi = mid;
    else
      lo = mid;
    end
  end

  out.ell_star = hi;

  % Root bracket audit.
  ell_hi = ell_low;
  ell_hi(1) = out.ell_star;
  F_hi = fluid_learning_readiness_symmetric( ...
    Omega,p,x,w0,alpha,ell_hi,Theta,C,max_windows);
  assert(F_hi.T_real <= TD + 10*tol, 'Returned ell_star does not rescue architecture.');
end
