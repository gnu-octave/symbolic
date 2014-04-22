function r = test_construct_rationals()
% unit test

  c = 0; r = [];

  x = sym(1) / 3;
  c=c+1; r(c) = 3*x - 1 == 0;

  x = 1 / sym(3);
  c=c+1; r(c) = 3*x - 1 == 0;

  x = sym('1/3');
  c=c+1; r(c) = 3*x - 1 == 0;

