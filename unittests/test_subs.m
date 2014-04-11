function r = test_subs()
  c = 0;
  syms x y t

  f = x*y;

  c=c+1; r(c) = isequal(  subs(f, x, y),  y^2  );
  c=c+1; r(c) = isequal(  subs(f, y, sin(x)),  x*sin(x)  );
  c=c+1; r(c) = isequal(  subs(f, x, 16),  16*y  );

  c=c+1; r(c) = isequal(  subs(f, {x}, {t}),  y*t  );
  c=c+1; r(c) = isequal(  subs(f, {x y}, {t t}),  t*t  );
  c=c+1; r(c) = isequal(  subs(f, {x y}, {t 16}),  16*t  );
  c=c+1; r(c) = isequal(  subs(f, {x y}, {16 t}),  16*t  );
  c=c+1; r(c) = isequal(  subs(f, {x y}, {2 16}),  32  );


  c=c+1; r(c) = isequal( subs(f, [x y], [t t]),  t*t  );
  c=c+1; r(c) = isequal( subs(f, [x y], [t 16]),  16*t  );
  c=c+1; r(c) = isequal( subs(f, [x y], [2 16]),  32  );
