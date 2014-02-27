function r = test_int()
  c = 0;
  syms x y z

  c=c+1; r(c) = isAlways(int(cos(x)) - sin(x) == 0);
  c=c+1; r(c) = int(cos(x),x) - sin(x) == 0;
  c=c+1; r(c) = int(cos(x),x,0,1) - sin(sym(1)) == 0;

