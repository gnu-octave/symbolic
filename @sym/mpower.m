function z = mpower(x, y)
%^   Matrix power

  cmd = [ 'def fcn(ins):\n'  ...
          '    (a,b) = ins\n'  ...
          '    return (a**b,)\n' ];

  if isscalar(x) && isscalar(y)
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    error('TODO: scalar^array not implemented yet');

  elseif ~isscalar(x) && isscalar(y)
    % todo: sympy can do int and rat, then MatPow, check MST
    z = python_sympy_cmd(cmd, sym(x), sym(y));

  else  % two array's case
    error('TODO: array^array not implemented yet');
  end
