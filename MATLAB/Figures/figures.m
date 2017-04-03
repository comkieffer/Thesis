
% If I were smart I would save the stuff I need into a .mat file and load that
% but time is running out ...
% clear all;

close all; 

load '../quad_copter_models.mat';

vrft_datasets  = load_data_files('vrft_data');
vrftd_datasets = load_data_files('vrftd_data');
hinf_datasets  = load_data_files('hinf_data');
hinfd_datasets = load_data_files('hinfd_data');

f = @(name) fullfile('../../Thesis-Report/Figures/Plots/', [name, '.dat']);

%% SimRes - PRBS sequence and outputs

vrft_data = table();
ol_data = load('../dati_id_ol_scalati.mat');

vrft_data.time      = ol_data.t;
vrft_data.dOmega    = ol_data.u;
vrft_data.q         = ol_data.yi;
vrft_data.q_deg     = rad2deg(vrft_data.q);

% Simulate the mixer input, the pitch angle (integrate) and re-simulate the
% pitch angle (Plant Model includes Mixer).prbs_inputs
vrft_data.dM    = lsim(Mixer^-1, vrft_data.dOmega, vrft_data.time);
vrft_data.theta = rad2deg(lsim(integrator, vrft_data.q, vrft_data.time));
vrft_data.q_sim = rad2deg(lsim(PlantModel, vrft_data.dM, vrft_data.time));

writetable(vrft_data, f('prbs_inputs'), 'FileType', 'text', 'Delimiter', '\t');

%% SimRes - Simulated controller Hi (junk)
%

himdl = load('hi_models.mat');

% load a set of experimental data to read the input signal
data = vrft_datasets{1};

% TODO: Export the model requirements and cntroller params cleanly.

sim_data = struct(); 
sim_data.set_point = rad2deg(data.attitude_ctr_test_p);
sim_data.time      = (1:length(sim_data.set_point))' .* .01; 
sim_data.theta     = rad2deg(lsim( ...
    himdl.OuterLoop_VRFT     , data.attitude_ctr_test_p, sim_data.time));
sim_data.ref_out   = rad2deg(lsim( ...
    himdl.OuterReferenceModel, data.attitude_ctr_test_p, sim_data.time));

writetable( struct2table(sim_data), ...
    f('sim_cl_hi'), 'FileType', 'text', 'Delimiter', '\t'); 

save_bode(f('simres_innerref_bode_hi' ), himdl.InnerReferenceModel);
save_bode(f('simres_innervrft_bode_hi'), himdl.InnerLoop_VRFT);
save_bode(f('simres_outerref_bode_hi' ), himdl.OuterReferenceModel);
save_bode(f('simres_outervrft_bode_hi'), himdl.OuterLoop_VRFT);

%% SimRes - Simulated Controller Normal.

normmdl = load('norm_models.mat');

% load a set of experimental data to read the input signal
data = vrft_datasets{1};

% TODO: Export the model requirements and cntroller params cleanly.

sim_data = struct(); 
sim_data.set_point = rad2deg(data.attitude_ctr_test_p);
sim_data.time      = (1:length(sim_data.set_point))' .* .01; 
sim_data.theta     = rad2deg(lsim( ...
    normmdl.OuterLoop_VRFT     , data.attitude_ctr_test_p, sim_data.time));
sim_data.ref_out   = rad2deg(lsim( ...
    normmdl.OuterReferenceModel, data.attitude_ctr_test_p, sim_data.time));

sim_data.theta_hinf = rad2deg(lsim( ...
    OuterLoop_Hinf     , data.attitude_ctr_test_p, sim_data.time));

writetable( struct2table(sim_data), ...
    f('sim_cl_norm'), 'FileType', 'text', 'Delimiter', '\t'); 

save_bode(f('simres_innerref_bode_norm' ), normmdl.InnerReferenceModel);
save_bode(f('simres_innervrft_bode_norm'), normmdl.InnerLoop_VRFT);
save_bode(f('simres_outerref_bode_norm' ), normmdl.OuterReferenceModel);
save_bode(f('simres_outervrft_bode_norm'), normmdl.OuterLoop_VRFT);



%% Experiemental Results - VRFT

data = vrft_datasets{1};

vrft_control_data = table(); 
vrft_control_data.time          = (1:length(data.o_attitude_roll))' .* .01; 
vrft_control_data.set_point     = rad2deg(data.attitude_ctr_test_p);
vrft_control_data.pitch_angle   = data.o_attitude_pitch;
vrft_control_data.pitch_rate    = data.o_attitude_q;
vrft_control_data.control_var_m = data.flight_ctr_m;

hinf_sr = lsim(OuterLoop_Hinf, PitchTestSequence.Theta, PitchTestSequence.Time);
vrft_control_data.pitch_angle_sim = lsim(...
    OuterLoop_VRFT, vrft_control_data.set_point, vrft_control_data.time);

writetable(...
    vrft_control_data, ...
    f('pitch_set_point_tracking_vrft'), ...
    'FileType', 'text', 'Delimiter', '\t'); 

