function S = symsum(f,n,a,b)
%SYMSUM   symbolic summation
%   todo: symsum(f, [a b])

  %if (nargin == 3)
  %  n = symvar

  cmd = [ 'def fcn(_ins):\n'  ...
            '    (f,n,a,b) = _ins\n'  ...
            '    S = sp.summation(f,(n,a,b))\n'  ...
            '    return (S,)\n' ];
  S = python_sympy_cmd(cmd, sym(f), sym(n), sym(a), sym(b));

