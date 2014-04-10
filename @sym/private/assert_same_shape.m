function t = assert_same_shape(x,y)
  if ~(is_same_shape(x,y))
    error('array inputs must have same size and shape');
  end

