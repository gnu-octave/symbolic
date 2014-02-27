function r = test_double()
  c = 0;
  x = sym(2);
  c=c+1;  r(c) = double(x) == 2;

  x = sym(pi);
  c=c+1;  r(c) = abs(double(x) - pi) < 2*eps;

  % should fail with error for non-double
  x = sym('x');
  try
    double(x)
    c=c+1;  r(c) = 0;
  catch
    c=c+1;  r(c) = 1;
  end

