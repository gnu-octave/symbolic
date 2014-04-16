function r = test_symfun()
  c = 0;

  syms x
  f(x) = 2*x;
  c=c+1; r(c) = isa(f, 'symfun');
  c=c+1; r(c) = isa(f, 'sym');
  c=c+1; r(c) = logical( f(3) - 6 == 0 );
  c=c+1; r(c) = logical( f(sin(x)) - 2*sin(x) == 0 );
  
%% y(x) = sym(y(x))  % todo does this work in SMT?

  x = sym('x');
  y = sym('y');
  f(x) = sym('f(x)');
  g(x,y) = sym('g(x,y)');
  c=c+1; r(c) = isa(g, 'symfun');
  f(1);
  g(1,2);
  g(x,y);
  diff(g, x);
  diff(g, y);
  c=c+1; r(c) = 1;  % got this far

  % todo
  %c=c+1; r(c) = isa(2*g, 'symfun');
  %c=c+1; r(c) = ~isa(0*g, 'symfun');  % may not worth worrying about


  % todo refactor hacky code for this:
  %c=c+1; r(c) = logical( g(t,t) - sym('g(t,t)') == 0 );



  % replace g with shorter and specific fcn
  g(x) = 2*x;
  c=c+1; r(c) = logical( g(5) - 10 == 0 );

  clear f g
  %syms f(x) g(x,y)   % todo needs x y syms in SMT?
  syms f(x)
  %todo octave parse error w/o quotes?  works in matlab?
  syms 'g(x,y)'
  c=c+1; r(c) = isa(f, 'symfun');
  c=c+1; r(c) = isa(g, 'symfun');

  % todo: reset python make still work


