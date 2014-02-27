function r = test_constructor()
  c = 0;

  % integers
  x = sym('2');
  y = sym(2);
  c=c+1;  r(c) = double(x) == 2;
  c=c+1;  r(c) = logical(x - y);

  % infinity
  for x = {'inf', '-inf', inf, -inf}
    y = sym(x{1});
    c=c+1;  r(c) = isinf(double(y));
  end

  % pi
  x = sym('pi');
  c=c+1;  r(c) = abs(double(x) - pi) < 2*eps;
  x = sym(pi);
  c=c+1;  r(c) = abs(double(x) - pi) < 2*eps;
