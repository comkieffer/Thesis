
%
% The testing pipeline:
%
% Yes, there are a bunch of scripts in here. Most of them even have a purpose.
% The first step when runnning a test is to run the 'inner_vrft_ct' and
% 'outer_vrft_ct' live scripts with the right options to generate the
% parameters of the inner and outer controllers.
%
% This should put |inner_pid_params| and |outer_pd_params| into your base
% workspace. 
%
% To start a test run this function. Decide on a test name eg. test_inner_1
% and run |prepare_test('test_inner_1')|. This will load the controller
% parameters, calculate the anti-windup term for the inner controller and
% generate three files: 
%
% 1. The Attitude_quadrotor.cpp file
% 2. the pitch_test file
% 3. params.mat
%
% The first file should be transfered to the computer running the |r2p-ide|
% and uploaded to the drone. 
% The second file contains the testing procedure to be run on the drone. Run
% it once the new firmware has been flashed. 
% The thrid file contains the parameters that have been used in an easily
% accessible format.
%
% Once the test has been run you can retrieve the data from the SD card by
% running |process_test_data|. This tool will grab the test data file frm the
% SD card and move it into the appropriate test folder.
%
% The tool will then run the parser on the file and retrieve the parsed log
% files form the parser directory so that it can load them all into a |.mat|
% file containing all the data.
%
% Finally, to take a peak at the data you can run |make_dashboard| to see what
% it all looks like. 
%

function prepare_test(test_name)
    
    % ensure that this script is run from the 'Hardware Testing' folder
    folders = regexp(pwd, filesep, 'split');
    if ~strcmp(folders(end), 'Hardware Testing')
        error('This script must be run from the ''Hardware Testing'' folder');
    end
    
    %% Step 1 - Verify the values of the parameters
     
    inner_pid_params = safe_evalin('base', 'inner_pid_params');
    outer_pd_params  = safe_evalin('base', 'outer_pd_params');
    
    if isempty(inner_pid_params) || isempty(outer_pd_params)
        fprintf('\nError: ''inner_pid_params'' and ''outer_pid_params'' are not set in the base workspace\n\n');
        return
    end

    fprintf('\nFound existing inner controller parameters: \n');
    fprintf('    Inner Controller: Kp = %.4f, Ki = %.4f, Kd = %.4f\n', ...
        inner_pid_params(1), inner_pid_params(2), inner_pid_params(3));

    if ~yes_no_prompt('Proceed with these parameters for the inner controller')
        return;
    end
    
    % TODO: Check this formula
    inner_anti_windup = 0.0;
    if (inner_pid_params(2) ~= 0.0 && inner_pid_params(3) ~= 0.0)
        inner_anti_windup = sqrt(inner_pid_params(3) / inner_pid_params(2));
    end
    
    fprintf('\nFound existing outer controller parameters: \n');
    fprintf('    Outer Controller: Kp = %.4f, Kd = %.4f\n', ...
        outer_pd_params(1), outer_pd_params(2));

    if ~yes_no_prompt('Proceed with these parameters for the outer controller')
        return;
    end
    
    %% Step 2 - Create the .cpp file to upload to the quadrotor
    
    test_folder = fullfile('test_results', test_name);
    
    fprintf('\n');
    fprintf('Creating new folder for scripts & results: %s\n', test_folder);
    mkdir_safe(test_folder);
    
    fprintf('Generating Attitude_quadrotor.cpp file ...\n');
    
    parameters = struct( ...
        'Kp_pitch', outer_pd_params(1),  ...
        'Ki_pitch', 0.0,                 ...
        'Kd_pitch', outer_pd_params(2),  ...
        'Kp_q', inner_pid_params(1),     ...
        'Ki_q', inner_pid_params(2),     ...
        'Kd_q', inner_pid_params(3),     ...
        'Kb_q', inner_anti_windup        ...
    );

    template = LTemplate.load('templates/Attitude_quadrotor.cpp.tpl');
    code = template.render(parameters);
    
    controller_file = fullfile(test_folder, 'Attitude_quadrotor.cpp');
    fprintf('Writing new controller to %s\n', controller_file);
    fwrite_safe(controller_file, 'w+', code);
    
    modules_file = fullfile('/home/tibo/Programming/r2p-sdk/drones_firmware/Proximity_module/matlab_gen/Attitude_quadrotor_grt_rtw', 'Attitude_quadrotor.cpp');;
    fprintf('Copying controller file to %s\n', modules_file); 
    fwrite_safe(modules_file, 'w+', code);
    
    %% Step 3 - Savec the parameters to a file for safekeeping
    
    parameters_file = fullfile(test_folder, 'params.mat');
    fprintf('Saving test parameters to: %s\n', parameters_file); 
    save(parameters_file, 'parameters');
    
    %% Step 3 create the script to run 
    template = LTemplate.load('templates/pitch_test.m.tpl');
    code = template.render(struct('test_name', test_name));
    
    script_file = fullfile(test_folder, sprintf('pitch_%s.m', test_name));
    fprintf('Writing new ''pitch_test'' script file to %s\n', script_file);
    fwrite_safe(script_file, 'w+', code);
    
    fprintf('\nTest Ready. After running the test use ''process_test_data'' to process the test data\n'); 
end

function result = yes_no_prompt(message)
    s = input([message ' ? (y/n) '], 's');
    result = strcmp(s, 'y');
end

function result = safe_evalin(workspace, var)
    if evalin(workspace, sprintf('exist(''%s'', ''var'')', var))
        result = evalin(workspace, var);
    else
        result = [];
    end
end

function fwrite_safe(filename, permission, contents)
   [fid, err] = fopen(filename, permission);      
   if fid < 0 
       error('Unable to open %s. Error: %s\n', filename, err);
   end
   
   fwrite(fid, contents);
   fclose(fid);
end

function mkdir_safe(dirname)
    if ~exist(dirname, 'dir')
       [status, message, messageID] = mkdir(dirname);
       
       if ~status
           error('Unable to create directory <%i>. Error was: %s (Code %s)', status, message, messageID');
       end
    end
end