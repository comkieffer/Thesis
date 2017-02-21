%% Parser plot                                  %
% Author: Mattia Giurato,Alessandro De Angelis  %
% Last review: 2016/12/09                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matFile = parsLog( log )

%% Files Parameters

LOG_PARSER = which('logParser.jar');
fprintf('Found jar file: %s\n', LOG_PARSER);

LOGS_FOLDER = 'parsed_logs';

LOG_NAME = log;
LOG_TYPE = '.txt';
LOG_FOLDER = fullfile('..', LOGS_FOLDER, LOG_NAME);
LOG_FILE = strcat(LOG_NAME, LOG_TYPE);

LOG_CMD = ['java -jar','  "',LOG_PARSER,'"  ',LOG_FILE];
fprintf('Executing parse command: %s\n', LOG_CMD);

SAVE_FILE_TYPE = '.mat';
SAVE_FILE_NAME = LOG_NAME;
SAVE_FILE = strcat(SAVE_FILE_NAME,SAVE_FILE_TYPE);

clear SAVE_FILE_NAME;
clear SAVE_FILE_TYPE;

IMU_RAW_SUFFIX = '-IMU_RAW';
O_ATTITUDE_SUFFIX = '-ON_ATTITUDE';
O_ATTITUDE_Q_SUFFIX = '-ON_ATTITUDE_QUAT';
O_POS_BODY_SUFFIX = '-ON_POS_BODY';
O_POS_NED_SUFFIX = '-ON_POS_NED';
BAROMETER_SUFFIX = '-BARO';
PROXIMITY_SUFFIX = '-PROXY';
GPS_SUFFIX = '-GPS';
RADIO_SUFFIX = '-RADIO';
MIXER_CTR_SUFFIX = '-MIXER';
FLIGHT_CTR_SUFFIX = '-FLIGHT_CTR';
G_ATTITUDE_SUFFIX = '-GND_ATTITUDE';
G_POS_SUFFIX = '-GND_POS';
WAYPOINT_SUFFIX = '-WAYPOINT';
HEARTBEAT_SUFFIX = '-HEARTBEAT';
ATTITUDE_CTR_TEST_SUFFIX = '-ATTITUDE_CTR_TEST';
INTERNAL_SP_SUFFIX = '-INTERNAL_SP';

%% Parsing

system(LOG_CMD);
clear LOG_CMD;
clear LOG_FILE;
clear LOG_PARSER;

%% Import data logged

cd(LOG_FOLDER)
clear LOG_FOLDER;

disp(' ');
disp(' ');
disp('Stored Data:');

try
    imu_raw_file = strcat(LOG_NAME,IMU_RAW_SUFFIX,LOG_TYPE);
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
    
    disp([IMU_RAW_SUFFIX,10,9,...
        '(imu_raw_acc_x, imu_raw_acc_y, imu_raw_acc_z,',10,9,...
        ' imu_raw_gyro_x, imu_raw_gyro_y, imu_raw_gyro_z,',10,9,...
        ' imu_raw_mag_x, imu_raw_mag_y, imu_raw_mag_z,',10,9,...
        ' imu_raw_state)']);
    
catch
end

clear IMU_RAW_SUFFIX;
clear imu_raw_data;
clear imu_raw_file;

try
    o_attitude_file = strcat(LOG_NAME,O_ATTITUDE_SUFFIX,LOG_TYPE);
    o_attitude_data = dlmread(o_attitude_file);
    
    o_attitude_roll = o_attitude_data(:,1);
    o_attitude_pitch = o_attitude_data(:,2);
    o_attitude_yaw = o_attitude_data(:,3);
    o_attitude_p = o_attitude_data(:,4);
    o_attitude_q = o_attitude_data(:,5);
    o_attitude_r = o_attitude_data(:,6);
    o_attitude_state = o_attitude_data(:,7);
    
    disp([O_ATTITUDE_SUFFIX,10,9,...
        '(o_attitude_roll, o_attitude_pitch, o_attitude_yaw,',10,9,...
        ' o_attitude_p, o_attitude_q, o_attitude_r,',10,9,...
        ' o_attitude_state)']);
