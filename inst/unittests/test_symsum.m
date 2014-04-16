function r = test_symsum()
  c = 0;
  syms n
  oo = sym(inf);

  c=c+1; r(c) = symsum(n,n,1,10) == 55;
  c=c+1; r(c) = isa(symsum(n,n,1,10), 'sym');
  c=c+1; r(c) = symsum(n,n,sym(1),sym(10)) == 55;
  c=c+1; r(c) = symsum(n,n,sym(1),sym(10)) == 55;
  c=c+1; r(c) = symsum(1/n,n,1,10) == sym(7381)/2520;
  c=c+1; r(c) = symsum(1/n,n,1,oo) == sym('zoo');
  c=c+1; r(c) = logical(symsum(1/n^2,n,1,oo) - sym(pi)^2/6 == 0);
  % ok to use double's for arguments
  c=c+1; r(c) = logical(symsum(1/n^2,n,1,inf) - sym(pi)^2/6 == 0);
