function z = mrdivide(x,y)
%/   forward slash division

  if isscalar(x) && isscalar(y)
    z = rdivide(x, y);

  elseif isscalar(x) && ~isscalar(y)
    error('TODO: scalar/array not implemented yet');

  elseif ~isscalar(x) && isscalar(y)
    z = rdivide(x, y);

  else  % two array's case
    error('TODO: array/array not implemented yet');
  end

