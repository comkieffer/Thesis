


%% Test format_number

assert_eq = @(s, n) assert(strcmp(s, format_number(n)), ...
    sprintf('Assert failed: %s ~= %s', s, format_number(n)));

assert_eq('1.7', 1.7);
assert_eq('-1.7',-1.7);

assert_eq('2', 2);
assert_eq('-2', -2);

assert_eq('0', 0);
assert_eq('0', -0);

%% Test format_term 

assert_eq = @(s, val, exp, var) assert(strcmp(s, format_term(val, exp, var)), ...
    sprintf('Assert failed: %s ~= %s', s, format_term(val, exp, var)));

% Check that we can change the variable
assert_eq('+0.3z^{1.2}', 0.3, 1.2, 'z');
assert_eq('+1.24q^{-2}', 1.24, -2, 'q');

assert_eq('+z^{2}', 1, 2, 'z');
assert_eq('-z^{2.4}', -1, 2.4, 'z');

assert_eq('+2.3', 2.3, 0, 'z');
assert_eq('-1.7', -1.7, 0, 'z');

assert_eq('+1', 1, 0, 'z');
assert_eq('-1', -1, 0, 'z');

%% Test tf2latex

assert_eq = @(s, f) assert(strcmp(s, tf2latex(f)),...
    sprintf('Assert failed: %s ~= %s', s, tf2latex(f)));

tf_s = tf([1 0], [1 1 1]);
tf_z = tf([1 0], [1 1 1], .05);

tf_z1 = tf_z;
tf_z1.Variable = 'z^-1';

assert_eq('G(s) = \frac{s}{s^{2}+s+1}', tf_s);
assert_eq('G(z) = \frac{z}{z^{2}+z+1}', tf_z);
assert_eq('G(z) = \frac{z^{-1}}{z^{-2}+z^{-1}+1}', tf_z1);