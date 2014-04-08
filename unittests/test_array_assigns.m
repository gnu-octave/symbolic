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
  c=c+1; r(c) = all(logical(  f == [2*x 4*x]  ));

  f(2) = 2;
  c=c+1; r(c) = all(logical(  f == [2*x 2]  ));

  % array expansion
  f(3) = x*x;
  c=c+1; r(c) = all(logical(  f == [2*x 2 x^2]  ));

  f(4) = 4;
  c=c+1; r(c) = all(logical(  f == [2*x 2 x^2 4]  ));

  % replace ranges
  f(1:2) = [x x];
  c=c+1; r(c) = all(logical(  f == [x x x^2 4]  ));

  f(1:2) = [1 2];
  c=c+1; r(c) = all(logical(  f == [1 2 x^2 4]  ));

  % end keyword
  f(end-1:end) = [3 4];
  c=c+1; r(c) = all(logical(  f == [1 2 3 4]  ));



