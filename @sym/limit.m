function L = limit(f,x,a,dir)
%LIMIT   Evaluate symbolic limits
%   L = limit(expr, x, a, dir)
%      limit of 'expr' as 'x' tends to 'a' from 'dir' ('left' or 'right')
%      'dir' defaults to 'right'.
%      todo: check default behavior on SMT
%   Examples:
%   syms x
%   L = limit(sin(x)/x, x, 0)
%   L = limit(1/x, x, sym(inf))
%   L = limit(1/x, x, 0, 'left')
%   L = limit(1/x, x, 0, 'right')
%
%   MATLAB Symbolic Toolbox supports omitting 'x' and then 'a'
%   but we don't currently support that.

  if (nargin < 4)
    dir= 'right';
  %elseif (nargin < 3)
  %  x = symvar(f);  % todo: not implemented
  elseif (nargin < 3)
    error('You must specify the var and limit');
  end

  switch (lower (dir))
    case {'left' '-'}
      pdir = '-';
    case {'right' '+'}
      pdir = '+';
    otherwise
      error('invalid')
  end
  
  cmd = [ 'def fcn(ins):\n'  ...
            '    (f,x,a,pdir) = ins\n'  ...
            '    g = f.limit(x,a,dir=pdir)\n'  ...
            '    return (g,)\n' ];
  L = python_sympy_cmd(cmd, sym(f), sym(x), sym(a), pdir);


%!shared x
%! syms x
%!assert(isa(limit(x,x,pi), 'sym'))
%!assert(isequal(limit(x,x,pi), sym(pi)))

