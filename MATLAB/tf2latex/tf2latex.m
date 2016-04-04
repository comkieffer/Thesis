
%
% Author: Thibaud Chupin
% Date Created: 2016-03-24
%
% Given a tranfer function, produce a latex representation. The transfer
% function can be continuous or discrete time in any of the supported matlab
% variables (s, z, z^-1, q, ...)
%
% Usage: 
%
%     >> t = tf([1 3.4 0], [5.34 6.890, 0, 0, 1.987])
% 
%     t =
% 
%               s^2 + 3.4 s
%       ---------------------------
%       5.34 s^4 + 6.89 s^3 + 1.987
% 
%     Continuous-time transfer function.   
% 
%     >> tf2latex(t, 'G')
%     ans =
%     G(s) = \frac{ 1 s^{2} + 3.400 s^{3} }{ 5.340 + 6.890 s + 1.987 s^{4} 
%
% Inputs: 
%   func: The transfer function to convert
%   funcname: The name of the transfer function. This can be any raw string or
%   latex snippet. 
%
% Outputs:
%   outstr: A string containing the latex code
% 

function outstr = tf2latex(func, funcname) 
    if ~exist('funcname', 'var'); funcname = 'G'; end
    
    [num, den] = tfdata(func);
    
    isinverse = false;
    funcvar = func.Variable; 
    if strcmp(funcvar, 'z^-1')
        isinverse = true; 
        funcvar = 'z';       
    elseif strcmp(funcvar, 'q^-1')
        isinverse = true; 
        funcvar = 'q'; 
    end
    
    outstr = sprintf('%s(%s) = \\frac{%s}{%s}', funcname, funcvar, ...
        poly2latex(num{:}, funcvar, isinverse), poly2latex(den{:}, funcvar, isinverse));
end

function outstr = poly2latex(poly, var, inverse)
    if ~exist('inverse', 'var'); inverse = false; end;
    
    outstr = '';
    degree = length(poly) - 1;
    
    if inverse
        for k = 1:length(poly)
            exponent = k - degree - 1;

            new_term = format_term(poly(k), exponent, var);

            % If the first term of the polynome is positive strip the leading '+'
            if isempty(outstr) && ~isempty(new_term) && new_term(1) == '+'
                new_term = new_term(2:end);
            end

            outstr = [outstr new_term];
        end
    else
        for k = length(poly):-1:1
            exponent = k-1;
            new_term = format_term(poly(k), exponent, var);
            
            % If the first term of the polynome is positive strip the leading '+'
            if isempty(outstr) && ~isempty(new_term) && new_term(1) == '+'
                new_term = new_term(2:end);
            end

            outstr = [outstr new_term];
        end
    end
end






