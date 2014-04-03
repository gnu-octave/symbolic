function z = times(x, y)
%.*  Array multiply.
%   Return the element-by-element multiplication product of inputs.

  if isscalar(x) && isscalar(y)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (a,b) = ins\n'  ...
            '    return (a*b,)\n' ];
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    z = make_zeros(size(y));
    for i = 1:numel(y)
      z(i) = x * y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = times(y,x);

  else  % both are arrays
    assert_same_shape(x,y);
    z = make_zeros(size(x));
    for j = 1:numel(x)
      z(j) = x(j) * y(j);
    end
    %for i = 1:n
    %  for j = 1:m
    %    z(i,j) = x(i,j)*y(i,j);
    %  end
    %end
  end

