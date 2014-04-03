function r = test_eq()
  c = 0; r = [];
  syms x

  c=c+1; r(c) = logical(  x == x  );
  c=c+1; r(c) = x == x;
  c=c+1; r(c) = x - x == 0;
  c=c+1; r(c) = isAlways(  x == x  );

  warning('2 known failures: todo: becomes false rather than defining an eqn')
  c=c+1; r(c) = ~isa(x - 5 == x - 3, 'logical');
  c=c+1; r(c) = isa(x - 5 == x - 3, 'sym');


  % using eq for == and "same obj" is strange:
  c=c+1; r(c) = isAlways(  (x == 4) == (x == 4) );
  %c=c+1; r(c) = isAlways(  (x - 5 == x - 3) == (x == 4) );

  D = [0 1; 2 3];
  A = [sym(0) 1; sym(2) 3];
  DZ = D - D;

  % array
  c=c+1; r(c) = all(all(logical(  A == D  )));
  c=c+1; r(c) = all(all(logical(  A - D == DZ  )));
  c=c+1; r(c) = all(all(logical(  A/3 == D/3  )));
  c=c+1; r(c) = all(all(logical(  A/3 - D/3 == DZ  )));

