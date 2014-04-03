function r = test_array_reshape()
  c = 0; r = [];

  syms x
  a = [1 x^2 x^4; x x^3 x^5];

  b = reshape(a, [1 6]);
  c=c+1; r(c) = all(  size(b) == [1 6]  );
  c=c+1; r(c) = all(logical(  b == x.^(0:5)  ));

  b = a(:);
  c=c+1; r(c) = all(  size(b) == [6 1]  );

  c=c+1; r(c) = all(logical(  b == x.^( (0:5)' )  ));

  b = reshape(b, size(a));
  c=c+1; r(c) = all(  size(b) == [2 3]  );
  c=c+1; r(c) = all(all(logical(  b == a  )));

