function z = power(x, y)
%.^  Componentwise exponentiation

  if isscalar(x) && isscalar(y)
    z = mpower(x,y);

  elseif isscalar(x) && ~isscalar(y)
    z = y;
    for i = 1:numel(y)
      z(i) = x ^ y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = x;
    for i = 1:numel(x)
      z(i) = x(i) ^ y;
    end

  else
    % both are arrays
    d1 = size(x);
    d2 = size(y);
    if ((length(d1) ~= length(d2)) || (any(d1 ~= d2)))
      error('must have same size and shape');
    end
    z = x;
    for j = 1:numel(x)
      z(j) = x(j)^y(j);
    end
  end