catch
end

clear O_ATTITUDE_SUFFIX;
clear o_attitude_file;
clear o_attitude_data;

try
    o_attitude_q_file = strcat(LOG_NAME,O_ATTITUDE_Q_SUFFIX,LOG_TYPE);
    o_attitude_q_data = dlmread(o_attitude_q_file);
    
    o_attitude_q1 = o_attitude_q_data(:,1);
    o_attitude_q2 = o_attitude_q_data(:,2);
    o_attitude_q3 = o_attitude_q_data(:,3);
    o_attitude_q4 = o_attitude_q_data(:,4);
    o_attitude_q_bias = o_attitude_q_data(:,5:7);
    o_attitude_q_state = o_attitude_q_data(:,8);
    
    disp([O_ATTITUDE_Q_SUFFIX,10,9,...
        '(o_attitude_q1, o_attitude_q2, o_attitude_q3, o_attitude_q4,',10,9,...
        ' o_attitude_qt_bias, o_attitude_q_state)']);
catch
end

clear o_attitude_q_file;
clear o_attitude_q_data;
clear O_ATTITUDE_Q_SUFFIX;

try
    o_pos_body_file = strcat(LOG_NAME,O_POS_BODY_SUFFIX,LOG_TYPE);
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
    
    disp([O_POS_BODY_SUFFIX,10,9,...
        '(o_pos_body_x, o_pos_body_u, o_pos_body_u_dot,',10,9,...
        ' o_pos_body_y, o_pos_body_v, o_pos_body_v_dot,',10,9,...
        ' o_pos_body_z, o_pos_body_w, o_pos_body_w_dot,',10,9,...
        ' o_pos_body_state)']);
catch
end

clear o_pos_body_file;
clear o_pos_body_data;
clear O_POS_BODY_SUFFIX;


try
    o_pos_ned_file = strcat(LOG_NAME,O_POS_NED_SUFFIX,LOG_TYPE);
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
    
    disp([O_POS_NED_SUFFIX,10,9,...
        '(o_pos_ned_n, o_pos_ned_n_vel, o_pos_ned_n_acc,',10,9,...
        ' o_pos_ned_e, o_pos_ned_e_vel, o_pos_ned_e_acc,',10,9,...
        ' o_pos_ned_d, o_pos_ned_d_vel, o_pos_ned_d_acc,',10,9,...
        ' o_pos_ned_state)']);
catch
end

clear o_pos_ned_file;
clear o_pos_ned_data;
clear O_POS_NED_SUFFIX;

try
    baro_file = strcat(LOG_NAME,BAROMETER_SUFFIX,LOG_TYPE);
    baro_data = dlmread(baro_file);
    
    baro_pressure = baro_data(:,1);
    baro_state = baro_data(:,2);
    
    disp([BAROMETER_SUFFIX,10,9,...
        '(baro_pressure, baro_state)']);
catch
end

clear BAROMETER_SUFFIX;
clear baro_file;
clear baro_data;

try
    proxy_file = strcat(LOG_NAME,PROXIMITY_SUFFIX,LOG_TYPE);
    proxy_data = dlmread(proxy_file);
    
    proxy_values = proxy_data(:,1:6);
    proxy_state = proxy_data(:,7);
    
    disp([PROXIMITY_SUFFIX,10,9,...
        '(proxy_values, proxy_state)']);
catch
end

clear PROXIMITY_SUFFIX;
clear proxy_file;
clear proxy_data;

try
    gps_file = strcat(LOG_NAME,GPS_SUFFIX,LOG_TYPE);
    gps_data = dlmread(gps_file);
    
    gps_fix = gps_data(:,1);
    gps_lat = gps_data(:,2);
    gps_lng = gps_data(:,3);
    gps_alt = gps_data(:,4);
    gps_state = gps_data(:,5);
    
    disp([GPS_SUFFIX,10,9,...
        '(gps_fix, gps_lat, gps_lon, gps_alt, gps_state)']);
