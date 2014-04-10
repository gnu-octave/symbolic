function r = test_array_reshape2()
  c = 0; r = [];

  syms x
  a = [1 x^2 x^4; x x^3 x^5];

  b = reshape(a, [1 6]);
  c=c+1; r(c) = isequal(size(b), [1 6]);
  c=c+1; r(c) = isequal(b, x.^(0:5));

  %b = a(:);
  %c=c+1; r(c) = isequal(size(b), [6 1]);
  %c=c+1; r(c) = isequal(b, x.^( (0:5)' ) );
  c=c+1; r(c) = 0; warning('test needs slice');
 
  b = reshape(b, size(a));
  c=c+1; r(c) = isequal(size(b), [2 3]);
  c=c+1; r(c) = isequal(b, a);

  % reshape scalar
  c=c+1; r(c) = logical( reshape(x, 1, 1) == x );
  c=c+1; r(c) = logical( reshape(x, [1 1]) == x );

