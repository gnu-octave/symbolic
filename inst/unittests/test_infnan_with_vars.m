function r = test_infnan_with_vars()
% unit test

  c = 0; r = [];

  snan = sym(nan);
  oo = sym(inf);
  zoo = sym('zoo');
  x = sym('x');

  % SMT says isinf(x+oo) should be true, I remain unconvinced
  warning('known issues here: but should be follow SMT?');
  y = x+oo;
  c=c+1;  r(c) = isinf(y);
  c=c+1;  r(c) = ~isempty( strfind(lower(y.pickle), 'add') );

  y = x-zoo;
  c=c+1;  r(c) = isinf(y);
  c=c+1;  r(c) = ~isempty( strfind(lower(y.pickle), 'add') );

  y = x*oo;
  c=c+1;  r(c) = isinf(y);
  c=c+1;  r(c) = ~isempty( strfind(lower(y.pickle), 'mul') );