catch
end

clear gps_file;
clear gps_data;
clear GPS_SUFFIX;

try
    radio_file = strcat(LOG_NAME,RADIO_SUFFIX,LOG_TYPE);
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
    
    disp([RADIO_SUFFIX,10,9,...
        '(radio_cmd, radio_mode, radio_fz,',10,9,...
        ' radio_roll, radio_pitch, radio_yaw,',10,9,...
        ' radio_n, radio_e, radio d,',10,9,...
        ' radio_u, radio_v, radio_w,',10,9,...
        ' radio_p, radio_q, radio_r,',10,9,...
        ' radio_state)']);
catch
end

clear RADIO_SUFFIX;
clear radio_file;
clear radio_data;

try
    mixer_ctr_file = strcat(LOG_NAME,MIXER_CTR_SUFFIX,LOG_TYPE);
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
    
    disp([MIXER_CTR_SUFFIX,10,9,...
        '(mixer_m1, mixer_m2, mixer_m3, mixer_m4,',10,9,...
        ' mixer_s1, mixer_s2, mixer_s3, mixer_s4,',10,9,...
        ' mixer_state)']);
catch
end

clear mixer_ctr_file;
clear mixer_ctr_data;
clear MIXER_CTR_SUFFIX;

try
    flight_ctr_file = strcat(LOG_NAME,FLIGHT_CTR_SUFFIX,LOG_TYPE);
    flight_ctr_data = dlmread(flight_ctr_file);
    
%     flight_ctr_t = flight_ctr_data(:,1);
%     flight_ctr_l = flight_ctr_data(:,2);
%     flight_ctr_m = flight_ctr_data(:,3);
%     flight_ctr_n = flight_ctr_data(:,4);
%     flight_ctr_r_ref = flight_ctr_data(:,5);
%     flight_ctr_p_ref = flight_ctr_data(:,6);
%     flight_ctr_y_ref = flight_ctr_data(:,7);
%     flight_ctr_n_ref = flight_ctr_data(:,8);
%     flight_ctr_e_ref = flight_ctr_data(:,9);
%     flight_ctr_d_ref = flight_ctr_data(:,10);
%     flight_ctr_state = flight_ctr_data(:,11);
%     
%     disp([FLIGHT_CTR_SUFFIX,10,9,...
%         '(flight_ctr_t,',10,9,...
%         ' flight_ctr_l, flight_ctr_m, flight_ctr_n,',10,9,...
%         ' flight_ctr_r_ref, flight_ctr_p_ref, flight_ctr_y_ref,',10,9,...
%         ' flight_ctr_n_ref, flight_ctr_e_ref, flight_ctr_d_ref,',10,9,...
%         ' flight_ctr_state)']);

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
    disp([FLIGHT_CTR_SUFFIX,10,9,...
        '(flight_ctr_fx, flight_ctr_fy, flight_ctr_fz,',10,9,...
        ' flight_ctr_l, flight_ctr_m, flight_ctr_n,',10,9,...
        ' flight_ctr_r_ref, flight_ctr_p_ref, flight_ctr_y_ref,',10,9,...
        ' flight_ctr_n_ref, flight_ctr_e_ref, flight_ctr_d_ref,',10,9,...
        ' flight_ctr_state)']);
catch
end

clear flight_ctr_file;
clear flight_ctr_data;
clear FLIGHT_CTR_SUFFIX;

try
    g_attitude_file = strcat(LOG_NAME,G_ATTITUDE_SUFFIX,LOG_TYPE);
    g_attitude_data = dlmread(g_attitude_file);
    
    g_attitude_roll = g_attitude_data(:,1);
    g_attitude_pitch = g_attitude_data(:,2);
    g_attitude_yaw = g_attitude_data(:,3);
    g_attitude_state = g_attitude_data(:,4);
    
    disp([G_ATTITUDE_SUFFIX,10,9,...
        '(g_attitude_roll, g_attitude_pitch, g_attitude_yaw,',10,9,...
        ' g_attitude_state)']);
