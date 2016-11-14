 
%
% To simplify further development of the VRFT control algorithms we group here
% all the different models that we might need. 
%

%% Inner Loop & H_inf Regulator
Ts = .01;

% This is the model specified on page 84, equation 7.3
PitchRateModel = tf(.423, [1, 1.33], ...
    'InputName', 'd\Omega', 'OutputName', 'q');
PitchRateModel_dt = c2d(PitchRateModel, Ts);

% The mixer matrix term was calculated in |quad_copter_model.mlx|
Mixer = tf(66.6667, 1, ...
    'InputName', 'dM', 'OutputName', 'd\Omega');

Tf = .01;
Ri = pid(.3, .3, .05, Tf, ...
    'InputName', 'e_i', 'OutputName', 'dM');

icloop = loopsens(PitchRateModel * Mixer, Ri);
InnerLoop_Hinf = tf(icloop.Ti);
InnerLoop_Hinf.InputName  = 'q°';
InnerLoop_Hinf.OutputName = 'q';

%% Outer Loop & H_inf Regulator

Ro = pid(1.61, 0, .00512, .01); 

integrator = tf(1, [1, 0]); 
integrator_dt = c2d(integrator, Ts);

ocloop = loopsens(integrator * InnerLoop_Hinf, Ro);
OuterLoop_Hinf = tf(ocloop.Ti);
OuterLoop_Hinf.InputName  = '\Theta°';
OuterLoop_Hinf.OutputName = '\Theta';

%% Discretize the relevant bits

Ts = .01; 

% This tolerance is used to perform pole/zero cancellations in |minreal| of
% poles that were not cancelled due to numeric errors in MATLAB. This value was
% chosen so that, in our case, the continuous and discretized models had the
% same order. 
discretization_tolerance = .0025; 

InnerLoop_Hinf_dt = minreal(c2d(InnerLoop_Hinf, Ts), discretization_tolerance); 
OuterLoop_Hinf_dt = minreal(c2d(OuterLoop_Hinf, Ts), discretization_tolerance);

%% VRFT Controller Classes
% 
% The controller classes are imposed by the architecture of the controller. They
% are not a design parameter. Only the Kp, Ki, Kd constants can be tuned.

PIDControllerClass = [ 1, tf(1, [1 0]), tf([1 0], [Tf 1]) ].';
PIDControllerClass_dt = c2d(PIDControllerClass, Ts);

PDControllerClass = [ 1, tf([1 0], [Tf 1]) ].';
PDControllerClass_dt = c2d(PDControllerClass, Ts);

%% Convenience functions that don't really deserve their own file

mk_2nd_order = @(omega, zeta) tf(omega^2, [1, 2*omega*zeta, omega^2]);

%% Save all the relevant variables

save('quad_copter_models.mat',                                      ...
     'PitchRateModel', 'Mixer', 'Ri', 'InnerLoop_Hinf', 'Tf', 'Ts', ...
     'integrator', 'integrator_dt', 'Ro', 'OuterLoop_Hinf',  ...
     'InnerLoop_Hinf_dt', 'OuterLoop_Hinf_dt', ...
     'PIDControllerClass_dt', 'PDControllerClass_dt', ...
     'mk_2nd_order'                                                 ...
     ); 
 