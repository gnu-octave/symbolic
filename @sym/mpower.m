function z = mpower(x, y)
%^   Matrix power

  if isscalar(x) && isscalar(y)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (a,b) = ins\n'  ...
            '    return (a**b,)\n' ];
    z = python_sympy_cmd(cmd, x, y);

  elseif isscalar(x) && ~isscalar(y)
    error('TODO: scalar^array not implemented yet');

  elseif ~isscalar(x) && isscalar(y)
    error('TODO: array^scalar not implemented yet');

  else  % two array's case
    error('TODO: array^array not implemented yet');
  end
