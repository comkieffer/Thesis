function resize_data(test_name)
    data = load(test_name);
    
    data_fields = fieldnames(data); 
    data_len = [];
    for k = 1:length(data_fields)
       if ~strcmp(data_fields{k}, 'test_name')
            data_len(end+1) = length(data.(data_fields{k}));
       end
    end
    min_data_len = min(data_len);
    max_data_len = max(data_len);
    
    fprintf('\nChecking dataset lengths ...\n');
    fprintf('  - Shortest data sequence is %i points long\n', min_data_len);
    fprintf('  - Longest data sequence is %i points long\n', max_data_len);
    
    if min_data_len ~= max_data_len
        warning('Some data set sizes vary. All datasets will be truncated to %i points', min_data_len);
        
        for k = 1:length(data_fields)
            if ~strcmp(data_fields{k}, 'test_name')
                data.(data_fields{k}) = data.(data_fields{k})(1:min_data_len);
            end
        end

        save(test_name, '-struct', 'data'); 
    end
end