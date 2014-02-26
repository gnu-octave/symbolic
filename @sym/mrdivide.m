function z = mrdivide(x,y)

  x = sym (x);
  y = sym (y);

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,y) = ins\n'  ...
          '    return (x/y,)\n' ];

  z = python_sympy_cmd (cmd, x, y);
