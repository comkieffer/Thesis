
function test_name = mktname(inner_bw, inner_damp, outer_bw, outer_damp)
    test_name = sprintf('test_i%.0f_di%02.0f_o%.0f_do%02.0f', ...
        inner_bw, inner_damp*10, outer_bw, outer_damp*10); 
end