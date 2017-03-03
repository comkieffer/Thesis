
%
% Locate the test data on the specified SD Card and move into the dedicated
% test folder so that it can be processed and converted to a matlab file. 
%
% The data file should be at sd_path/test_name
% 

function process_test_data(test_name, sd_path)
    
    % ensure that we return to the starting directory on failure. 
    initial_folder = pwd;
    cleanup = onCleanup(@() cd(initial_folder));

    % ensure that this script is run from the 'Hardware Testing' folder
    folders = regexp(pwd, filesep, 'split');
    if ~strcmp(folders(end), 'Hardware Testing')
        error('This script must be run from the ''Hardware Testing'' folder');
    end 

    %% Step 1 - Move the data from the SD to the results directory
    
    % Ensure that the SD card is connected and available
    if ~exist(sd_path, 'dir')
        error('Unable to locate SD storage at %s', sd_path);
    end
    
    % Try to find the test file on the SD card
    sd_data_file = fullfile(sd_path, 'test_0.txt');
    if ~exist(sd_data_file, 'file')
        error('Unable to locate test data file at %s', sd_data_file);
    end
    
    [this_folder, ~, ~] = fileparts(which('process_test_data'));
%     sd_data_file = fullfile(this_folder, [test_name '.txt']);
    
    % Move the data file to the results folder
    % First we find the base folder for our test. This is where we want to put
    % all our data for safe-keeping.
    % Actually, the directory should alread exist ...
    base_folder = fullfile(pwd, 'test_results', test_name);
    fprintf('\nLocating working directory for this test in: %s\n', base_folder'); 
    if ~exist(base_folder, 'dir')
        error('Unable to locate base folder %s for test <%s>', base_folder, test_name);
    end
    
    % The log file will have to be moved into our base folder
    log_file_destination = fullfile(base_folder, [test_name '.txt']);
    fprintf('\nMoving test data to %s\n', log_file_destination); 
    copyfile(sd_data_file, log_file_destination); 
    
    %% Step 2 - Parse the results
    
    [log_folder, ~, ~] = fileparts(log_file_destination); 
    
    % First we need to find the java binary that parses the log
    parser_executable = which('logParser.jar');
    [parser_folder, ~, ~] = fileparts(parser_executable);
    
    parse_command = sprintf('java -jar "%s" "%s"', ...
       parser_executable, log_file_destination);
    fprintf('\nExecuting parse command: %s\n\n', parse_command);
    
    % The binary creates a 'parsed_logs' directory in its own directory and
    % puts the results there. For simplicity let's move there too. 
    cd(parser_folder);
    system(parse_command); 
    
    % Now we need to locate the folder of parsed logs and move back into our
    % main folder for analysis.
    parsed_logs_folder = fullfile(parser_folder, 'parsed_logs', test_name);
    if ~exist(parsed_logs_folder, 'dir')
        error('Unable to locate ''parsed_logs'' directory.');
    end
 
    % Finally we can generate the .mat file from all of this data
    cd(parsed_logs_folder);
    matlabify_data(test_name)
    
    new_data_folder = fullfile(log_folder, 'parsed_logs');
    fprintf('\nMoving generated files into log directory: %s\n', new_data_folder);
    if exist(new_data_folder, 'dir') 
        if yes_no_prompt('Output log folder already exists. Overwrite')
            rmdir(new_data_folder, 's');
        else
            error('Log folder %s for test <%s> already exists.');
        end
    end
        
    movefile(parsed_logs_folder, new_data_folder, 'f'); 
    
    fprintf('\nAdding test folder %s to path\n', new_data_folder);
    addpath(new_data_folder);
    
    cd(initial_folder);
    
end

function mkdir_safe(dirname)
    if ~exist(dirname, 'dir')
       [status, message, messageID] = mkdir(dirname);
       
       if ~status
           error('Unable to create directory <%i>. Error was: %s (Code %s)', status, message, messageID');
       end
    end
end

function matlabify_data(test_name)

    disp('Stored Data:');

    imu_raw_file = strcat(test_name, '-IMU_RAW.txt');
    if exist(imu_raw_file, 'file')
        imu_raw_data = dlmread(imu_raw_file);

        imu_raw_acc_x = imu_raw_data(:,1);
        imu_raw_acc_y = imu_raw_data(:,2);
        imu_raw_acc_z = imu_raw_data(:,3);
        imu_raw_gyro_x = imu_raw_data(:,4);
        imu_raw_gyro_y = imu_raw_data(:,5);
        imu_raw_gyro_z = imu_raw_data(:,6);
        imu_raw_mag_x = imu_raw_data(:,7);
        imu_raw_mag_y = imu_raw_data(:,8);
        imu_raw_mag_z = imu_raw_data(:,9);
        imu_raw_state = imu_raw_data(:,10);

        disp([' - IMU_RAW',10,9,...
            '(imu_raw_acc_x, imu_raw_acc_y, imu_raw_acc_z,',10,9,...
            ' imu_raw_gyro_x, imu_raw_gyro_y, imu_raw_gyro_z,',10,9,...
            ' imu_raw_mag_x, imu_raw_mag_y, imu_raw_mag_z,',10,9,...
            ' imu_raw_state)']);
    end

    o_attitude_file = strcat(test_name,'-ON_ATTITUDE.txt');
    
    if exist(o_attitude_file, 'file') 
        o_attitude_data = dlmread(o_attitude_file);
        
        o_attitude_roll = remove_spurious_measurements(o_attitude_data(:,1), 5);
        o_attitude_pitch = remove_spurious_measurements(o_attitude_data(:,2), 5);
        o_attitude_yaw = remove_spurious_measurements(o_attitude_data(:,3), 5);
        o_attitude_p = remove_spurious_measurements(o_attitude_data(:,4), 5);
        o_attitude_q = remove_spurious_measurements(o_attitude_data(:,5), 5);
        o_attitude_r = remove_spurious_measurements(o_attitude_data(:,6), 5);
        o_attitude_state = o_attitude_data(:,7);

        disp([' - ON_ATTITUDE',10,9,...
            '(o_attitude_roll, o_attitude_pitch, o_attitude_yaw,',10,9,...
            ' o_attitude_p, o_attitude_q, o_attitude_r,',10,9,...
            ' o_attitude_state)']);
    end

    o_attitude_q_file = strcat(test_name, '-ON_ATTITUDE_QUAT.txt');
    if exist(o_attitude_q_file, 'file')
        o_attitude_q_data = dlmread(o_attitude_q_file);

        o_attitude_q1 = o_attitude_q_data(:,1);
        o_attitude_q2 = o_attitude_q_data(:,2);
        o_attitude_q3 = o_attitude_q_data(:,3);
        o_attitude_q4 = o_attitude_q_data(:,4);
        o_attitude_q_bias = o_attitude_q_data(:,5:7);
        o_attitude_q_state = o_attitude_q_data(:,8);

        disp([' - ON_ATTITUDE_QUAT',10,9,...
            '(o_attitude_q1, o_attitude_q2, o_attitude_q3, o_attitude_q4,',10,9,...
            ' o_attitude_qt_bias, o_attitude_q_state)']);
    end

    
    o_pos_body_file = strcat(test_name, '-ON_POS_BODY.txt');
    if exist(o_pos_body_file, 'file')
        o_pos_body_data = dlmread(o_pos_body_file);

        o_pos_body_x = o_pos_body_data(:,1);
        o_pos_body_u = o_pos_body_data(:,2);
        o_pos_body_u_dot = o_pos_body_data(:,3);
        o_pos_body_y = o_pos_body_data(:,4);
        o_pos_body_v = o_pos_body_data(:,5);
        o_pos_body_v_dot = o_pos_body_data(:,6);
        o_pos_body_z = o_pos_body_data(:,7);
        o_pos_body_w = o_pos_body_data(:,8);
        o_pos_body_w_dot = o_pos_body_data(:,9);
        o_pos_body_state = o_pos_body_data(:,10);

        disp([' - ON_POS_BODY',10,9,...
            '(o_pos_body_x, o_pos_body_u, o_pos_body_u_dot,',10,9,...
            ' o_pos_body_y, o_pos_body_v, o_pos_body_v_dot,',10,9,...
            ' o_pos_body_z, o_pos_body_w, o_pos_body_w_dot,',10,9,...
            ' o_pos_body_state)']);
    end

    o_pos_ned_file = strcat(test_name, '-ON_POS_NED.txt');
    if exist(o_pos_ned_file, 'file')
        o_pos_ned_data = dlmread(o_pos_ned_file);

        o_pos_ned_n = o_pos_ned_data(:,1);
        o_pos_ned_n_vel = o_pos_ned_data(:,2);
        o_pos_ned_n_acc = o_pos_ned_data(:,3);
        o_pos_ned_e = o_pos_ned_data(:,4);
        o_pos_ned_e_vel = o_pos_ned_data(:,5);
        o_pos_ned_e_acc = o_pos_ned_data(:,6);
        o_pos_ned_d = o_pos_ned_data(:,7);
        o_pos_ned_d_vel = o_pos_ned_data(:,8);
        o_pos_ned_d_acc = o_pos_ned_data(:,9);
        o_pos_ned_state = o_pos_ned_data(:,10);

        disp([' - ON_POS_NED',10,9,...
            '(o_pos_ned_n, o_pos_ned_n_vel, o_pos_ned_n_acc,',10,9,...
            ' o_pos_ned_e, o_pos_ned_e_vel, o_pos_ned_e_acc,',10,9,...
            ' o_pos_ned_d, o_pos_ned_d_vel, o_pos_ned_d_acc,',10,9,...
            ' o_pos_ned_state)']);
    end

    baro_file = strcat(test_name, '-BARO.txt');
    if exist(baro_file, 'file')
        baro_data = dlmread(baro_file);

        baro_pressure = baro_data(:,1);
        baro_state = baro_data(:,2);

        disp([' - BARO',10,9,...
            '(baro_pressure, baro_state)']);
    end

    proxy_file = strcat(test_name, '-PROXY.txt');
    if exist(proxy_file, 'file')
        proxy_data = dlmread(proxy_file);

        proxy_values = proxy_data(:,1:6);
        proxy_state = proxy_data(:,7);

        disp([' - PROXY',10,9,...
            '(proxy_values, proxy_state)']);
    end

    gps_file = strcat(test_name, '-GPS.txt');
    if exist(gps_file, 'file')
        gps_data = dlmread(gps_file);

        gps_fix = gps_data(:,1);
        gps_lat = gps_data(:,2);
        gps_lng = gps_data(:,3);
        gps_alt = gps_data(:,4);
        gps_state = gps_data(:,5);

        disp([' - GPS',10,9,...
            '(gps_fix, gps_lat, gps_lon, gps_alt, gps_state)']);
    end

    radio_file = strcat(test_name, '-RADIO.txt');
    
    if exist(radio_file, 'file')
        radio_data = dlmread(radio_file);

        radio_cmd = radio_data(:,1);
        radio_mode = radio_data(:,2);
        radio_fz = radio_data(:,3);
        radio_roll = radio_data(:,4);
        radio_pitch = radio_data(:,5);
        radio_yaw = radio_data(:,6);
        radio_n = radio_data(:,7);
        radio_e = radio_data(:,8);
        radio_d = radio_data(:,9);
        radio_u = radio_data(:,10);
        radio_v = radio_data(:,11);
        radio_w = radio_data(:,12);
        radio_p = radio_data(:,13);
        radio_q = radio_data(:,14);
        radio_r = radio_data(:,15);
        radio_state = radio_data(:,16);

        disp([' - RADIO',10,9,...
            '(radio_cmd, radio_mode, radio_fz,',10,9,...
            ' radio_roll, radio_pitch, radio_yaw,',10,9,...
            ' radio_n, radio_e, radio d,',10,9,...
            ' radio_u, radio_v, radio_w,',10,9,...
            ' radio_p, radio_q, radio_r,',10,9,...
            ' radio_state)']);
    end

    mixer_ctr_file = strcat(test_name, '-MIXER.txt');
    if exist(mixer_ctr_file, 'file')
        mixer_ctr_data = dlmread(mixer_ctr_file);

        mixer_m1 = mixer_ctr_data(:,1);
        mixer_m2 = mixer_ctr_data(:,2);
        mixer_m3 = mixer_ctr_data(:,3);
        mixer_m4 = mixer_ctr_data(:,4);
        mixer_s1 = mixer_ctr_data(:,5);
        mixer_s2 = mixer_ctr_data(:,6);
        mixer_s3 = mixer_ctr_data(:,7);
        mixer_s4 = mixer_ctr_data(:,8);
        mixerr_state = mixer_ctr_data(:,9);

        disp([' - MIXER',10,9,...
            '(mixer_m1, mixer_m2, mixer_m3, mixer_m4,',10,9,...
            ' mixer_s1, mixer_s2, mixer_s3, mixer_s4,',10,9,...
            ' mixer_state)']);
    end

    flight_ctr_file = strcat(test_name, '-FLIGHT_CTR.txt');
    if exist(flight_ctr_file, 'file')
        flight_ctr_data = dlmread(flight_ctr_file);

        flight_ctr_fx = flight_ctr_data(:,1);
        flight_ctr_fy = flight_ctr_data(:,2);
        flight_ctr_fz = flight_ctr_data(:,3);
        flight_ctr_l = flight_ctr_data(:,4);
        flight_ctr_m = flight_ctr_data(:,5);
        flight_ctr_n = flight_ctr_data(:,6);
        flight_ctr_r_ref = flight_ctr_data(:,7);
        flight_ctr_p_ref = flight_ctr_data(:,8);
        flight_ctr_y_ref = flight_ctr_data(:,9);
        flight_ctr_n_ref = flight_ctr_data(:,10);
        flight_ctr_e_ref = flight_ctr_data(:,11);
        flight_ctr_d_ref = flight_ctr_data(:,12);
        flight_ctr_state = flight_ctr_data(:,13);
        disp([' - FLIGHT_CTR',10,9,...
            '(flight_ctr_fx, flight_ctr_fy, flight_ctr_fz,',10,9,...
            ' flight_ctr_l, flight_ctr_m, flight_ctr_n,',10,9,...
            ' flight_ctr_r_ref, flight_ctr_p_ref, flight_ctr_y_ref,',10,9,...
            ' flight_ctr_n_ref, flight_ctr_e_ref, flight_ctr_d_ref,',10,9,...
            ' flight_ctr_state)']);
    end

    g_attitude_file = strcat(test_name, '-GND_ATTITUDE.txt');
    if exist(g_attitude_file, 'file')
        g_attitude_data = dlmread(g_attitude_file);

        g_attitude_roll = g_attitude_data(:,1);
        g_attitude_pitch = g_attitude_data(:,2);
        g_attitude_yaw = g_attitude_data(:,3);
        g_attitude_state = g_attitude_data(:,4);

        disp([' - GND_ATTITUDE',10,9,...
            '(g_attitude_roll, g_attitude_pitch, g_attitude_yaw,',10,9,...
            ' g_attitude_state)']);
    end

    g_pos_file = strcat(test_name,'-GND_POS.txt');
    if exist(g_pos_file, 'file')
        g_pos_data = dlmread(g_pos_file);

        g_pos_n = g_pos_data(:,1);
        g_pos_n_vel = g_pos_data(:,2);
        g_pos_n_acc = g_pos_data(:,3);
        g_pos_e = g_pos_data(:,4);
        g_pos_e_vel = g_pos_data(:,5);
        g_pos_e_acc = g_pos_data(:,6);
        g_pos_d = g_pos_data(:,7);
        g_pos_d_vel = g_pos_data(:,8);
        g_pos_d_acc = g_pos_data(:,9);
        g_pos_state = g_pos_data(:,10);

        disp([' - GND_POS',10,9,...
            '(g_pos_n, g_pos_e, g_pos_d,',10,9,...
            ' g_pos_state)']);
    end

    waypoint_file = strcat(test_name, '-WAYPOINT.txt');
    if exist(waypoint_file, 'file')
        waypoint_data = dlmread(waypoint_file);

        waypoint_n = waypoint_data(:,1);
        waypoint_e = waypoint_data(:,2);
        waypoint_d = waypoint_data(:,3);
        waypoint_state = waypoint_data(:,4);

        disp([' - WAYPOINT',10,9,...
            '(waypoint_n, waypoint_e, waypoint_d,',10,9,...
            ' waypoint_state)']);
    end

    heartbeat_file = strcat(test_name, '-HEARTBEAT.txt');
    if exist(heartbeat_file)
        heartbeat_data = dlmread(heartbeat_file);

        heartbeat_mode = heartbeat_data(:,1);
        heartbeat_cmd = heartbeat_data(:,2);
        heartbeat_stick1 = heartbeat_data(:,3);
        heartbeat_stick2 = heartbeat_data(:,4);
        heartbeat_state = heartbeat_data(:,5);

        disp([' - HEARTBEAT',10,9,...
            '(heartbeat_mode, heartbeat_cmd,',10,9,...
            ' heartbeat_stick1, heartbeat_stick2,',10,9,...
            ' heartbeat_state)']);
    end

    attitude_ctr_test_file = strcat(test_name, '-ATTITUDE_CTR_TEST.txt');
    if exist(attitude_ctr_test_file, 'file')
        attitude_ctr_test_data = dlmread(attitude_ctr_test_file);

        attitude_ctr_test_t = attitude_ctr_test_data(:,1);
        attitude_ctr_test_r = attitude_ctr_test_data(:,2);
        attitude_ctr_test_p = attitude_ctr_test_data(:,3);
        attitude_ctr_test_y = attitude_ctr_test_data(:,4);
        attitude_ctr_test_d1 = attitude_ctr_test_data(:,5);
        attitude_ctr_test_d2 = attitude_ctr_test_data(:,6);
        attitude_ctr_test_d3 = attitude_ctr_test_data(:,7);
        attitude_ctr_test_d4 = attitude_ctr_test_data(:,8);
        attitude_ctr_test_state = attitude_ctr_test_data(:,9);

        disp([' - ATTITUDE_CTR_TEST',10,9,...
            '(attitude_ctr_test_t,',10,9,...
            ' attitude_ctr_test_r, attitude_ctr_test_p, attitude_ctr_test_y,',10,9,...
            ' attitude_ctr_test_d1, attitude_ctr_test_d2,',10,9,...
            ' attitude_ctr_test_d3, attitude_ctr_test_d4,',10,9,...
            ' attitude_ctr_test_state)']);
    end
    
    internal_sp_file = strcat(test_name, '-INTERNAL_SP.txt');
    if exist(internal_sp_file, 'file')
        internal_sp_data = dlmread(internal_sp_file);

        internal_sp_p = internal_sp_data(:,1);
        internal_sp_q = internal_sp_data(:,2);
        internal_sp_r = internal_sp_data(:,3);
        internal_sp_u = internal_sp_data(:,4);
        internal_sp_v = internal_sp_data(:,5);
        internal_sp_w = internal_sp_data(:,6);
        internal_sp_state = internal_sp_data(:,7);

        disp([' - INTERNAL_SP',10,9,...
            '(internal_sp_p, internal_sp_q, internal_sp_r,',10,9,...
            ' internal_sp_u, internal_sp_v, internal_sp_w,',10,9,...
            ' internal_sp_state)']);
    end
       
    clear -regexp file$ data$
    save(test_name);
end

function result = yes_no_prompt(message)
    s = input([message ' ? (y/n) '], 's');
    result = strcmp(s, 'y');
end

function new_data = remove_spurious_measurements(data, cutoff)
    cutoff_value = std(data)*cutoff;
    
    new_data = data; 
    new_data(abs(data -mean(data)) > cutoff_value) = NaN;
end