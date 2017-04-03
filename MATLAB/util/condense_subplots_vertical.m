

%
% Reduce vertical spacing between plots.
%
% When plotting multiple datasets with the same x axis there is no need to
% repeat the x axis tcks and labels. Addign them once to the bottomost plot is
% suffcient. This script does precisely that. 
%
% USAGE: 
%
% figure()
%   ax1 = subplot(2, 1, 1)
%       plot(1:100, sin(1:100 / 10)); 
%   ax2 = subplot(2, 1, 2)
%       plot(1:100, cos(1:100 / 10)); 
%   
% condense_subplots_vertical([ax1, ax2]);
%
%
% PARAMETERS:
%
% plots: A vector of axes to consider (e.g. [ax1, ax2,])
% padding: The padding between adjacent plots (default: 0.02)
%
 

function condense_subplots_vertical(varargin)
    ip = inputParser(); 
    ip.addRequired('plots'); % @isnumeric
    ip.addParameter('padding', .02); % @isnumeric, iscalar
    ip.parse(varargin{:});
    
    if isempty(ip.Results.plots) 
        return
    end
       
    % Order the plots by their y coordinate in asscending order (bottom first)
    %
    % In any sane programming launguage the standard library would provide a
    % sorting function that accepts a user-defined comparator making this
    % completely trivial. MATLAB however is anything but a sane language.
    %
    % Maybe there is a saner way of doing this but right now I can't find it. 
    %    
    order = arrayfun(@(el) el.Position(2), ip.Results.plots)';
    [~, idx] = sortrows(order);
    plots = ip.Results.plots(idx);     
    bottom_plot = plots(1); 
    
    [x1, y1, x2, y2] = make_plot_bounding_box(plots);
    height = y2 - y1;
        
    % Compute the total area that will be used for padding
    total_padding_space = (length(plots) - 1) * ip.Results.padding;
    
    single_plot_height = (height - total_padding_space) / length(plots);
    
    for k = 1:length(plots)
       this_plot = plots(k);
%        fprintf('Plot %i Initial Pos: [%.2f, %.2f, %.2f, %.2f]\n', k, this_plot.Position);
       
       if this_plot ~= bottom_plot
           this_plot.XTickLabel = {};
           this_plot.XLabel.String = {};
           
           adjust_yticks(this_plot);
           
       end
       
       this_plot.Position =[
            x1
            y1 + (k-1) * (single_plot_height + ip.Results.padding)
            x2 - x1
            single_plot_height
       ];
   
%        fprintf('Plot %i Final Pos  : [%.2f, %.2f, %.2f, %.2f]\n', k, this_plot.Position);

    end
end

function [x1, y1, x2, y2] = make_plot_bounding_box(plots)
    
    % Top left corner
    x1 = realmax;
    y1 = realmax;
    
    % Bottom right corner
    x2 = realmin;
    y2 = realmin;
    
    for k = 1:length(plots)
        this_plot = plots(k);
        
        x1 = min(this_plot.Position(1), x1);
        y1 = min(this_plot.Position(2), y1);
        
        x2 = max(this_plot.Position(1) + this_plot.Position(3), x2);
        y2 = max(this_plot.Position(2) + this_plot.Position(4), y2);
    end
end

function bottom_plot = get_bottom_plot(plots)
    bottom_plot = -1;
    y = 0;
    for k = 1:length(plots) 
        if plots(k).Position(2) > y
            y = plots(k).Position(2);
            bottom_plot = k;
        end
    end
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
    else
        % The axis contains |Line| objects that contain the actual data.
        % We want the maximum and minimum of all the data points in the
        % |Line| objects of this axis.
        upper_bound = max(max(axis.Children.YData));
        lower_bound = min(min(axis.Children(:).YData));
        mid_point   = (upper_bound + lower_bound) / 2; 

        axis.YTick = [lower_bound, mid_point, upper_bound];
    end
end
