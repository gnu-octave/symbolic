function z = log2(x)
%LOG2  Symbolic log base 2 function

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (x,) = _ins\n'  ...
          '    y = sp.log(x,2)\n'  ...
          '    return (y,)\n' ];

  z = python_sympy_cmd(cmd, x);

