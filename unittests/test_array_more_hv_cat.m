function r = test_array_more_hv_cat()
  c = 0; r = [];
  syms x


  a = [sym(1) 2];
  b = [sym(3) 4];
  c=c+1; r(c) = all(all(logical(  [a;b] == [1 2; 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a b] == [1 2 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a 3 4] == [1 2 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [3 4 a] == [3 4 1 2]  )));
  c=c+1; r(c) = all(all(logical(  [a [3 4]] == [1 2 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a sym(3) 4] == [1 2 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a [sym(3) 4]] == [1 2 3 4]  )));


  % looks like octave 3.6 bug, works in 3.8.1 and m*tl*b
  try
    [x [x x]; x x x];
    [[x x] x; x x x];
    [[x x] x; [x x] x];
    [x x x; [x x] x];
    c=c+1; r(c) = 1;
  catch
    c=c+1; r(c) = 0;
    warning('some tests failed, skipping: known bug on Octave 3.6')
    return
  end

  % back to regular tests
  c=c+1; r(c) = all(all(logical(  [a; [3 4]] == [1 2; 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a; sym(3) 4] == [1 2; 3 4]  )));
  c=c+1; r(c) = all(all(logical(  [a; [sym(3) 4]] == [1 2; 3 4]  )));

