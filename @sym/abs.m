function z = abs(x)
%ABS  Symbolic absolute value function
%   TODO: complex input?

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,) = ins\n'  ...
          '    y = sp.Abs(x)\n'  ...
          '    return (y,)\n' ];

z = python_sympy_cmd(cmd, x);

