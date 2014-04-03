function z = power(x, y)
%.^  Componentwise exponentiation

  if isscalar(x) && isscalar(y)
    z = mpower(x,y);

  elseif isscalar(x) && ~isscalar(y)
    z = make_zeros(size(y));
    for i = 1:numel(y)
      z(i) = x ^ y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = make_zeros(size(x));
    for i = 1:numel(x)
      z(i) = x(i) ^ y;
    end

  else  % both are arrays
    assert_same_shape(x,y);
    z = make_zeros(size(x));
    for j = 1:numel(x)
      z(j) = x(j)^y(j);
    end
  end

