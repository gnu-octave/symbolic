function z = log10(x)
%LOG10  Symbolic log base 10 function

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (x,) = _ins\n'  ...
          '    y = sp.log(x,10)\n'  ...
          '    return (y,)\n' ];

  z = python_sympy_cmd(cmd, x);

