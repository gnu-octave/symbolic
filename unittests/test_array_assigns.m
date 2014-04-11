function r = test_array_assigns()
  c = 0; r = [];
  syms x

  f = [x 2; 3 4*x];
  % element access
  c=c+1; r(c) = logical(  f(1,1) == x  );
  c=c+1; r(c) = logical(  f(1,2) == 2  );
  % linear access of 2d array
  c=c+1; r(c) = logical(  f(1) == x  );
  c=c+1; r(c) = logical(  f(2) == 3  );  % column based
  c=c+1; r(c) = logical(  f(3) == 2  );


  f = [2*x 3*x];
  % element access
  c=c+1; r(c) = logical(  f(1) == 2*x  );
  c=c+1; r(c) = logical(  f(2) == 3*x  );

  %% array assignment (subsasgn)
  f(2) = 4*x;
  c=c+1; r(c) = isequal(f, [2*x 4*x]);

  f(2) = 2;
  c=c+1; r(c) = isequal(f, [2*x 2]);

  % array expansion
  g = f;
  g(1,3) = x*x;
  c=c+1; r(c) = isequal(g, [2*x 2 x^2]);

  g = f;
  g(3) = x*x;
  c=c+1; r(c) = isequal(g, [2*x 2 x^2]);

  g = f;
  g(3) = 4;
  c=c+1; r(c) = isequal(g, [2*x 2 4]);
