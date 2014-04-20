function z = mtimes(x, y)
%*   Matrix multiplication of inputs

  cmd = [ '(x,y) = _ins\n'  ...
          'return ( x*y ,)' ];

  z = python_cmd (cmd, sym(x), sym(y));

