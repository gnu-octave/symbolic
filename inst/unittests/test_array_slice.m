function r = test_array_slice()
  c = 0; r = [];
  syms x


  warning('known failures, slicing currently not implemented')
  c=c+1; r(c) = 0;
  return

  c=c+1; r(c) = all(all(logical(  b(:,1) == a(:,1)  )));
  c=c+1; r(c) = all(all(logical(  b(:,2) == a(:,2)  )));
  c=c+1; r(c) = all(all(logical(  b(1,:) == a(1,:)  )));
  c=c+1; r(c) = all(all(logical(  b(2,:) == a(2,:)  )));
  c=c+1; r(c) = all(all(logical(  b(:,:) == a(:,:)  )));
  c=c+1; r(c) = all(all(logical(  b(1:3,2) == a(1:3,2)  )));
  c=c+1; r(c) = all(all(logical(  b(1:4,:) == a(1:4,:)  )));
  c=c+1; r(c) = all(all(logical(  b(1:2:5,:) == a(1:2:5,:)  )));
  c=c+1; r(c) = all(all(logical(  b(1:2:4,:) == a(1:2:4,:)  )));
  c=c+1; r(c) = all(all(logical(  b(2:2:4,3) == a(2:2:4,3)  )));
  c=c+1; r(c) = all(all(logical(  b(2:2:4,3) == a(2:2:4,3)  )));
  % todo: end, negative entries, etc?


  warning('known failures in ranged assignment');
  c=c+1; r(c) = 0;

  % replace ranges
  f = [1 x^2 x^4];
  f(1:2) = [x x];
  c=c+1; r(c) = all(logical(  f == [x x x^4]  ));

  f(1:2) = [1 2];
  c=c+1; r(c) = all(logical(  f == [1 2 x^4]  ));

  % end keyword
  f(end-1:end) = [3 4];
  c=c+1; r(c) = all(logical(  f == [1 3 4]  ));
