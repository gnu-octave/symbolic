function r = test_subs_ordering()
% unit test

  c = 0; r = [];
  syms x y t

  f = sin(x)*y;
  F = [f; 2*f];

  % we need the simultaneous=True flag in SymPy (confirmed this matches
  % SMT 2013b)
  c=c+1; r(c) = isequal( subs(f, [x t], [t 6]), y*sin(t) );
  c=c+1; r(c) = isequal( subs(F, [x t], [t 6]), [y*sin(t); 2*y*sin(t)] );

  % swap x and y (also needs simultaneous=True
  c=c+1; r(c) = isequal( subs(f, [x y], [y x]), x*sin(y) );

  % but of course both x and y to t still works
  c=c+1; r(c) = isequal( subs(f, [x y], [t t]), t*sin(t) );
