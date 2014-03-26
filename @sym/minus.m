function z = minus(x, y)
%-   Minus
%   X - Y subtracts sym Y from sym X.

  if isscalar(x) && isscalar(y)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (x,y) = ins\n'  ...
            '    return (x-y,)\n' ];
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    z = y;
    for i = 1:numel(y)
      z(i) = x - y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = x;
    for i = 1:numel(x)
      z(i) = x(i) - y;
    end

  else  % both are arrays
    assert_same_shape();
    z = x;
    for j = 1:numel(x)
      z(j) = x(j) - y(j);
    end
  end

