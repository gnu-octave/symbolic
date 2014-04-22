function r = test_sym_cell()
% unit test

  c = 0; r = [];
  syms x

  % these tests are pretty weak (how to compare two cells?) but
  % just running these is a good test.

  a = {1 2};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );

  a = {1 2 {3 4}};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );

  a = {1 2; 3 4};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );

  a = {1 2; 3 {4}};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );

  a = {1 [1 2] x [sym(pi) x]};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );
  c=c+1; r(c) = isequal( size(a{2}), size(s{2}) );
  c=c+1; r(c) = isequal( size(a{4}), size(s{4}) );


  a = {{{[1 2; 3 4]}}};
  s = sym(a);
  c=c+1; r(c) = isequal( size(a), size(s) );
  c=c+1; r(c) = isequal( size(a{1}), size(s{1}) );
  c=c+1; r(c) = isequal( size(a{1}{1}), size(s{1}{1}) );
  c=c+1; r(c) = isequal( size(a{1}{1}{1}), size(s{1}{1}{1}) );

