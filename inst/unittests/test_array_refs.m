function r = test_array_refs()
% unit test

  c = 0; r = [];

  % basically a random matrix
  a = reshape( round(50*(sin(1:20)+1)),  5,4);
  b = sym(a);

  c=c+1; r(c) = logical(b(1,1) == a(1,1));
  c=c+1; r(c) = logical(b(3,1) == a(3,1));
  c=c+1; r(c) = logical(b(1,3) == a(1,3));
  c=c+1; r(c) = logical(b(4,4) == a(4,4));

  % linear indices
  c=c+1; r(c) = logical(b(1) == a(1));
  c=c+1; r(c) = logical(b(3) == a(3));
  c=c+1; r(c) = logical(b(13) == a(13));

  % end
  c=c+1; r(c) = all(all(logical(  b(end,1) == a(end,1)  )));
  c=c+1; r(c) = all(all(logical(  b(2,end) == a(2,end)  )));
  c=c+1; r(c) = all(all(logical(  b(end,end) == a(end,end)  )));
  c=c+1; r(c) = all(all(logical(  b(end-1,1) == a(end-1,1)  )));
  c=c+1; r(c) = all(all(logical(  b(2,end-1) == a(2,end-1)  )));
  c=c+1; r(c) = all(all(logical(  b(end-1,end-1) == a(end-1,end-1)  )));
