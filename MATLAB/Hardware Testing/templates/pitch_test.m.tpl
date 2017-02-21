%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUADROTOR PITCH MODEL IDENTIFICATION - TEST                             %
% Authors:  Mattia Giurato (mattia.giurato@polimi.it)                     %
% Date: 18/01/2017                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars
close all 
clc


%% User interface
SerialPort = '/dev/ttyS101';
TestName = 'test_base_1';

global IS_TESTING;
IS_TESTING = true; 

%% Initialization of serial communication
%Serial parameters and functions

if ~IS_TESTING
    % Close old serial port if it is still open 
    try
        fclose(instrfind);
    catch
        disp('Problem using fclose... Opening a serial COM first.');
    end

    % Open a new serial port 
    drone_serial = serial(SerialPort, 'BaudRate', 57600, 'DataBits', 8, 'Terminator', 'CR/LF');
    fopen(drone_serial);
else
    drone_serial = 'dummy';
end

calibrate = @(delay) ...
    send_command(drone_serial, delay, 'Calibrate', 'sim_raspy 99 1 0');
testmode  = @(delay) ...
    send_command(drone_serial, delay, 'TestMode', 'sim_raspy 99 2 1');

start_log = @(delay, name, signals) ...
    send_command(drone_serial, delay, 'Start Log', sprintf('log %s %s', name, signals));
stop_log  = @(delay) ...
    send_command(drone_serial, delay, 'Stop Log', 'log stop');

attitude_start = @(delay, base_thrust, p, q, r) ...
    send_command(drone_serial, delay, 'Start Attitude', sprintf( ...
        'test_attitude_ctr_test %.4f %.4f %.4f %.4f', base_thrust, p, q, r) ...
    );
attitude_stop = @(delay) ...
    send_command(drone_serial, delay, 'Stop Attitude', 'test_attitude_ctr stop');

attitude_home = @(delay, base_thrust) ...
    send_command(drone_serial, delay, 'Attitude Home', ...
        sprintf('test attitude_ctr_test %.4f 0 0 0', base_thrust));

    
%% Start Test equence

hover_thrust = -10;

% Drone Setup 
calibrate(1);
testmode(1); 
attitude_home(10, hover_thrust); 

% Beep - Start test
start_log(2, 'test', 'o_attitude mixer attitude_ctr_test');
attitude_start(10, hover_thrust, 0, deg2rad(30), 0);
attitude_start(10, hover_thrust, 0, -deg2rad(30), 0);
attitude_home(5, hover_thrust);
stop_log(2);

% Beep - End Test
attitude_stop(1);

% Close the serial port
if ~IS_TESTING
    fclose(drone_serial);
end

%% END OF CODE

% Send a command to the drone and print on screen
function send_command(serial, delay, name, command)
    global IS_TESTING;
    
    fprintf('\n[%s] - %13s : %s\n', datestr(now, 'HH:MM:SS.FFF'), name, command);
    
    if ~IS_TESTING
        fprintf(serial, command);
    end
    
    pause_progress(delay);
end

% Display a pretty progress bar whilst waiting for the time to run out
function pause_progress(delay)
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
    end
    
    cpb.stop(); 
end
