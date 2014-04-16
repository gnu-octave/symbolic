function r = test_simple_fractions()
  x = sym('1/2');
  r = double(x) - 1/2 == 0;
  r(2) = 2*x - sym(1) == 0;