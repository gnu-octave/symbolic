function r = test_eq_smt()
  c = 0; r = [];
  syms x

  % some tests based on what SMT does
  c=c+1; r(c) = islogical( sym(1) == sym(1) );
  c=c+1; r(c) = islogical( sym(1) == 1 );
  c=c+1; r(c) = islogical( sym(1) == 0 );

  % note anything involving a variable is not a bool
  c=c+1; r(c) = ~islogical( x == 0 );
  % except via cancellation
  c=c+1; r(c) = islogical( x - x == 0 );

  a = sym([1 2; 3 4]);
  c=c+1; r(c) = islogical( a == a );
  c=c+1; r(c) = isequal( size(a == a), [2 2]);
  c=c+1; r(c) = islogical( a == 1 );
  c=c+1; r(c) = islogical( a == 42 );

  % if any x's it should not be logical but the equality
  warning('known failures');
  c=c+1; r(c) = ~islogical( [x 1] == 1 );
  c=c+1; r(c) = ~islogical( [x 1] == x );
  c=c+1; r(c) = ~islogical( [x x] == x );
  %c=c+1; r(c) = isequal( [x x] == sym([1 2]), [x==1 x==2] );
  %c=c+1; r(c) = isequal( [x x] == [1 2], [x==1 x==2] );

