function r = test_array_pow()
% unit test

  c = 0; r = [];
  syms x

  c=c+1; r(c) = x^2 - x*x == 0;
  c=c+1; r(c) = x^sym(3) - x*x*x == 0;

  D = [0 1; 2 3];
  A = [sym(0) 1; sym(2) 3];
  c=c+1; r(c) = all(all( sym(2).^D - 2.^D == 0 ));
  c=c+1; r(c) = all(all( sym(2).^A - 2.^A == 0 ));
  c=c+1; r(c) = all(all( 2.^D - 2.^A == 0 ));
  c=c+1; r(c) = all(all( 2.^A - 2.^A == 0 ));

