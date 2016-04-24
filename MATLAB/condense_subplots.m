
% Move 2 subplots closer in the figure window
%
% When we plot 2 subplots with the default settings MATLAB leaves enough space
% between them for each subplot to have a tick label and a title. 
%
% If we want to plot for example the position and speed of an object with time
% on the x axis it seems redundant to specify the time on each axis. This script
% will strip the ticks on the x axis from the upper plot and move the 2 plots
% closer together expanding them as necessary to fill the empty space.
%
% Inputs:
% 
% >> condense_subplots('name', 'value', ...)
%
% Where name is one of: 
% 
% * handle, The figure handle for the figure to manipulate. If not specified
% |gcf| is used.
% * upper, The index of the upper plot in the |handle.Children| array. If not
% specified, 2 is used.
% * lower, The index of the lowerer plot in the |handle.Children| array. If not
% specified, 2 is used.
% * padding, The amount of free space between the 2 figures. If not specified
% .08 is used. The padding should be specified in MATLAB figure units (from 0 to
% 1).
% * tight, When this option is specified the padding between the 2 plots is
% reduced even more and the tick labels on the y axis are adjusted so as not to
% overlap.
% 
% Note: The script assumes that there are only 2 subplots in the figure. 

function condense_subplots(varargin)
    ip = inputParser(); 
    ip.addOptional('handle', gcf()); 
    ip.addParameter('upper', -1);
    ip.addParameter('lower', -1);
    ip.addParameter('padding', .08);
    ip.addParameter('tight', false);
    ip.parse(varargin{:});
    
    % Extract the children that are axis objects
    fig_axes = ip.Results.handle.Children(...
        arrayfun(@(x) isa(x, 'matlab.graphics.axis.Axes'), ip.Results.handle.Children));
    if ip.Results.upper == -1 || ip.Results.lower == -1
        if length(fig_axes) ~= 2
            error('CondenseSubplots:Error', 'Unsupported number of plots. Specify the subplots manually with the ''upper'' and ''lower'' options');
        end
    end
    
    if ip.Results.upper == -1
        upper_axis = fig_axes(2);
    else
        upper_axis = ip.Results.handle.Children(ip.Results.upper);
    end
    
    if ip.Results.lower == -1
        lower_axis = fig_axes(1);
    else
        lower_axis = ip.Results.handle.Children(ip.Results.lower);
    end
    
    if lower_axis == upper_axis
        error('CondenseSubplots:Error', 'Upper and Lower plot cannot be the same');
    end    
    
    % After all this wrangling of parameters we can get to the meat of the
    % problem ...
    
    % FixMe: Hacky - Hacky way of figuring out if the 2 arays are the same
    if ~(length(upper_axis.XTick) == length(lower_axis.XTick) && ...
       sum(upper_axis.XTick == lower_axis.XTick) == length(upper_axis.XTick))
        error('CondenseSubplots:Error', 'Subplots have different ticks.');
    end
    upper_axis.XTickLabel = {}; 
    
    % Now we can start expanding the 2 plots. The position of the plots is
    % specified as :
    %
    % [ top_left, top_right, width, height ]
    
    make_struct = @(x) struct('x', x(1), 'y', x(2), 'w', x(3), 'h', x(4));
    
    upper_pos = make_struct(upper_axis.Position);
    lower_pos = make_struct(lower_axis.Position);
    
    free_space = upper_pos.y - (lower_pos.y + lower_pos.h); 
    move_amount = (free_space - ip.Results.padding) / 2;
    
    if ip.Results.tight
        % upper_axis.YTickLabel{1} = ' '; 
        % lower_axis.YTickLabel{end} = ' ';
        move_amount = (free_space - .01) / 2;
    end
    
    upper_axis.Position(2) = upper_axis.Position(2) - move_amount;
    upper_axis.Position(4) = upper_axis.Position(4) + move_amount;
    lower_axis.Position(4) = lower_axis.Position(4) + move_amount;
end
