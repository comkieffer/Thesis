
vrft_datasets  = load_data_files('vrft_data');
vrftd_datasets = load_data_files('vrftd_data');
hinf_datasets  = load_data_files('hinf_data');
hinfd_datasets = load_data_files('hinfd_data');

dataset = 4;

figure(); 
    subplot 121;
    plot(hinf_datasets{dataset}.o_attitude_pitch); hold on; 
    plot(rad2deg(hinf_datasets{dataset}.attitude_ctr_test_p));
    title('Hinf')
    
    subplot 122;
    plot(vrft_datasets{dataset}.o_attitude_pitch); hold on; 
    plot(rad2deg(vrft_datasets{dataset}.attitude_ctr_test_p));
    title('VRFT')

%% END CODE

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