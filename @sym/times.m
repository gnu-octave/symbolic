function z = times(x, y)
%.*  Array multiply.
%   Return the element-by-element multiplication product of inputs.

  if isscalar(x) && isscalar(y)
    z = mtimes(x,y);
  elseif isscalar(x) && ~isscalar(y)
    z = mtimes(x,y);
  elseif ~isscalar(x) && isscalar(y)
    z = mtimes(y,x);
  else
    % both are arrays
    d1 = size(x);
    d2 = size(y);
    if ((length(d1) ~= length(d2)) || (any(d1 ~= d2)))
      error('must have same size and shape');
    end
    z = x;
    for j = 1:numel(x)
      z(j) = x(j)*y(j);
    end
    %for i = 1:n
    %  for j = 1:m
    %    z(i,j) = x(i,j)*y(i,j);
    %  end
    %end
  end

