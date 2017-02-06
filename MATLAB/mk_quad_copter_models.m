 
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
Mixer = tf(66.6667, ...
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

%% Angle Test Sequence

step_size = .18;     % Rough guess from the figures
step_duration = 600; % Estimated 6s per state, 100 samples per second
time_step = .01;     % 100 samples/sec. Extrapolated from FCU freq (100Hz)
test_time_vec = time_step * [0:(70/time_step)]'; 

base = ones(1, step_duration);
test_theta_set_point = [
    base * 0, base * -1 * step_size, base * 0, base * step_size, base * 0, ...
    base * -2 * step_size, base *  0, base * 2 * step_size, base * 0,      ...
    base * -3 * step_size, base *  0, base * 3 * step_size, base * 0,      ...
]';

% Crop the input sequence to the size of the time vector
test_theta_set_point = test_theta_set_point(1:length(test_time_vec));

% Build a |timeseries| object from the input data so that we can pass it into
% Simulink as an input signal
PitchTestSequence.Time = test_time_vec;
PitchTestSequence.Theta = test_theta_set_point; 

%% Convenience functions that don't really deserve their own file

mk_2nd_order = @(omega, zeta) tf(omega^2, [1, 2*omega*zeta, omega^2]);

bode_no_phase = bodeoptions('cstprefs');
bode_no_phase.PhaseVisible = 'off';

%% Save all the relevant variables

save('quad_copter_models.mat',                                      ...
     'PitchRateModel', 'Mixer', 'Ri', 'InnerLoop_Hinf', 'Tf', 'Ts', ...
     'integrator', 'integrator_dt', 'Ro', 'OuterLoop_Hinf',  ...
     'InnerLoop_Hinf_dt', 'OuterLoop_Hinf_dt', ...
     'PIDControllerClass_dt', 'PDControllerClass_dt', ...
     'PitchTestSequence', ...
    'mk_2nd_order', 'bode_no_phase' ...
     ); 
 