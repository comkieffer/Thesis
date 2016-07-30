 
%
% To simplify further development of the VRFT control algorithms we group here
% all the different models that we might need. 
%

%% Inner Loop & H_inf Regulator

% This is the model specified on page 84, equation 7.3
PitchRateModel = tf(.423, [1, 1.33], ...
    'InputName', 'd\Omega', 'OutputName', 'q');

% The mixer matrix term was calculated in |quad_copter_model.mlx|
Mixer = tf(66.6667, 1, ...
    'InputName', 'dM', 'OutputName', 'd\Omega');

Ri = pid(.3, .3, .05, .01, ...
    'InputName', 'e_i', 'OutputName', 'dM');

icloop = loopsens(PitchRateModel * Mixer, Ri);
InnerLoop = tf(icloop.Ti, ...
    'InputName', 'q°', 'OutputName', 'q'); 

%% Outer Loop & H_inf Regulator

Ro = pid(1.61, 0, .00512, .01); 

integrator = tf(1, [1, 0]); 

ocloop = loopsens(integrator * InnerLoop, Ro);
OuterLoop = tf(ocloop.Ti, ...
    'InputName', '\Theta°', 'OutputName', '\Theta'); 

%% Convenience functions that don't really deserve their own file

mk_2nd_order = @(omega, zeta) tf(omega^2, [1, 2*omega*zeta, omega^2]);

%% Save all the relevant variables

save('quad_copter_models.mat', ...
     'PitchRateModel', 'Mixer', 'Ri', 'InnerLoop', ...
     'integrator', 'Ro', 'OuterLoop', ...
     'mk_2nd_order', ...
     ); 
 