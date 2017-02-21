%% Parser plot                                  %
% Author: Mattia Giurato,Alessandro De Angelis  %
% Last review: 2016/12/09                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parsing

% README: 
%
% A new directory (parsed_logs) will be created in the parent directpry of the
% logs file to store the generated files of this tool.

function Parser(log_path)
    PATH_TO_RETURN = pwd;
    
    [log_folder, log_file, ~] = fileparts(log_path);
    
    cd(log_folder);
    load(parsLog(log_file));
    cd(PATH_TO_RETURN);
end
    
%% END OF CODE