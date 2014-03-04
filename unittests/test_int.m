function r = test_int()
  c = 0;
  syms x y a

  c=c+1; r(c) = logical(int(cos(x)) - sin(x) == 0);
  c=c+1; r(c) = logical(int(cos(x),x) - sin(x) == 0);
  c=c+1; r(c) = logical(int(cos(x),x,0,1) - sin(sym(1)) == 0);
  % or limits might be syms
  c=c+1; r(c) = logical(int(cos(x),x,sym(0),sym(1)) - sin(sym(1)) == 0);
  c=c+1; r(c) = logical(int(cos(x),x,0,a) - sin(a) == 0);

  % other variables present
  c=c+1; r(c) = logical(int(y*cos(x),x) - y*sin(x) == 0);

