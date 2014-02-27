function r = test_abs()

  f1 = abs(sym(1));
  f2 = abs(1);
  r = abs(double(f1) - f2) < 1e-15;

