
function make_dashboard(test_name)
    
    % ensure that this script is run from the 'Hardware Testing' folder
    folders = regexp(pwd, filesep, 'split');
    if ~strcmp(folders(end), 'Hardware Testing')
        error('This script must be run from the ''Hardware Testing'' folder');
    end
    
    % Load the base case data (initial Hinf controller)
    base_test_name = 'test_hinf.mat';

    base_data_file = which(base_test_name);
    if isempty(base_data_file)
        error('Unable to locate base data file for <%s>', base_test_name);
    end

    base_test_data = load(base_data_file); 
    
    % Load the data for this test
    test_data_file = fullfile( ...
        pwd, 'test_results', test_name, 'parsed_logs', [test_name '.mat']);
    if ~exist(test_data_file)
        error('Unable to locate test data file. Expected it at: %s', test_data_file);
    end
    
    new_test_data = load(test_data_file);
    
    % Finally start drawing the dashboard 
    
    base_data_time_vec = [1:length(base_test_data.o_attitude_roll)] .* .01;
    new_data_time_vec = [1:length(new_test_data.o_attitude_roll)] .* .01; 
    
    width = 2; height = 3;
    plot_idx = @(x, y) (x-1) * width + y;
    figure();
        ax11 = subplot(height, width, plot_idx(1, 1));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_roll, ... 
                new_data_time_vec , new_test_data.o_attitude_roll, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_r, 'g--' ...
            ); 
            title('Angular Position')
            ylabel('Roll (°)');
        ax21 = subplot(height, width, plot_idx(2, 1));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_pitch, ... 
                new_data_time_vec , new_test_data.o_attitude_pitch, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_p, 'g--' ...
            ); 
            ylabel('Pitch (°)');
        ax31 = subplot(height, width, plot_idx(3, 1));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_yaw, ...
                new_data_time_vec , new_test_data.o_attitude_yaw, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_y, 'g--' ...
            ); 
            ylabel('Yaw (°)');
            xlabel('Time (s)');
            legend('Base H\infty', 'New VRFT', 'Set Point', 'Location', 'SouthEast');
        ax12 = subplot(height, width, plot_idx(1, 2));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_p, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_p ...
            ); 
            title('Angular Rate');
            ylabel('Roll Rate (°/s)');
        ax22 = subplot(height, width, plot_idx(2, 2));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_q, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_q ...
            ); 
            ylabel('Pitch Rate(°/s)');
        ax32 = subplot(height, width, plot_idx(3, 2));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_r, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_r ...
            ); 
            ylabel('Yaw Rate (°/s)');    
            xlabel('Time (s)');
         
%     condense_subplots_vertical([ax11, ax21, ax31]);
%     condense_subplots_vertical([ax12, ax22, ax32]);
end

