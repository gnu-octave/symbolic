function L = limit(f,x,a,dir)
%LIMIT   Evaluate symbolic limits
%   L = limit(expr, x, a, dir)
%      limit of 'expr' as 'x' tends to 'a' from 'dir' ('left' or 'right')
%
%   'dir' defaults to 'right'.  Note this is different from Matlab's
%   Symbolic Math Toolbox which returns NaN for limit(1/x, x, 0)
%   (and +/-inf if you specify 'left'/'right').  I'm not sure how to get
%   this nicer behaviour from SymPy.
%
%
%   Examples:
%   syms x
%   L = limit(sin(x)/x, x, 0)
%   L = limit(1/x, x, sym(inf))
%   L = limit(1/x, x, 0, 'left')
%   L = limit(1/x, x, 0, 'right')
%
%   Symbolic Math Toolbox supports omitting 'x' and then 'a'
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
  
  cmd = [ '(f,x,a,pdir) = _ins\n'  ...
          'g = f.limit(x,a,dir=pdir)\n'  ...
          'return (g,)' ];
  L = python_cmd (cmd, sym(f), sym(x), sym(a), pdir);


%!shared x
%! syms x
%!assert(isa(limit(x,x,pi), 'sym'))
%!assert(isequal(limit(x,x,pi), sym(pi)))

