function z = plus(x, y)
%+   Plus
%   X + Y adds sym X and sym Y.

  if isscalar(x) && isscalar(y)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (x,y) = ins\n'  ...
            '    return (x+y,)\n' ];
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    z = make_zeros(size(y));
    for i = 1:numel(y)
      z(i) = x + y(i);
    end

  elseif ~isscalar(x) && isscalar(y)
    z = y + x;

  else  % both are arrays
    assert_same_shape(x,y);
    z = make_zeros(size(x));
    for j = 1:numel(x)
      z(j) = x(j) + y(j);
    end
  end

