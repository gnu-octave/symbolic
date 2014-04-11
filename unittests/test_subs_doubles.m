function r = test_subs_doubles()
  c = 0;  r = [];
  syms x y
  f = x*y;

  c=c+1; r(c) = isequal( subs(f, {x y}, {2 pi}), 2*sym(pi) );

  % this behaviour matches the SMT:
  c=c+1; r(c) = ~isa(subs(f, {x y}, {2 pi}), 'double');
  c=c+1; r(c) = isa(subs(f, {x y}, {2 pi}), 'sym');

  c=c+1; r(c) = isa(subs(f, {x y}, {2 sym(pi)}), 'sym');
  c=c+1; r(c) = isa(subs(f, {x y}, {sym(2) sym(pi)}), 'sym');
