
%% Plant Model

% Using estimated data from Table 6.2 (p79) for Iyy and dM_q
Iyy = 34.7e-3;   % kg m^2
dM_q = -46.3e-3; % N m s

% Using guess from equation 6.26 (p76) for dM_u
dM_u = 15e-3;    % Nms

A = [
    1 / Iyy * dM_q,  0;
    1                0;
];

B = [1 / Iyy * dM_u; 0];
C = [1 0];
D = 0;

PitchRateModel = ss(A, B, C, D, ...
    'InputName', 'Delta Omega', 'OutputName', 'Pitch Rate (q)');

% PitchRateModel is also provided in tf form to give convenient access to the
% numerator and denominator to the Simulink Model.
PitchRateModel_tf = tf(PitchRateModel);

Mixer = dM_u^-1;

%% Controllers

Tf = .01; % cf. p87 (Bottom right)

% The controller constants can be found in table 7.1 (p87). In some versions of the Thesis
% the constants are mislabelled. These are the correct values !% 
R1 = pid(.3, .3, .05, Tf);
R2 = pid(1.61, 0, .00512, Tf); 

% For clarity we rename the controllers:
%   - Ri is the inner controller 
%   - Ro is the outer controller
Ri = R1; Ri_tf = tf(Ri);
Ro = R2; Ro_tf = tf(Ro);

%% Discretize

Ts = .01;

Ro_dt = c2d(tf(Ro), Ts);
Ri_dt = c2d(tf(Ri), Ts);
PitchRateModel_dt = c2d(tf(PitchRateModel), Ts);