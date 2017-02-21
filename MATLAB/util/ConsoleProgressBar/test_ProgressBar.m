function test_ProgressBar()
%test_ProgressBar ConsoleProgressBar Demo and Test
%
% Upd: 04.02.2011

fprintf('ConsoleProgressBar Demo:\n\n')


%% Create instance progress bar
cpb = ConsoleProgressBar();

% Set progress bar parameters
cpb.setLeftMargin(4);   % progress bar left margin
cpb.setTopMargin(1);    % rows margin

cpb.setLength(40);      % progress bar length: [.....]
cpb.setMinimum(0);      % minimum value of progress range [min max]
cpb.setMaximum(100);    % maximum value of progress range [min max]

% Set text position
cpb.setPercentPosition('left');
cpb.setTextPosition('right');


%
%% 3 Console Progress Bars
fprintf('---------------------------------------------------------------\n')
fprintf('3 Console Progress Bars:')

for i = 1:3
    % Start new progress bar
    cpb.start();
    
    for k = 0:100
        text = sprintf('Progress %d: %d/%d', i, k, 100);
        
        cpb.setValue(k);  	% update progress value
        cpb.setText(text);  % update user text
        
        pause(0.025)
    end
end

% Stop progress bar
cpb.stop();


%% 1 Progress Bar with 2 replaces
fprintf('\n\n---------------------------------------------------------------\n')
fprintf('1 Console Progress Bar with 2 replaces:')

% Start new progress bar
cpb.start();

for i = 1:2
    for k = 0:100
        text = sprintf('Progress %d: %d/%d', i, k, 100);
        
        cpb.setValue(k);
        cpb.setText(text);
        
        pause(0.025)
    end
end

cpb.stop();
%}


%% Elapsed time and remaining time display
fprintf('\n\n---------------------------------------------------------------\n')
fprintf('Elapsed time and remaining time display:')

minVal = 0;
maxVal = 1000;

cpb.setMinimum(minVal);
cpb.setMaximum(maxVal);

cpb.setElapsedTimeVisible(1);
cpb.setRemainedTimeVisible(1);

cpb.setElapsedTimePosition('left');
cpb.setRemainedTimePosition('right');

cpb.start();

for k = minVal:maxVal
    
    text = sprintf('Progress: %d/%d', k, maxVal);
    
    cpb.setValue(k);
    cpb.setText(text);
    
    pause(0.01)
end

cpb.stop();


%%
fprintf('\n\nGood luck! Just for fun! :)\n')


