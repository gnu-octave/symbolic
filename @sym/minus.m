function z = minus(a, b)
%+   Minus
%   X - Y subtracts sym Y from sym X.  If only one input is a sym, try
%   to coerce the other to a sym.

  a = sym(a);
  b = sym(b);

  cmd = [ 'def fcn(ins):\n'  ...
          '    (a,b) = ins\n'  ...
          '    return (a-b,)\n' ];

  z = python_sympy_cmd(cmd, a, b);

