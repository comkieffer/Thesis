% Format a term of a polynome.
%
% format_term(value, exponent, var)
%
% Examples: 
%   >> format_term(1.23, 5, 'z')
%   1.23 z^5
%
%   >> format_term(-0.5, 2, 'q')
%   -0.5 q^2
%
%   >> format_term(1, 4, 's')
%   z^4
function outstr = format_term(value, exponent, var)
    outstr = '';
    
    if value ~= 0
        val_str = sprintf('%s%s', getsign(value), format_number(value));
        
        if (value == 1 || value == -1) && exponent ~= 0
            val_str = getsign(value);
        end
        
        if exponent == 0
            outstr = sprintf('%s', val_str);
        elseif exponent == 1
            outstr = sprintf('%s%s', val_str, var);             
        else 
            outstr = sprintf('%s%s^{%s}', val_str, var, format_number(exponent));
        end
        
        % Since when we build thee string we explicitely prepend the sign of the
        % value, when the value is negative the string will jave 2 minus signs.
        if outstr(1) == '-' && outstr(2) == '-'
            outstr = outstr(2:end);
        end
    end
end

function sign = getsign(num) 
    sign = '+';
    if num < 0; sign = '-'; end
end