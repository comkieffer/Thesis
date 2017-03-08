
function make_dashboard(test_name, comparator)
    
    % ensure that this script is run from the 'Hardware Testing' folder
    folders = regexp(pwd, filesep, 'split');
    if ~strcmp(folders(end), 'Hardware Testing')
        error('This script must be run from the ''Hardware Testing'' folder');
    end
    
    % Load the data for this test
    test_data_file = fullfile( ...
        pwd, 'test_results', test_name, 'parsed_logs', [test_name '.mat']);
    if ~exist(test_data_file)
        error('Unable to locate test data file. Expected it at: %s', test_data_file);
    end
    fprintf('Loading new test data from: %s\n', test_data_file);
    
    new_test_data = load(test_data_file);
    
    % Load the base case data (initial Hinf controller)
    if nargin == 2
        if strcmp(comparator, 'hinf')
            base_test_name = 'test_hinf.mat';
            base_data_file = which(base_test_name);
            if isempty(base_data_file)
                error('Unable to locate base data file for <%s>', base_test_name);
            end
            fprintf('Loading base (hinf) test data from: %s\n', base_data_file);

            base_test_data = load(base_data_file); 
        else
            base_data_file = which([comparator, '.mat']);
            if isempty(base_data_file)
                error('Unable to locate dataset %s', comparator);
            end
            
            base_test_data = load(base_data_file); 
        end
    end
    

    
    % Finally start drawing the dashboard 
    
        % Used in the simulink model that we're about to run
    Ts = .01;
    model_theta_sp = [
        (Ts:length(new_test_data.attitude_ctr_test_p)) .* Ts;  
        rad2deg(new_test_data.attitude_ctr_test_p')
    ]';
    assignin('base', 'model_theta_sp', model_theta_sp);

    if ~evalin('base', 'exist(''OptimalOuterController'', ''var'')')
        error('The required simulation variables are missing from the workspace');
    end
    
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
    
    new_data_time_vec = [1:length(new_test_data.o_attitude_roll)] .* .01; 

    width = 2; height = 3;
    plot_idx = @(x, y) (x-1) * width + y;
    figure();
        ax11 = subplot(height, width, [1, 3]);
            plot( ...
                new_data_time_vec , new_test_data.o_attitude_pitch, ...
                new_data_time_vec, rad2deg(new_test_data.attitude_ctr_test_p), 'g--' ...
            ); grid minor;
            if exist('base_test_data', 'var')
                hold on; 
                base_data_time_vec = [1:length(base_test_data.o_attitude_roll)] .* .01;
                plot(base_data_time_vec, base_test_data.o_attitude_pitch)
            end
            
            title('Pitch')
            ylabel('Angle (°)'); 
            
        ax21 = subplot(height, width, plot_idx(3, 1));
            plot( ...
                new_data_time_vec , new_test_data.o_attitude_q, ...
                0, 0, 'g--' ...
            ); grid minor;
            if exist('base_test_data', 'var')
                hold on; 
                plot(base_data_time_vec, base_test_data.o_attitude_q, '--');
                legend('New VRFT', 'Set Point', comparator, 'Location', 'SouthEast');
            else
                legend('New VRFT', 'Set Point', 'Location', 'SouthEast');
            end
            
            ylabel('Rate (°/s)'); xlabel('Time (s)');
            

        ax12 = subplot(height, width, plot_idx(1, 2));
            plot(new_data_time_vec , new_test_data.o_attitude_pitch, ...
                 theta_sim.Time, theta_sim.Data, ...
                 model_theta_sp(:, 1), model_theta_sp(:, 2), 'g--' ...
            ); grid minor;
            title('Comparision of Real & Simulated Signals');
            ylabel('Pitch Angle (°)');
            legend('Measured', 'Simultated', 'Set Point');
            
        ax22 = subplot(height, width, plot_idx(2, 2));
            plot(theta_dot_sim.Time, theta_dot_sim.Data, ...
                 new_data_time_vec , new_test_data.o_attitude_q ...
            ); grid minor;
            ylabel('Pitch Rate (°/s)');
            legend('Simultated', 'Measured');

        ax32 = subplot(height, width, plot_idx(3, 2));
            plot(dM_sim.Time, dM_sim.Data, ...
                new_data_time_vec, new_test_data.flight_ctr_m ...
            ); grid minor;
            ylabel('Control Effort');                 
            legend('Simultated');
            
    condense_subplots_vertical([ax11, ax21]);
    condense_subplots_vertical([ax12, ax22, ax32]);

    figure();
        plot( ...
            new_data_time_vec , new_test_data.o_attitude_pitch, ...
            new_data_time_vec, rad2deg(new_test_data.attitude_ctr_test_p), 'g--' ...
        ); grid minor;
        if exist('base_test_data', 'var')
            hold on; 
            base_data_time_vec = [1:length(base_test_data.o_attitude_roll)] .* .01;
            plot(base_data_time_vec, base_test_data.o_attitude_pitch)
            legend('New VRFT', 'Set Point', comparator, 'Location', 'SouthEast');
        else
            legend('New VRFT', 'Set Point', 'Location', 'SouthEast');
        end

        title('Pitch')
        ylabel('Angle (°)'); xlabel('Time (s)');
    
end

