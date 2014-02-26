function z = log10(x)
%LOG  Symbolic log base 10 function

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,) = ins\n'  ...
          '    y = sp.log(x,10)\n'  ...
          '    return (y,)\n' ];

z = python_sympy_cmd(cmd, x);

