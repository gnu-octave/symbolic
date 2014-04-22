function r = test_double()
% unit test

  c = 0; r = [];
  x = sym(2);
  c=c+1;  r(c) = double(x) == 2;

  x = sqrt(sym(2));
  c=c+1;  r(c) = abs(double(x) - sqrt(2)) < 2*eps;

  x = sym(pi);
  c=c+1;  r(c) = abs(double(x) - pi) < 2*eps;

  oo = sym(inf);
  zoo = sym('zoo');
  c=c+1;  r(c) = double(oo) == inf;
  c=c+1;  r(c) = double(-oo) == -inf;
  c=c+1;  r(c) = double(zoo) == inf;
  c=c+1;  r(c) = double(-zoo) == inf;
  c=c+1;  r(c) = isnan(double(0*oo));
  c=c+1;  r(c) = isnan(double(0*zoo));

  snan = sym(nan);
  c=c+1;  r(c) = isnan(double(snan));

  % arrays
  a = [1 2; 3 4];
  c=c+1;  r(c) = isequal(  double(sym(a)), a  );
  c=c+1;  r(c) = isequal(  double(sym(a)), a  );

  % should fail with error for non-double
  x = sym('x');
  try
    double(x);
    c=c+1;  r(c) = 0;
  catch
    c=c+1;  r(c) = 1;
  end

  try
    double([1 2 x]);
    c=c+1;  r(c) = 0;
  catch
    c=c+1;  r(c) = 1;
  end
