function r = test_array_pow()
  c = 0; r = [];
  syms x

  if (1==0)
    warning('array ops: skipping til equality testing fixed');
    r = 0;
    return
  end

  c=c+1; r(c) = x^2 - x*x == 0;
  c=c+1; r(c) = x^sym(3) - x*x*x == 0;

  D = [0 1; 2 3];
  A = [sym(0) 1; sym(2) 3];
  c=c+1; r(c) = all(all( sym(2).^D - 2.^D == 0 ));
  c=c+1; r(c) = all(all( sym(2).^A - 2.^A == 0 ));
  c=c+1; r(c) = all(all( 2.^D - 2.^A == 0 ));
  c=c+1; r(c) = all(all( 2.^A - 2.^A == 0 ));

