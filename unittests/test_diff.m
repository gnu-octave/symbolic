function r = test_diff()
  c = 0;
  syms x y z

  c=c+1; r(c) = diff(sin(x)) - cos(x) == 0;
  c=c+1; r(c) = diff(sin(x),x) - cos(x) == 0;
  c=c+1; r(c) = diff(sin(x),x,x) + sin(x) == 0;
  c=c+1; r(c) = diff(sin(x),x,2) + sin(x) == 0;
