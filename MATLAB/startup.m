

function startup() 
    % This is the main entry point. 
    %
    % We want to look for subidrectories that contain script files and print
    % a list of directories and the files they provide. The list of extensions
    % we search for are contained in the |MATLAB_EXTENSIONS| and
    % |SIMULINK_EXTENSIONS| variables. The list is by no means exhaustive.
    % Feel free to add to it.

    % Start by detecting the presence or absence of a global startup file. If the file exists we run
    % it before doing anything else.
    root_startup = userpath();
    root_startup = fullfile(root_startup(1:end-1), 'startup.m');

    if exist(root_startup, 'file') == 2
        fprintf('Running root startup file: <strong>%s</strong>\n', root_startup);
        run(root_startup);
    end

    % Now we can start loading the subdirectories in the current folder. 

    MATLAB_EXTENSIONS = {'.m', '.p' '.mlx'};
    SIMULINK_EXTENSIONS = {'.slx'};


    fprintf('Scanning local directories ... \n\n');
    base_dir = pwd();
    paths = genpath('.');

    folders = strsplit(paths, pathsep);

    new_paths = '';
    for k = 1:length(folders)
        folder = folders{k};
        folder = folder(2:end); % Strip out the initial '.' character
        
        % Exclude '.' and '..' from the listing.
        if isempty(folder) || strcmp(folder, '.')
            continue
        end
        
        % We want to exclude folders that do not contain MATLAB or SIMULINK files.

        files = dir(strcat(base_dir, folder));
       
        matlab_files = cell(0);
        simulink_files = cell(0);
        for l = 1:length(files)
            [~, name, ext] = fileparts(files(l).name);

            if find(strcmp(ext, MATLAB_EXTENSIONS))
                matlab_files{end+1} = name;
            elseif find(strcmp(ext, MATLAB_EXTENSIONS))
                simulink_files{end+1} = name;
            end
        end
        
        % If the folder has at least one MATLAB or SIMULINK file we add it to the path and print a
        % message to the screen.
        abs_path = fullfile(base_dir, folder);
        
        if ~isempty(matlab_files) || ~isempty(simulink_files)
            new_paths = strcat(new_paths, abs_path, ';');
            fprintf('<strong>%s</strong> provides: \n', shorten_path(abs_path));    
        end

        if ~isempty(matlab_files)
            matlab_files = join_cells(matlab_files, ', ');
            fprintf('  Scripts:\n');
            fprintf('%s\b\b\b\n', wrap_string(matlab_files, '  |  '));
        end

        if ~isempty(simulink_files)
            simulink_files = join_cells(simulink_files);
            fprintf('  Simulink Models:\n');
            fprintf('%s\b\b\b\n, ', wrap_string(simulink_files, '  |  '));
        end
    end

    % Actually add all the folders to the path
    addpath(new_paths);
    
    
    
    % disable warnings that pop up in the compiled parts of VRFT toolbox
    % that we can't bloody well change
    % warning('off', 'Ident:estimation:invalidFocusOption2');
end

function short_path = shorten_path(abs_path, max_path_len)
    % Shorten the path so that it is less than max_path_len but still print
    % the entire filename and extension. 
    
    if ~exist('max_path_len', 'var') max_path_len = 80; end

    if length(abs_path) > max_path_len 
        [path, file, ext] = fileparts(abs_path);

        remaining_chars = max_path_len - 1 - length(file) - length(ext);

        if length(path) > remaining_chars
            path = strcat(path(1:remaining_chars-3), '...');
        end

        short_path = strcat(path, '/', file, ext'); 
    else 
        short_path = abs_path;
    end
end

function joined_str = join_cells(str, joiner)
    joined_str = ...
        cell2mat(cellfun(@(x) [x joiner], str, 'UniformOutput', false));
end

function wrapped_str = wrap_string(str, indent)
    % Wrap the string to the width of the command window
    
    if ~exist('indent', 'var'); indent = ''; end
            
    items = strsplit(str);
    win_size = matlab.desktop.commandwindow.size;
    width = win_size(1);
    
    lines = {};
    this_line = indent;
    for k = 1:length(items)
        if length(this_line) + length(items{k}) + 1 < width
            this_line = [this_line ' ' items{k}];
        else
            lines{end+1} = this_line;
            this_line = [indent items{k}];
        end
    end
    lines{end+1} = this_line;
    
    wrapped_str = sprintf(join_cells(lines, '\n'));
end