%% Experiemental Results - Hinf

% Not 1 because the set point for {1} is incorrect for the first couple of
% samples.
data = hinf_datasets{3};

vrft_control_data = table(); 
vrft_control_data.time          = (1:length(data.o_attitude_roll))' .* .01; 
vrft_control_data.set_point     = rad2deg(data.attitude_ctr_test_p);
vrft_control_data.pitch_angle   = data.o_attitude_pitch;
vrft_control_data.pitch_rate    = data.o_attitude_q;
vrft_control_data.control_var_m = data.flight_ctr_m;

hinf_sr = lsim(OuterLoop_Hinf, PitchTestSequence.Theta, PitchTestSequence.Time);
vrft_control_data.pitch_angle_sim = lsim(...
    OuterLoop_VRFT, vrft_control_data.set_point, vrft_control_data.time);

writetable(...
    vrft_control_data, ...
    f('pitch_set_point_tracking_hinf'), ...
    'FileType', 'text', 'Delimiter', '\t'); 

%% MSE of the VRFT & Hinf test procedures

[this_mse, this_std] = allmse(vrft_datasets);
save_value('../../Thesis-Report/Tables/Data/vrft_mse.dat'          , this_mse);
save_value('../../Thesis-Report/Tables/Data/vrft_std.dat'          , this_std);

[this_mse, this_std] = allmse(vrftd_datasets);
save_value('../../Thesis-Report/Tables/Data/vrftd_mse.dat'          , this_mse);
save_value('../../Thesis-Report/Tables/Data/vrftd_std.dat'          , this_std);

[this_mse, this_std] = allmse(hinf_datasets);
save_value('../../Thesis-Report/Tables/Data/hinf_mse.dat'          , this_mse);
save_value('../../Thesis-Report/Tables/Data/hinf_std.dat'          , this_std);

[this_mse, this_std] = allmse(hinfd_datasets);
save_value('../../Thesis-Report/Tables/Data/hinfd_mse.dat'          , this_mse);
save_value('../../Thesis-Report/Tables/Data/hinfd_std.dat'          , this_std);


%% Disturbed tests - VRFT

clear data;
data = vrftd_datasets{1};

disturbed_vrft_data = table(); 
disturbed_vrft_data.time          = (1:length(data.o_attitude_roll))' .* .01; 
disturbed_vrft_data.set_point     = rad2deg(data.attitude_ctr_test_p);
disturbed_vrft_data.pitch_angle   = data.o_attitude_pitch;
disturbed_vrft_data.pitch_rate    = data.o_attitude_q;
disturbed_vrft_data.control_var_m = data.flight_ctr_m;

writetable(...
    disturbed_vrft_data, ...
    f('disturbed_control_vrft'), ...
    'FileType', 'text', 'Delimiter', '\t'); 

%% Disturbed tests - Hinf

clear data;
data = hinfd_datasets{1};

disturbed_hinf_data = table(); 
disturbed_hinf_data.time          = (1:length(data.o_attitude_roll))' .* .01; 
disturbed_hinf_data.set_point     = rad2deg(data.attitude_ctr_test_p);
disturbed_hinf_data.pitch_angle   = data.o_attitude_pitch;
disturbed_hinf_data.pitch_rate    = data.o_attitude_q;
disturbed_hinf_data.control_var_m = data.flight_ctr_m;

writetable(...
    disturbed_hinf_data, ...
    f('disturbed_control_hinf'), ...
    'FileType', 'text', 'Delimiter', '\t'); 


%% Utility functions 

function save_value(file, value)
    fid = fopen(file, 'w+'); 

    if fid < 0
       error(['Unable to open ' file]); 
    end

    fwrite(fid, num2str(value));
    fclose(fid); 
end

function save_bode(file, model)
    [mag, phase, wout] = bode(model);
    
    ref_mdl = struct2table(struct( ...
        'omega', squeeze(wout), ...
        'mag', squeeze(db(mag)), ...
        'phase', squeeze(phase) ...
    ));
    writetable( ref_mdl, ...    
        file, 'FileType', 'text', 'Delimiter', '\t'); 
end

function data = load_data_files(data_folder)
    vrft_files = dir(data_folder);
    data = cell(0);
    
    for k = 1:length(vrft_files) 
        this_file = fullfile(data_folder, vrft_files(k).name);
        if strcmp(this_file, '.') || strcmp(this_file, '..') || vrft_files(k).isdir
            continue;
        end
        data{end+1} = load(this_file);
    end
end

function [this_mse, this_variance] = allmse(datasets)
    mse_fun = @(ref, actual) mean((ref - actual).^2);

    individual_mse = [];
    for k = 1:length(datasets)
        len = min(length(datasets{k}.attitude_ctr_test_p), length(datasets{k}.o_attitude_p));
        individual_mse(k) = mse_fun(datasets{k}.attitude_ctr_test_p(1:len), datasets{k}.o_attitude_p(1:len));
    end

    this_mse = mean(individual_mse);
    this_variance = std(individual_mse);
end
