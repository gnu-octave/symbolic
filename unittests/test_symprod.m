function r = test_symprod()
  c = 0;
  syms n a
  oo = sym(inf);

  c=c+1; r(c) = symprod(n, n, 1, 10) - factorial(sym(10)) == 0;
  c=c+1; r(c) = symprod(n, n, sym(1), sym(10)) - factorial(10) == 0;
  c=c+1; r(c) = symprod(1, n, 1, oo) == 1;
  c=c+1; r(c) = logical( symprod(a, n, 1, oo) - a^oo == 0 );

