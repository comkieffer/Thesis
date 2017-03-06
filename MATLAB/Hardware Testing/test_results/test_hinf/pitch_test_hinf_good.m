%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUADROTOR PITCH MODEL IDENTIFICATION - TEST                             %
% Authors:  Mattia Giurato (mattia.giurato@polimi.it)                     %
% Date: 18/01/2017                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars
close all 
clc

%% User interface
SerialPort = '/dev/ttyACM0';

%% Initialization of serial communication
%Serial parameters and functions

% Close old serial port if it is still open 
try
    fclose(instrfind);
catch
    disp('Problem using fclose... Opening a serial COM first.');
end


%% Setup commands
%
% These commands will be run before the test starts and take care of
% configuring the drone, starting the logging and powering the motors

hover_thrust = -10;

attitude_cmd = @(h, p, q, r) ...
    sprintf('test attitude_ctr_test %.4f %.4f %.4f %.4f', h, p, q, r);

setup_commands = struct([]); 

setup_commands(1).name = 'Calibrate';
setup_commands(1).command = 'sim_raspy 99 1 0';
setup_commands(1).duration = 2; 

setup_commands(2).name = 'Enter Test Mode';
setup_commands(2).command = 'sim_raspy 99 2 1';
setup_commands(2).duration = 2; 

setup_commands(3).name = 'Power Up Motors';
setup_commands(3).command = attitude_cmd(hover_thrust, 0, 0, 0);
setup_commands(3).duration = 5; 

setup_commands(4).name = 'Start Logging';
setup_commands(4).command = 'log test_0 o_attitude mixer attitude_ctr_test';
setup_commands(4).duration = 1;

%% Teardown commands
%
% These commands will be run after the test finishes and will take care of
% returning the drone to a safe orientation, stopping the loggind and powering
% off. 

teardown_commands = struct([]);

teardown_commands(1).name = 'Set Attitude Home';
teardown_commands(1).command = attitude_cmd(hover_thrust, 0, 0, 0);
teardown_commands(1).duration = 5;

teardown_commands(2).name = 'Stop Logging';
teardown_commands(2).command = 'log stop';
teardown_commands(2).duration = 1;

teardown_commands(3).name = 'Power Down Motors';
teardown_commands(3).command = 'test attitude_ctr_test stop';
teardown_commands(3).duration = 1;

%% Test commands
%
% This is where the test actually happens

test_commands = struct([]);

test_commands(1).name = 'Set Attitude Home';
test_commands(1).command = attitude_cmd(hover_thrust, 0, deg2rad(15), 0);
test_commands(1).duration = 10;

test_commands(2).name = 'Set Attitude Home';
test_commands(2).command = attitude_cmd(hover_thrust, 0, deg2rad(-15), 0);
test_commands(2).duration = 10;

%% Run the test

% Open a new serial port 
drone_serial = serial(SerialPort, 'BaudRate', 57600, 'DataBits', 8, 'Terminator', 'CR/LF');
fopen(drone_serial);

draw_boxed_text('Setup In Progress'); 
for k = 1:length(setup_commands)
    run_command(drone_serial, setup_commands(k))
end

draw_boxed_text('Running Test');
for k = 1:length(test_commands)
    run_command(drone_serial, test_commands(k))
end

draw_boxed_text('Teardown In Progress');
for k = 1:length(teardown_commands)
    run_command(drone_serial, teardown_commands(k))
end

% Close the serial port
fclose(drone_serial);
fprintf('\n');

%% END OF CODE

% Send a command to the drone and print on screen
function run_command(serial_device, command)
    fprintf('\n[%s] - %13s : %s\n', datestr(now, 'HH:MM:SS.FFF'), ...
        command.name, command.command);
    
    fprintf(serial_device, command.command);
    readasync(serial_device)

    waitfor(command.duration);
    
    if serial_device.BytesAvailable > 0
        str = fscanf(serial_device);
        
        % remove newlines, extra spaces and other junk
        str = replace({char(10), char(13)}, ' ', str); % 10 = CR, 13 = LF
        str = deblank(str);
        
        for k = 1:length(str)
            line = str{k};
            
            if ~isempty(line) && line ~= ' '
                fprintf('\n  => Serial says: <-%s->\n', str{:});
            end
        end
    end        
end

% Display a pretty progress bar whilst waiting for the time to run out
function waitfor(delay)
    start_time =  clock();
    
    win_size = matlab.desktop.commandwindow.size;
    
    cpb = ConsoleProgressBar();
    cpb.setMinimum(0); 
    cpb.setMaximum(100);
    cpb.setLeftMargin(5);
    cpb.setLength(win_size(1) - 30);
    cpb.setPercentVisible(0);
    cpb.setElapsedTimeVisible(1);
    cpb.start();
    
    while true
        elapsed = etime(clock(), start_time);
        
        if elapsed > delay
            cpb.setValue(100);
            break;
        end
        
        cpb.setValue(elapsed / delay * 100);
        pause(.001);
    end
    
    
    cpb.stop(); 
end

function draw_boxed_text(text)
    win_size = matlab.desktop.commandwindow.size;
    padding = 4;
    
    % Assume that window will be big enough
    box_size = length(text) + 2*padding;
    fprintf('\n\n');
    disp(pad(['#' pad('', box_size, 'both', '=') '#'], win_size(1) - 1, 'both', ' '));
    disp(pad(['#    ' text '    #'], win_size(1) - 1, 'both', ' '));
    disp(pad(['#' pad('', box_size, 'both', '=') '#'], win_size(1) - 1, 'both', ' '));    
    fprintf('\n');
end