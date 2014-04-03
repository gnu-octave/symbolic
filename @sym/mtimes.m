function z = mtimes(x, y)
%*   Matrix multiplication of inputs

  if isscalar(x) && isscalar(y)
    z = times(x,y);
  elseif isscalar(x) && ~isscalar(y)
    z = times(x,y);
  elseif ~isscalar(x) && isscalar(y)
    z = times(y,x);
  else  % both are arrays
    error('TODO: matrix mult not implemented yet');
  end

