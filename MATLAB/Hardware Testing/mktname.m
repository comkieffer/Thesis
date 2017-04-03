
%
% Make Test Name
%
% Small utility to generate a test name from the parameters of the reference
% models. The suffix allows you to add (duh!) a suffix to the name.
%
% USAGE:
%   >> mktname(8, .7, 9, .8, '_disturbed')
%   ans =
%   test_i8_di07_o9_do08_disturbed
%



function test_name = mktname(inner_bw, inner_damp, outer_bw, outer_damp, suffix)
    if nargin == 0
        inner_bw = evalin('base', 'inner_bw');
        inner_damp = evalin('base', 'inner_damp');

        outer_bw = evalin('base', 'outer_bw');
        outer_damp = evalin('base', 'outer_damp');
    end
    
    test_name = sprintf('test_i%.0f_di%02.0f_o%.0f_do%02.0f', ...
        inner_bw, inner_damp*10, outer_bw, outer_damp*10); 
    
    if nargin == 5
        test_name = [test_name suffix];
    end
end