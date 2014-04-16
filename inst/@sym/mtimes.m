function z = mtimes(x, y)
%*   Matrix multiplication of inputs

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (x,y) = _ins\n'  ...
          '    return ( x*y ,)\n' ];
 
  z = python_sympy_cmd(cmd, sym(x), sym(y));

