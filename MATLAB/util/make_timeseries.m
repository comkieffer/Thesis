
% Make a timeseries structfrom the data. 
%
% Timeseries structs are useful to pass data in and out of simulink. You can
% pass a timeseries struct as the input to the |From Workspace| block for
% example. 
%
% USAGE:
%
% make_timeseries(time, signals)
%
%   time is the time vector for teh signals (column vector)
%   signals is a matrix of signals. Each signal should be one column of the
%   matrix. 
%
% TODO: improve me !!
%   use array of string as 'signals' parameter and load them from the parent
%   workspace. 
%   add support for extra fields (kwargs style)
%
function ts = make_timeseries(time, signals)
    ts.time = time;
    ts.signals.values = signals;
    ts.signals.dimensions = size(signals, 2);
end

