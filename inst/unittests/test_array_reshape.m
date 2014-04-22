function r = test_array_reshape()
% unit tests

  c = 0; r = [];

  d = [2 4 6; 8 10 12];
  a = sym(d);
  c=c+1; r(c) = isequal(reshape(a, [1 6]), reshape(d, [1 6]));
  c=c+1; r(c) = isequal(reshape(a, 1, 6), reshape(d, 1, 6));
  c=c+1; r(c) = isequal(reshape(a, 2, 3), reshape(d, 2, 3));
  c=c+1; r(c) = isequal(reshape(a, 3, 2), reshape(d, 3, 2));
  c=c+1; r(c) = isequal(reshape(a, 6, 1), reshape(d, 6, 1));

