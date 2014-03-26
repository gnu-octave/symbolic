function z = uminus(x)
%-   Unitary minus
%   -X is negative of the sym X.

  if isscalar(x)
    cmd = [ 'def fcn(ins):\n'  ...
            '    (x,) = ins\n'  ...
            '    return (-x,)\n' ];
    z = python_sympy_cmd(cmd, x);

  else
    z = 0 - x;

  end

