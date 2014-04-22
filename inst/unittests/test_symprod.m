function r = test_symprod()
% unit test

  c = 0; r = [];
  syms n a
  oo = sym(inf);
  zoo = sym('zoo');

  c=c+1; r(c) = symprod(n, n, 1, 10) - factorial(sym(10)) == 0;
  c=c+1; r(c) = symprod(n, n, sym(1), sym(10)) - factorial(10) == 0;
  c=c+1; r(c) = symprod(a, n, 1, oo) - a^oo == 0;
  c=c+1; r(c) = symprod(a, n, 1, inf) - a^oo == 0;
  % not with oo, but true with zoo, see below
  c=c+1; r(c) = symprod(1, n, 1, zoo) == 1;
  c=c+1; r(c) = symprod(1, n, 1, 'zoo') == 1;

  %% a^oo, when a == 1
  % sympy 0.7.4: gives 1
  % sympy 0.7.5: gives NaN  [https://github.com/sympy/sympy/wiki/Release-Notes-for-0.7.5]
  % SMT R2013b: gives 1
  c=c+1; r(c) = isnan(1^oo);
  if (~ r(c))
    warning('1 known failure on SymPy 0.7.4, fixed in 0.7.5')
  end

  %% a^zoo, when a == 1
  % on both sympy 0.7.4 and 0.7.5 this is 1
  c=c+1; r(c) = islogical(1^zoo == 1);
  c=c+1; r(c) = 1^zoo == 1;

