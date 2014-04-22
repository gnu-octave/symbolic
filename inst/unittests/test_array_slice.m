function r = test_array_slice()
% unit test

  c = 0; r = [];
  syms x

  a = [1 2 3 4 5 6]; a = [a; 3*a; 5*a; 2*a; 4*a];
  b = sym(a);

  c=c+1; r(c) = isequal(  b(:,1), a(:,1)  );
  c=c+1; r(c) = isequal(  b(:,2), a(:,2)  );
  c=c+1; r(c) = isequal(  b(1,:), a(1,:)  );
  c=c+1; r(c) = isequal(  b(2,:), a(2,:)  );
  c=c+1; r(c) = isequal(  b(:,:), a(:,:)  );
  c=c+1; r(c) = isequal(  b(1:3,2), a(1:3,2)  );
  c=c+1; r(c) = isequal(  b(1:4,:), a(1:4,:)  );
  c=c+1; r(c) = isequal(  b(1:2:5,:), a(1:2:5,:)  );
  c=c+1; r(c) = isequal(  b(1:2:4,:), a(1:2:4,:)  );
  c=c+1; r(c) = isequal(  b(2:2:4,3), a(2:2:4,3)  );
  c=c+1; r(c) = isequal(  b(2:2:4,3), a(2:2:4,3)  );
  % todo: end, negative entries, etc?


  % replace ranges: these are pretty tame, probably more in
  % subsasgn.m octave tests
  f = [1 x^2 x^4];
  f(1:2) = [x x];
  c=c+1; r(c) = isequal(  f, [x x x^4]  );

  f(1:2) = [1 2];
  c=c+1; r(c) = isequal(  f, [1 2 x^4]  );

  f(end-1:end) = [3 4];
  c=c+1; r(c) = isequal(  f, [1 3 4]  );

  f(3:4) = [10 11];
  c=c+1; r(c) = isequal(  f, [1 3 10 11]  );

  f(end:end+1) = [12 14];
  c=c+1; r(c) = isequal(  f, [1 3 10 12 14]  );
