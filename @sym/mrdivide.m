function z = mrdivide(x,y)
%/   forward slash division

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,y) = ins\n'  ...
          '    return (x/y,)\n' ];

  z = python_sympy_cmd (cmd, x, y);
