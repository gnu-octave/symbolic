function r = test_infnan()
  c = 0;

  % make sure their pickles contain infinity, otherwise just symbols
  oo = sym(inf);
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );
  oo = sym(-inf);
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );
  oo = sym('inf');
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );
  oo = sym('-inf');
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );
  oo = sym('Inf');
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );
  oo = sym('INF');
  c=c+1;  r(c) = ~isempty( strfind(oo.pickle, 'Infinity') );

  x = sym(nan);
  c=c+1;  r(c) = isempty( strfind(x.pickle, 'Symbol') );
  x = sym('nan');
  c=c+1;  r(c) = isempty( strfind(x.pickle, 'Symbol') );
  x = sym('NaN');
  c=c+1;  r(c) = isempty( strfind(x.pickle, 'Symbol') );
  x = sym('NAN');
  c=c+1;  r(c) = isempty( strfind(x.pickle, 'Symbol') );


  snan = sym(nan);
  oo = sym(inf);
  zoo = sym('zoo');
  c=c+1;  r(c) = isinf(oo);
  c=c+1;  r(c) = isinf(zoo);
  c=c+1;  r(c) = isnan(0*oo);
  c=c+1;  r(c) = isnan(0*zoo);
  c=c+1;  r(c) = isnan(snan);
  c=c+1;  r(c) = isinf(oo+oo);
  c=c+1;  r(c) = isnan(oo-oo);
  c=c+1;  r(c) = isnan(oo-zoo);


  % arrays
  c=c+1;  r(c) = isequal(  isinf([oo zoo]), [1 1]  );
  c=c+1;  r(c) = isequal(  isinf([oo 1]),   [1 0]  );
  c=c+1;  r(c) = isequal(  isinf([10 zoo]), [0 1]  );

  c=c+1;  r(c) = isequal(  isnan([oo zoo]),    [0 0]  );
  c=c+1;  r(c) = isequal(  isnan([10 snan]),   [0 1]  );
  c=c+1;  r(c) = isequal(  isnan([snan snan]), [1 1]  );

  % bug!
  a = sym([nan 1 2])
  c=c+1;  r(c) = isequaln(  a, [nan 1 2]  );
  a = sym([1 inf])
  c=c+1;  r(c) = isequaln(  a, [1 inf]  );
