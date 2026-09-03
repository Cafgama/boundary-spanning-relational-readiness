fprintf('Running coupled fluid-learning tests...\n');
tol = 1e-8;

%% 1. Active-set schedule is analytically correct in a two-actor case.
p1 = [0.75,0.25];
x1 = [0.5,0.5];
S1 = fluid_active_segments_symmetric(1.5,p1,x1);
assert(S1.n_segments == 2, 'Expected two active-set segments.');
assert(abs(S1.s_start(1)-0) < tol && abs(S1.s_end(1)-2/3) < tol, ...
  'First active-set segment is incorrect.');
assert(abs(S1.A(1)-1) < tol && all(S1.active_masks{1} == [true,true]), ...
  'First segment active mass/mask is incorrect.');
assert(abs(S1.s_start(2)-2/3) < tol && abs(S1.s_end(2)-1.5) < tol, ...
  'Second active-set segment is incorrect.');
assert(abs(S1.A(2)-0.25) < tol && all(S1.active_masks{2} == [false,true]), ...
  'Second segment active mass/mask is incorrect.');

%% 2. No exhaustion before crossing reproduces the exact no-capacity first moment.
p2 = ones(1,4)/4;
x2 = p2;
w0 = 0.4;
alpha = 0.08;
ell = 1;
Theta = 0.8;
N2 = no_capacity_mean_crossing_real(p2,w0,alpha,ell,Theta,200,1e-11);
F2 = fluid_learning_readiness_symmetric(2.0,p2,x2,w0,alpha,ell,Theta,60,3);
assert(F2.delta == 1 && N2.delta == 1, 'Diffuse crossing must be observed.');
assert(abs(F2.T_real-N2.t_cross) < 1e-8, ...
  'Fluid-learning solver must reproduce no-capacity first moment before exhaustion.');

%% 3. The same exact reduction holds for concentrated matched capacity.
p3 = one_heavy_responsibility(4,8/15);
x3 = p3;
N3 = no_capacity_mean_crossing_real(p3,w0,alpha,ell,Theta,200,1e-11);
F3 = fluid_learning_readiness_symmetric(2.0,p3,x3,w0,alpha,ell,Theta,60,3);
assert(abs(F3.T_real-N3.t_cross) < 1e-8, ...
  'Matched concentrated capacity must reduce to the no-capacity mean crossing.');

%% 4. Post-exhaustion segment update matches a hand calculation.
F4 = fluid_learning_readiness_symmetric(1.5,p1,x1,0.4,0.1,1,0.95,20,1);
dt1 = 20*(2/3);
dt2 = 20*(1.5-2/3);
r1 = 0.6*(1-0.1*0.75)^dt1;
r2 = 0.6*(1-0.1*0.25)^dt1*(1-0.1*(0.25*0.25))^dt2;
W4_expected = 0.75*(1-r1)+0.25*(1-r2);
assert(F4.delta == 0, 'High-threshold one-window case should remain censored.');
assert(abs(F4.W_final-W4_expected) < 1e-10, ...
  'Post-exhaustion mean-learning recursion does not match hand calculation.');

%% 5. Canonical mismatch can force readiness into a later window.
p5 = one_heavy_responsibility(4,13/15);
x5 = ones(1,4)/4;
N5 = no_capacity_mean_crossing_real(p5,w0,alpha,ell,Theta,200,1e-11);
F5 = fluid_learning_readiness_symmetric(1.0,p5,x5,w0,alpha,ell,Theta,60,3);
assert(F5.delta == 1, 'Canonical mismatch case must eventually cross.');
assert(F5.first_exhaustion_attempt < N5.t_cross, ...
  'Test case must exhaust before the no-capacity crossing.');
assert(F5.T_real > 60 && F5.T_real < 62, ...
  'Canonical mismatch should cross shortly after the second window begins.');

%% 6. Complete concentration crosses before the 15-slot heavy carrier exhausts.
p6 = one_heavy_responsibility(4,1);
x6 = ones(1,4)/4;
F6 = fluid_learning_readiness_symmetric(2.0,p6,x6,w0,alpha,ell,Theta,60,2);
expected6 = log((1-Theta)/(1-w0))/log(1-alpha);
assert(F6.delta == 1 && abs(F6.T_real-expected6) < 1e-8, ...
  'Complete-concentration real crossing is incorrect.');
assert(F6.T_real < F6.first_exhaustion_attempt, ...
  'Complete concentration must cross before heavy-carrier exhaustion.');

%% 7. Extending the horizon cannot change an already observed crossing.
F7a = fluid_learning_readiness_symmetric(1.0,p5,x5,w0,alpha,ell,Theta,60,3);
F7b = fluid_learning_readiness_symmetric(1.0,p5,x5,w0,alpha,ell,Theta,60,10);
assert(abs(F7a.T_real-F7b.T_real) < 1e-10, ...
  'Observed first passage must be invariant to a longer unused horizon.');

%% 8. Raising the readiness threshold cannot accelerate first passage.
Flo = fluid_learning_readiness_symmetric(1.0,p5,x5,w0,alpha,ell,0.75,60,10);
Fhi = fluid_learning_readiness_symmetric(1.0,p5,x5,w0,alpha,ell,0.85,60,10);
assert(Flo.delta == 1 && Fhi.delta == 1 && Fhi.T_real >= Flo.T_real, ...
  'First passage must be monotone in Theta.');
assert(Fhi.W_final >= 0 && Fhi.W_final <= 1+1e-10, ...
  'Readiness must remain in [0,1].');

fprintf('PASS: coupled fluid-learning tests.\n');
