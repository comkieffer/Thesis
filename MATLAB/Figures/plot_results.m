
DATA_FOLDER = 'hinfd_data';

vrft_files = dir(DATA_FOLDER);

clear vrft_data;
vrft_data = cell(0);
for k = 1:length(vrft_files) 
    this_file = fullfile(DATA_FOLDER, vrft_files(k).name);
    if strcmp(this_file, '.') || strcmp(this_file, '..') || vrft_files(k).isdir
        continue;
    end
        
    vrft_data{end+1} = load(this_file);
end

figure(); 
    for k = 1:length(vrft_data)
       time_vec = (1:length(vrft_data{k}.o_attitude_pitch)) .* .01;
       plot(time_vec, vrft_data{k}.o_attitude_pitch, 'DisplayName', vrft_files(k).name);
       hold on; 
    end
    
    legend('-DynamicLegend');