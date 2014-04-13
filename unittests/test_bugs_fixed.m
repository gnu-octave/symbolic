function r = test_bugs_fixed()
  c = 0; r = [];
  syms x


  %% Issue #5, scalar expansion
  a = sym(1);
  a(2) = 2;
  c=c+1; r(c) = isequal(a, [1 2]);



  %% "any, all" not implemented
  D = [0 1; 2 3];
  A = sym(D);
  c=c+1; r(c) = isequal( size(any(A-D)), [1 2] );
  c=c+1; r(c) = isequal( size(all(A-D,2)), [2 1] );



  %% double wasn't implemented correctly for arrays
  D = [0 1; 2 3];
  A = sym(D);
  c=c+1; r(c) = isequal( size(double(A)), size(A) );
  c=c+1; r(c) = isequal( double(A), D );



  %% inf/nan in array ctor used to make wrong matrix
  a = sym([nan 1 2]);
  c=c+1;  r(c) = isequaln(  a, [nan 1 2]  );
  a = sym([1 inf]);
  c=c+1;  r(c) = isequaln(  a, [1 inf]  );

