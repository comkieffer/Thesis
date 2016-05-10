

function matlab2tikz_export(filename, varargin)
% matlab2tikz_export - Easily export matlab figures to tikz and streamline 
% the boilerlate.  
%
% Syntax: 
%
%	matlab2tikz_export('filename')
%	matlab2tikz_export('filename', ...)
% 
% matlab2tikz_export('filename') exports the current figure to tikz code
% and saves it in the specified file. If 'filename' does not have an
% extension then '.tikz' will be used.
%
% matlab2tikz_export('filename', ...) allows you to specify additional
% options that will be passed to matlab2tikz or cleanfigure. Available
% options are:
%
%   * minPOintsDistance <float> removes points that are too close (default
%   0.01)
%   * width <string> sets the figure width (default '\figurewidth')
%   * height <string> sets the figure height (default '\figureheight')
%   * showInfo <bool> allows you to toggle informational output (default
%   false)
%   * postProcessor <function handle> A function that will be called to 
%	modify the generated tikz code. The function should accept one 
%	argument: the tikz source and return the modified source.
%	* extraAxisOptions <string> sets some extra options on every axis 
%	(useful to modify the tick format)
%
% Additionally you can specifiy a global base folder by setting the
% global variable MATLAB2TIKZ_EXPORT_FOLDER.
%
% Examples
%	
%   matlab2tikz_export('myfile')
    
    % For some insane reason this isn't a builtin ...
    isfunction = @(fn) isa(fn, 'function_handle'); 

    p = inputParser; 
    p.addRequired('filename'                          , @ischar   );
    p.addOptional('minPointsDistance', 0.01           , @isnumeric);
    p.addOptional('width'            , '\figurewidth' , @ischar   );
    p.addOptional('height'           , '\figureheight', @ischar   );
    p.addOptional('showInfo'         , false          , @islogical);
    p.addOptional('postProcessor'    , 0              , isfunction);
    p.addOptional('extraAxisOptions' , ''             , @ischar   ); 
    p.addOptional('trim'             , true           , @islogical);     
    p.parse(filename, varargin{:});
    
    % Check if the user has a global path for matlab2tikz files
    global MATLAB2TIKZ_EXPORT_FOLDER;
    if ischar(MATLAB2TIKZ_EXPORT_FOLDER) && ~isempty(MATLAB2TIKZ_EXPORT_FOLDER)
        filename = fullfile(MATLAB2TIKZ_EXPORT_FOLDER, filename);
    end
    
    [~, ~, ext] = fileparts(filename);
    if isempty(ext) 
        filename = strcat(filename, '.tikz');
    end
      
    fprintf('Saving new figure to %s\n', filename);
        
    cleanfigure('minimumPointsDistance', p.Results.minPointsDistance);
    
    
    opts = { ...
        'showInfo' p.Results.showInfo
        'width'    p.Results.width
        'height'   p.Results.height
    }';


    if ~isempty(p.Results.extraAxisOptions) 
        cat(2, opts, {'extraAxisOptions'; p.Results.extraAxisOptions});
	end
	
    matlab2tikz(filename, opts{:});
    
	
    src = fileread(filename);

	% Do a quick trim of the axes
    if p.Results.trim
        src = strrep(src,                                          ...
            '\begin{tikzpicture}',                                 ...
            '\begin{tikzpicture}[trim axis left, trim axis right]' ...
        );   
    end
       
	if isfunction(p.Results.postProcessor)
        src = p.Results.postProcessor(src);
	end
		
	fid = fopen(filename, 'w');
	fwrite(fid, src);
	fclose(fid);
	
	
 
        