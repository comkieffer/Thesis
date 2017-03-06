
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
    fprintf('Loading base (hinf) test data from: %s\n', base_data_file);
    
    base_test_data = load(base_data_file); 
    
    % Load the data for this test
    test_data_file = fullfile( ...
        pwd, 'test_results', test_name, 'parsed_logs', [test_name '.mat']);
    if ~exist(test_data_file)
        error('Unable to locate test data file. Expected it at: %s', test_data_file);
    end
    fprintf('Loading new test data from: %s\n', test_data_file);
    
    new_test_data = load(test_data_file);
    
    % Finally start drawing the dashboard 
    
    base_data_time_vec = [1:length(base_test_data.o_attitude_roll)] .* .01;
    new_data_time_vec = [1:length(new_test_data.o_attitude_roll)] .* .01; 

    width = 3; height = 2;
    plot_idx = @(x, y) (x-1) * width + y;
    figure();
        ax11 = subplot(height, width, plot_idx(1, 1));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_roll, ... 
                new_data_time_vec , new_test_data.o_attitude_roll, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_, 'g--' ...
            ); 
            title('Roll')
            ylabel('Angle (°)');
        ax21 = subplot(height, width, plot_idx(2, 1));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_p, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_p, ...
                0, 0, 'g--' ...
            ); 
            ylabel('Rate (°/s)');
            xlabel('Time (s)');
            legend('Base H\infty', 'New VRFT', 'Set Point', 'Location', 'SouthEast');

        ax12 = subplot(height, width, plot_idx(1, 2));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_pitch, ... 
                new_data_time_vec , new_test_data.o_attitude_pitch, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_p, 'g--' ...
            ); 
            title('Pitch')
            ylabel('Angle (°)'); 
            
        ax22 = subplot(height, width, plot_idx(2, 2));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_q, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_q, ...
                0, 0, 'g--' ...
            ); 
            ylabel('Rate (°/s)');            
            xlabel('Time (s)');
            legend('Base H\infty', 'New VRFT', 'Set Point', 'Location', 'SouthEast');

        ax13 = subplot(height, width, plot_idx(1, 3));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_yaw, ... 
                new_data_time_vec , new_test_data.o_attitude_yaw, ...
                new_data_time_vec, new_test_data.attitude_ctr_test_y, 'g--' ...
            ); 
            title('Yaw')
            ylabel('Angle (°)');
        ax23 = subplot(height, width, plot_idx(2, 3));
            plot( ...
                base_data_time_vec, base_test_data.o_attitude_r, '--', ... 
                new_data_time_vec , new_test_data.o_attitude_r, ...
                0, 0, 'g--' ...
            ); 
            ylabel('Rate (°/s)');
            xlabel('Time (s)');
            legend('Base H\infty', 'New VRFT', 'Set Point', 'Location', 'SouthEast');

            
    condense_subplots_vertical([ax11, ax21]);
    condense_subplots_vertical([ax12, ax22]);
    condense_subplots_vertical([ax13, ax23]);
            
    % Used in the simulink model that we're about to run
    Ts = .01;
    model_theta_sp = [
        (Ts:length(new_test_data.attitude_ctr_test_p)) .* Ts;  
        rad2deg(new_test_data.attitude_ctr_test_p')
    ]';
    assignin('base', 'model_theta_sp', model_theta_sp);

    
    simout = sim('model', ...
        'SimulationMode', 'normal', ...
        'SaveState', 'on', ...
        'StateSaveName', 'xout', ...
        'SaveOutput', 'on', ...
        'OutputSaveName', 'yout', ...
        'SaveFormat', 'DataSet', ...
        'StopTime', num2str(model_theta_sp(end, 1)) ...
    );
    
    theta_sim = simout.get('yout').get('ThetaSim').Values;
    theta_dot_sim = simout.get('yout').get('ThetaDotSim').Values;
    dM_sim = simout.get('yout').get('dMSim').Values;

    width = 1; height = 3;
    plot_idx = @(x, y) (x-1) * width + y;
    
    figure();
        ax11 = subplot(height, width, plot_idx(1, 1));
            plot(theta_sim.Time, theta_sim.Data, ...
                 new_data_time_vec , new_test_data.o_attitude_pitch, ...
                 model_theta_sp(:, 1), model_theta_sp(:, 2), 'g--' ...
            ); 
            title('Comparision of Real & Simulated Signals');
            ylabel('Pitch Angle (°)');
            legend('Simultated', 'Measured', 'Set Point');
            
        ax21 = subplot(height, width, plot_idx(2, 1));
            plot(theta_dot_sim.Time, theta_dot_sim.Data, ...
                 new_data_time_vec , new_test_data.o_attitude_q ...
            );
            ylabel('Pitch Rate (°/s)');
            legend('Simultated', 'Measured');

        ax31 = subplot(height, width, plot_idx(3, 1));
            plot(dM_sim.Time, dM_sim.Data, ...
                new_data_time_vec, new_test_data.flight_ctr_p_ref ...
            );
            ylabel('Control Effort');                 
            legend('Simultated');

    condense_subplots_vertical([ax11, ax21, ax31]);

end

