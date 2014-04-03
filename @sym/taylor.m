function s = taylor(f,x,a,varargin)
%TAYLOR   symbolic Taylor series
%   todo: look at SMT interface

  %if (nargin == 3)
  %  n = 
  n = 8;
  warning('todo');

  cmd = [ 'def fcn(_ins):\n'  ...
            '    (f,x,a,n) = _ins\n'  ...
            '    s = f.series(x,a,n).removeO()\n'  ...
            '    return (s,)\n' ];
  s = python_sympy_cmd(cmd, f, x, a, n);

