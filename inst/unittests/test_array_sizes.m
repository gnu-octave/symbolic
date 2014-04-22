function r = test_array_sizes()
% unit test

  c = 0; r = [];

  a = sym([1 2 3]);
  c=c+1; r(c) = length(a) == 3;
  c=c+1; r(c) = numel(a) == 3;
  c=c+1; r(c) = isequal(size(a), [1 3]);
  c=c+1; r(c) = isa(size(a), 'double');
  c=c+1; r(c) = isa(numel(a), 'double');
  c=c+1; r(c) = isa(length(a), 'double');

  a = sym([1 2 3; 4 5 6]);
  c=c+1; r(c) = length(a) == 3;
  c=c+1; r(c) = numel(a) == 6;
  c=c+1; r(c) = isequal(size(a), [2 3]);
  c=c+1; r(c) = isa(size(a), 'double');
  c=c+1; r(c) = isa(numel(a), 'double');
  c=c+1; r(c) = isa(length(a), 'double');
