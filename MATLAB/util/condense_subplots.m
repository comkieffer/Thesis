
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
% By default, the script will still leave enough space for the tick labels of
% the plots not to overlap. To minimse the space between the 2 plots use the
% |tight| option.
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
% * lower, The index of the lower plot in the |handle.Children| array. If not
% specified, 1 is used.
% * padding, The amount of free space between the 2 figures. If not specified
% .08 is used. The padding should be specified in MATLAB figure units (from 0 to
% 1).
% * tight, When this option is specified the padding between the 2 plots is
% reduced even more and the tick labels on the y axis are adjusted so as not to
% overlap.
% 
% TODO: replace upper and lower with |plotOrder| to support more subplots

function condense_subplots(varargin)
    ip = inputParser(); 
    ip.addOptional('handle', gcf()); % @ishandle 
    ip.addOptional('plotOrder', []); % @isnumeric
    ip.addParameter('padding', .08); % @isnumeric, iscalar
    ip.addParameter('tight', false); % @isbool
    ip.parse(varargin{:});
    
    % Extract the children that are axis objects
    fig_axes = ip.Results.handle.Children(...
        arrayfun(@(x) isa(x, 'matlab.graphics.axis.Axes'), ip.Results.handle.Children));
    
    plotOrder = ip.Results.plotOrder;
    if isempty(plotOrder)
        % If the order of the plots is not specified then we reverse the order
        % of the extracted figure handles. This gives us the list of the plots
        % from top to bottom (usually).
        plotOrder = fig_axes(end:-1:1); 
    end
    
    for k = 2:length(plotOrder)
       adjust_subplots(plotOrder(k-1), plotOrder(k), ip.Results);
    end
end

function adjust_subplots(upper_axis, lower_axis, opts)
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
    move_amount = (free_space - opts.padding) / 2;
    
    % If 'tight' is specified we may need to change the y-axis labels to make
    % them fit
    if opts.tight
        upper_ymin = upper_axis.YLim(1);
        upper_ytick_min = upper_axis.YTick(1);
        
        if upper_ymin == upper_ytick_min
            adjust_yticks(upper_axis);
        end
        
        lower_ymax = lower_axis.YLim(2);
        lower_ytick_max = lower_axis.YTick(end);
        
        if lower_ymax == lower_ytick_max
            adjust_yticks(lower_axis);
        end
        
        move_amount = (free_space - .01) / 2;
    end
    
    upper_axis.Position(2) = upper_axis.Position(2) - move_amount;
    upper_axis.Position(4) = upper_axis.Position(4) + move_amount;
    lower_axis.Position(4) = lower_axis.Position(4) + move_amount;
end

function adjust_yticks(axis)
    % If removing the top-most axis label doesn't deprive the graph of
    % meaning then do it. otherwise we need to rescale it.
    % 
    % When we rescale the graph we want to ensure that we have at least
    % 3 ticks. We also want to palce them at sane intervals. Currently
    % we use the max, min and mid-point of the YData.
    if length(axis.YTick) > 3
        axis.YTickLabel{1} = ' ';
        axis.YTickLabel{end} = ' ';
    else
        % The axis contains |Line| objects that contain the actual data.
        % We want the maximum and minimum of all the data points in the
        % |Line| objects of this axis.
        upper_bound = max(max(axis.Children.YData));
        lower_bound = min(min(axis.Children(:).YData));
        mid_point   = (upper_bound + lower_bound) / 2; 

        axis.YTick = [lower_bound, mid_point, upper_bound];
        axis.YTickLabel = num2str(axis.YTcik);
    end
end
