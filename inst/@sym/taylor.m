function s = taylor(f,x,a,varargin)
%TAYLOR   symbolic Taylor series
%   todo: look at SMT interface

  %if (nargin == 3)
  %  n = 
  n = 8;
  warning('todo');

  cmd = [ '(f,x,a,n) = _ins\n'  ...
          's = f.series(x,a,n).removeO()\n'  ...
          'return (s,)' ];
  s = python_cmd(cmd, sym(f), sym(x), sym(a), n);

