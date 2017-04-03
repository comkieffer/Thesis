
% Simple helper to plot a value from one of the data files

function mkplot(test_name, datasets)
    
    data_mat_file = which([test_name '.mat']);
    fprintf('Loading data from %s\n', data_mat_file);
    data = load(data_mat_file);
    
    data_time_vec = [1:length(data.o_attitude_roll)] .* .01; 

    
    figure();
        for k = 1:length(datasets)
           plot(data_time_vec, data.(datasets{k}));
           hold on; 
        end
        
        legend(datasets, 'Interpreter', 'none');
end