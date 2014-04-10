function r = test_array_ops()
  c = 0; r = [];
  syms x

  D = [0 1; 2 3];
  A = [sym(0) 1; sym(2) 3];
  DZ = D - D;
  % todo these can all be isequal

  %% unitary minus
  c=c+1; r(c) = all(all(logical(  -A == -D  )));

  %% sym from array
  c=c+1; r(c) = all(all(logical(  size(sym(D)) == size(D)  )));
  c=c+1; r(c) = all(all(logical(  sym(D) == A  )));

  %% array subtraction
  c=c+1; r(c) = all(all(logical(  A - D == DZ  )));
  c=c+1; r(c) = all(all(logical(  A - A == DZ  )));
  c=c+1; r(c) = all(all(logical(  D - A == DZ  )));
  c=c+1; r(c) = all(all(logical(  A - 2 == D - 2  )));
  c=c+1; r(c) = all(all(logical(  4 - A == 4 - D  )));
  %% array addition
  c=c+1; r(c) = all(all(logical(  A + D == 2*D  )));
  c=c+1; r(c) = all(all(logical(  D + A == 2*D  )));
  c=c+1; r(c) = all(all(logical(  A + A == 2*D  )));
  c=c+1; r(c) = all(all(logical(  A + 2 == D + 2  )));
  c=c+1; r(c) = all(all(logical(  4 + A == 4 + D  )));

  %% mult
  c=c+1; r(c) = all(all(logical(  2*A == 2*D  )));
  c=c+1; r(c) = all(all(logical(  A*2 == 2*D  )));
  c=c+1; r(c) = all(all(logical(  2.*A == 2*D  )));
  c=c+1; r(c) = all(all(logical(  A.*2 == 2*D  )));
  c=c+1; r(c) = all(all(logical(  A.*A == D.*D  )));
  c=c+1; r(c) = all(all(logical(  A.*D == D.*D  )));
  c=c+1; r(c) = all(all(logical(  D.*A == D.*D  )));

  %% div
  A=2*A; D=2*D;  % otherwise ctor doesn't do doubles on rhs
  c=c+1; r(c) = all(all(logical(  A/2 == D/2  )));
  c=c+1; r(c) = all(all(logical(  A./2 == D/2  )));
  c=c+1; r(c) = all(all(logical(  A/sym(2) == D/2  )));
  c=c+1; r(c) = all(all(logical(  A./sym(2) == D/2  )));
  c=c+1; r(c) = all(all(logical(  D./sym(2) == D/2  )));

  A = A/2 + 1;
  D = D/2 + 1;
  c=c+1; r(c) = all(all(logical(  A./A == D./D  )));
  c=c+1; r(c) = all(all(logical(  A./D == D./D  )));
  c=c+1; r(c) = all(all(logical(  D./A == D./D  )));
  c=c+1; r(c) = all(all(logical(  12./A == 12./D  )));  % 12, no fracs


