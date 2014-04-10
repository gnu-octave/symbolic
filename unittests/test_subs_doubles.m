function r = test_subs_doubles()
  c = 0;  r = [];
  syms x y
  f = x*y;

  warning('todo: passing doubles broken, what happens in SMT?');
  c=c+1; r(c) = 0;
  return
  c=c+1; r(c) = logical( subs(f, {x y}, {2 pi}) - 2*pi == 0 );
  c=c+1; r(c) = isa(subs(f, {x y}, {2 pi}), 'double');  % i think correct
  c=c+1; r(c) = ~isa(subs(f, {x y}, {2 pi}), 'sym');    % i think correct
  c=c+1; r(c) = isa(subs(f, {x y}, {2 sym(pi)}), 'sym');
  c=c+1; r(c) = isa(subs(f, {x y}, {sym(2) sym(pi)}), 'sym');

