function r = test_simple_fractions()
% unit test
  c = 0; r = [];

  x = sym('1/2');
  c=c+1; r(c) = double(x) - 1/2 == 0;
  c=c+1; r(c) = 2*x - sym(1) == 0;