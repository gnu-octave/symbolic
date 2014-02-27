function r = test_construct_rationals()
  c = 0;

  x = sym(1) / 3;
  c=c+1; r(c) = 3*x - 1 == 0;

  x = 1 / sym(3);
  c=c+1; r(c) = 3*x - 1 == 0;

  % TODO: known to fail
  x = sym('1/3');
  c=c+1; r(c) = 3*x - 1 == 0;

