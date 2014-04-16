function r = test_limit()
  c = 0;
  syms x
  oo = sym(inf);

  c=c+1; r(c) = limit(sin(x)/x, x, 0) == 1;
  c=c+1; r(c) = limit(1/x, x, 0, 'right') == oo;
  c=c+1; r(c) = limit(1/x, x, 0) == oo;
  c=c+1; r(c) = limit(1/x, x, 0, 'left') == -oo;
  c=c+1; r(c) = limit(1/x, x, oo) == 0; 

  c=c+1; r(c) = limit(sign(x), x, 0, 'left') == -1;
  c=c+1; r(c) = limit(sign(x), x, 0, 'right') == 1;
  c=c+1; r(c) = limit(sign(x), x, 0, '-') == -1;
  c=c+1; r(c) = limit(sign(x), x, 0, '+') == 1;

