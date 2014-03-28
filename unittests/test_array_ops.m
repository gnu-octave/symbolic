function r = test_array_ops()
  c = 0; r = [];
  syms x

  if (1==1)
    warning('array ops: skipping til equality testing fixed');
    r = 0;
    return
  end

  D = [0 1; 2 3];
  A = [sym(0) 1; sym(2) 3];
  DZ = D - D;
  % todo new symzeros cmd == dz, in different file

  %% array subtraction
  c=c+1; r(c) = all(all(logical(  A - D == DZ  )));
  c=c+1; r(c) = all(all(logical(  A - A == DZ  )));
  % todo known failure, see note above
  %c=c+1; r(c) = all(all(logical(  D - A == DZ  )));
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
  c=c+1; r(c) = all(all(logical(  A.*A == D.D  )));

  %% unitary minus
  c=c+1; r(c) = all(all(logical(  -A == -D  )));


