function r = test_symfun_vec()
  c = 0;

  syms x y
  F(x,y) = [1; 2*x; y; y*sin(x)];
  c=c+1; r(c) = isa(F, 'symfun');
  c=c+1; r(c) = isa(F, 'sym');
  c=c+1; r(c) = isequal( F(sym(pi)/2, 4) , [1; pi; 4; 4] );

