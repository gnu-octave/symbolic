function t = assert_same_shape(x,y)
  d1 = size(x);
  d2 = size(y);
  if ((length(d1) ~= length(d2)) || (any(d1 ~= d2)))
    error('array inputs must have same size and shape');
  end

