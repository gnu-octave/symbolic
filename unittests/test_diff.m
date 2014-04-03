function r = test_diff()
  c = 0;
  syms x y z

  c=c+1; r(c) = diff(sin(x)) - cos(x) == 0;
  c=c+1; r(c) = diff(sin(x),x) - cos(x) == 0;
  c=c+1; r(c) = diff(sin(x),x,x) + sin(x) == 0;

  % these fail when doubles are not converted to sym
  c=c+1; r(c) = diff(sin(x),x,2) + sin(x) == 0;
  c=c+1; r(c) = diff(sym(1),x) == 0;
  c=c+1; r(c) = diff(1,x) == 0;
  c=c+1; r(c) = diff(1.1,x) == 0;

  % symbolic diff of constant
  % Note this fails in sympy: it works in SMT but does anyone care?
  % TODO: start document about behaviour differences from SMT
  warning('known failure');
  %c=c+1; r(c) = diff(sym(1)) == 0;
  c=c+1; r(c) = 0;

  % octave's vector difference still works
  c=c+1; r(c) = isempty(diff(1));
  c=c+1; r(c) = (diff([2 6]) == 4);

