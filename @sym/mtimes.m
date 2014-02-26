function z = mtimes(x, y)
%*   Matrix multiplication of inputs
%

  if isscalar(x) && isscalar(y)
    x = sym(x);
    y = sym(y);
    cmd = [ 'def fcn(ins):\n'  ...
            '    (a,b) = ins\n'  ...
            '    return (a*b,)\n' ];
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    x = sym(x);
    z = y;
    for i = 1:numel(y)
      z(i) = x * y(i);
    end
  elseif ~isscalar(x) && isscalar(y)
    z = times(y,x);

  else  % two array's case
    error('TODO: not implemented yet');
  end
