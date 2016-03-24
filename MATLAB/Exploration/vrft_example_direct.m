
%% Example data

N = 512;   % Number of samples
Ts = .05;  % Sample Time [s]

t_end = N*Ts - Ts;
t  = 0:Ts:t_end;   % Time vector

z = tf('z', Ts);

% Plant Model
B = (.28261 +  .50666 * z^-1);
A = (1 - 1.41833 * z^-1 + 1.58939 * z^-2 - 1.31608 * z^-3 + .88642 * z^-4);

Plant = z^-3 * B / A; 
Plant.Variable = 'z^-1';

% Reference Model
omega_bar = 10; 
alpha = exp(-Ts * omega_bar); 
RefModel = z^-3 * (1 - alpha)^2 / (1 - alpha * z^-1)^2;
RefModel.Variable = 'z^-1';

% Controller family
c1 =    1 / (1 - z^-1);  c1.Variable = 'z^-1';
c2 = z^-1 / (1 - z^-1);  c2.Variable = 'z^-1';  
c3 = z^-2 / (1 - z^-1);  c3.Variable = 'z^-1';
c4 = z^-3 / (1 - z^-1);  c4.Variable = 'z^-1';
c5 = z^-4 / (1 - z^-1);  c5.Variable = 'z^-1';
c6 = z^-5 / (1 - z^-1);  c6.Variable = 'z^-1';
Controller = [c1 c2 c3 c4 c5 c6].';

% Input/Output signals
u = wgn(N, 1, 0);
y = lsim(Plant, u, t);

%% Compare Plant and Ref Model

figure()
    bode(Plant, RefModel);
    legend('Plant', 'Reference Model', 'location', 'SouthWest');
    grid on;
    
%% Calculate optimal controller

OptimalController = VRFT1_ry(u, y, RefModel,  Controller, [], [], []);
OptimalController.Variable = 'z^-1'; 

%% Calculate parameter vector: 
% Since the form of the model is so different we use an identification approach
% to calculate the original terms of the controller
%
% To verify the calculation we can run it using the controller provided in the
% paper (SolvedController, defined below). The values of theta that come out are
% the same that came in so the formula must work. 


A = OptimalController.Numerator{:}; 
theta = zeros(1, 6); 

theta(1) = A(1); 
theta(2) = A(2) + 5 * theta(1); 
theta(3) = A(3) + 5 * theta(2) - 10 * theta(1);
theta(4) = A(4) + 5 * theta(3) - 10 * theta(2) + 10 * theta(1);
theta(5) = A(5) + 5 * theta(4) - 10 * theta(3) + 10 * theta(2) - 5 * theta(1);
theta(6) = A(6) + 5 * theta(5) - 10 * theta(4) + 10 * theta(3) - 5 * theta(2) + theta(1);

theta_down = theta; 

theta = zeros(1, 6); 

theta(6) = -A(11); 
theta(5) = -A(10) + 5 * theta(6);
theta(4) = -A(9)  + 5 * theta(5) - 10 * theta(6);
theta(3) = -A(8)  + 5 * theta(4) - 10 * theta(5) + 10 * theta(6);
theta(2) = -A(7)  + 5 * theta(3) - 10 * theta(4) + 10 * theta(5) - 5 * theta(6);
theta(1) = -A(6)  + 5 * theta(2) - 10 * theta(3) + 10 * theta(4) - 5 * theta(5) + theta(6);

theta_up = theta; 

fprintf('Calculated parameters: \n\n');

fprintf('+---------+----------+------------+---------+\n');
fprintf('| Theta N | Value Up | Value Down |   Error |\n');
fprintf('+---------+----------+------------+---------+\n');
for k = 1:length(theta_up)
   fprintf('| %7i | %8.4f |   %8.4f | %7.4f |\n', ...
       k-1, theta_up(k), theta_down(k), abs(theta_up(k) - theta_down(k)) / theta_up(k) * 100 ); 
end
fprintf('+---------+----------+------------+---------+\n');

%% Compare ou model with the one provided by the paper

SolvedController = Controller.' * [.14724, -.25016, .29166, -.25678, .18587, -.03717]';

SolvedLoop = SolvedController * Plant;
OptimalLoop = OptimalController * Plant;

SolvedPlant = feedback(SolvedLoop, 1);
OptimalPlant = feedback(OptimalLoop, 1);

figure()
    % step(SolvedLoop, OptimalLoop);
    step(SolvedPlant, OptimalPlant);
    legend('Solved Controller', 'Optimal Controller');
    grid on;

%% Compare controlled plant and reference 

ControlledPlant = feedback(OptimalController * Plant, 1);
figure()
    bode(ControlledPlant, RefModel); 
    legend('Controlled Plant', 'ReferenceModel', 'location', 'SouthWest');
    grid on;