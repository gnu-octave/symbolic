function r = test_transforms()
% unit test

  c = 0; r = [];

  syms x k
  f = exp(-x^2);
  F = fourier(f,x,k);
  g = ifourier(F,k,x);
  c=c+1; r(c) = isequal(f,g);

  %todo laplace
