function r = test_isAlways_and_logical()
  c = 0;
  syms x y

  %% this first examples are true in both
  expr = x == x;
  c=c+1; r(c) = logical(expr);
  c=c+1; r(c) = isAlways(expr);

  % todo: should we support implicit == 0 like sympy?  what does SMT do?
  %expr = x - x;
  %c=c+1; r(c) = logical(expr);
  %c=c+1; r(c) = isAlways(expr);

  expr = x - x == 0;
  c=c+1; r(c) = logical(expr);
  c=c+1; r(c) = isAlways(expr);

  expr = 1 + x == x + 1;
  c=c+1; r(c) = logical(expr);
  c=c+1; r(c) = isAlways(expr);

  expr = x*(1+y) == x*(y+1);
  c=c+1; r(c) = logical(expr);


  %% Now for some differences
  % simplest example from SymPy FAQ
  expr = x*(1+y) == x+x*y;
  c=c+1; r(c) = logical(expr) == 0;
  c=c+1; r(c) = isAlways(expr);

  % logical() from SMT gives error on next two (todo check)
  expr = (x+1)*(x+1)  ==  ( x*x + 2*x + 1 );
  c=c+1; r(c) = logical(expr) == 0;
  c=c+1; r(c) = isAlways(expr);

  expr = sin(2*x)  ==  2*sin(x)*cos(x);
  c=c+1; r(c) = logical(expr) == 0;
  c=c+1; r(c) = isAlways(expr);