catch
end

clear g_attitude_file;
clear g_attitude_data;
clear G_ATTITUDE_SUFFIX;

try
    g_pos_file = strcat(LOG_NAME,G_POS_SUFFIX,LOG_TYPE);
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
    
    disp([G_POS_SUFFIX,10,9,...
        '(g_pos_n, g_pos_e, g_pos_d,',10,9,...
        ' g_pos_state)']);
catch
end

clear g_pos_file;
clear g_pos_data;
clear G_POS_SUFFIX;

try
    waypoint_file = strcat(LOG_NAME,WAYPOINT_SUFFIX,LOG_TYPE);
    waypoint_data = dlmread(waypoint_file);
    
    waypoint_n = waypoint_data(:,1);
    waypoint_e = waypoint_data(:,2);
    waypoint_d = waypoint_data(:,3);
    waypoint_state = waypoint_data(:,4);
    
    disp([WAYPOINT_SUFFIX,10,9,...
        '(waypoint_n, waypoint_e, waypoint_d,',10,9,...
        ' waypoint_state)']);
catch
end

clear waypoint_file;
clear waypoint_data;
clear WAYPOINT_SUFFIX;

try
    heartbeat_file = strcat(LOG_NAME,HEARTBEAT_SUFFIX,LOG_TYPE);
    heartbeat_data = dlmread(heartbeat_file);
    
    heartbeat_mode = heartbeat_data(:,1);
    heartbeat_cmd = heartbeat_data(:,2);
    heartbeat_stick1 = heartbeat_data(:,3);
    heartbeat_stick2 = heartbeat_data(:,4);
    heartbeat_state = heartbeat_data(:,5);
    
    disp([HEARTBEAT_SUFFIX,10,9,...
        '(heartbeat_mode, heartbeat_cmd,',10,9,...
        ' heartbeat_stick1, heartbeat_stick2,',10,9,...
        ' heartbeat_state)']);
catch
end

clear heartbeat_file;
clear heartbeat_data;
clear HEARTBEAT_SUFFIX;

try
    attitude_ctr_test_file = strcat(LOG_NAME,ATTITUDE_CTR_TEST_SUFFIX,LOG_TYPE);
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
    
    disp([ATTITUDE_CTR_TEST_SUFFIX,10,9,...
        '(attitude_ctr_test_t,',10,9,...
        ' attitude_ctr_test_r, attitude_ctr_test_p, attitude_ctr_test_y,',10,9,...
        ' attitude_ctr_test_d1, attitude_ctr_test_d2,',10,9,...
        ' attitude_ctr_test_d3, attitude_ctr_test_d4,',10,9,...
        ' attitude_ctr_test_state)']);
catch
end

clear attitude_ctr_test_file;
clear attitude_ctr_test_data;
clear ATTITUDE_CTR_TEST_SUFFIX;

try
    internal_sp_file = strcat(LOG_NAME,INTERNAL_SP_SUFFIX,LOG_TYPE);
    internal_sp_data = dlmread(internal_sp_file);
    
    internal_sp_p = internal_sp_data(:,1);
    internal_sp_q = internal_sp_data(:,2);
    internal_sp_r = internal_sp_data(:,3);
    internal_sp_u = internal_sp_data(:,4);
    internal_sp_v = internal_sp_data(:,5);
    internal_sp_w = internal_sp_data(:,6);
    internal_sp_state = internal_sp_data(:,7);
    
    disp([INTERNAL_SP_SUFFIX,10,9,...
        '(internal_sp_p, internal_sp_q, internal_sp_r,',10,9,...
        ' internal_sp_u, internal_sp_v, internal_sp_w,',10,9,...
        ' internal_sp_state)']);
catch
end

clear internal_sp_file;
clear internal_sp_data;
clear INTERNAL_SP_SUFFIX;

clear LOG_NAME;
clear LOG_TYPE;
clear LOGS_FOLDER;
clear ans log;

%% save data

save(SAVE_FILE)
matFile =SAVE_FILE;


%% END of Code