function r = test_subs()
  c = 0;
  syms x y t

  f = x*y;

  c=c+1; r(c) = logical( subs(f, x, y) - y^2 == 0 );

  c=c+1; r(c) = logical( subs(f, y, sin(x)) - x*sin(x) == 0 );

  c=c+1; r(c) = logical( subs(f, x, 16) - 16*y == 0 );

  warning('todo known failures');
  c=c+1; r(c) = 0
  %c=c+1; r(c) = logical( subs(f, [x y], [t t]) - t*t == 0 );

  %c=c+1; r(c) = logical( subs(f, [x y], [t 16]) - 16*t == 0 );

  %c=c+1; r(c) = logical( subs(f, [x y], [2 16]) - 32 == 0 );


