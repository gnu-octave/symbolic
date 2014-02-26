function z = plus(a, b)
%+   Plus
%   X + Y adds syms X and Y.  If only one input is a sym, trys to
%   coerce the other to a sym.

  a = sym (a);
  b = sym (b);

  cmd = [ 'def fcn(ins):\n'  ...
          '    (a,b) = ins\n'  ...
          '    return (a+b,)\n' ];

  z = python_sympy_cmd (cmd, a, b);
