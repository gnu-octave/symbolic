function r = test_array_assigns()
  c = 0; r = [];
  syms x

  %% array assignment (subsasgn)
  f = [2*x 3*x];
  f(2) = 4*x;
  c=c+1; r(c) = all(logical(  f == [2*x 4*x]  ));

  f(3) = x*x;
  c=c+1; r(c) = all(logical(  f == [2*x 4*x x^2]  ));
  
  f(1:2) = [x x];
  c=c+1; r(c) = all(logical(  f == [x x x^2]  ));

  f(1:2) = [1 2];
  c=c+1; r(c) = all(logical(  f == [1 2 x^2]  ));

