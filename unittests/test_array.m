function r = test_array()
  c = 0; r = [];
  syms x

  % row vectors
  try
    [x x];
    [x 1];
    [1 x];
    c=c+1; r(c) = 1;  
  catch
    c=c+1; r(c) = 0;
  end

  % arrays to ctor
  try
    sym([x x]);
    sym([1 2]);
    sym([1 x]);
    sym([1 2; 3 4]);
    c=c+1; r(c) = 1;  
  catch
    c=c+1; r(c) = 0;
  end

  % vertcat
  try
    [x x; x x];
    [x x x; x x x];
    [x; x; x];
    c=c+1; r(c) = 1;  
  catch
    c=c+1; r(c) = 0;
  end


