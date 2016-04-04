
function out_str = format_number(num)
    out_str = sprintf('%f', num);
    
    % There is no built in way to remove trailing zeros in MATLAB (as far as I
    % am aware). This is why we use another horrible hack ...
    out_str = strrep(out_str, '0', ' ');
    out_str = deblank(out_str);
    out_str = strrep(out_str, ' ', '0');
    
    % If the number passed into the function was an integer then it will have a
    % '.' as its last character.
    if out_str(end) == '.'
        out_str = out_str(1:end-1);
    end
    
    % For some reason MATLAB will sometimes not collapse '-0' into '0'
    if strcmp(out_str, '-0')
        out_str = '0';
    end
end