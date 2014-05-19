%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File}  {@var{y} =} limit (@var{expr}, @var{x}, @var{a}, @var{dir})
%% Evaluate symbolic limits.
%%
%% The limit of @var{expr} as @var{x} tends to @var{a} from
%% @var{dir}.  @var{dir} can be @code{left} or @code{right}.
%%
%% Examples:
%% @example
%% syms x
%% L = limit(sin(x)/x, x, 0)
%% L = limit(1/x, x, sym(inf))
%% L = limit(1/x, x, 0, 'left')
%% L = limit(1/x, x, 0, 'right')
%% @end example
%%
%% FIXME: Matlab's Symbolic Math Toolbox supports omitting @var{x}
%% and then @var{a} but we don't currently support that.
%%
%% @var{dir} defaults to @code{right}.  Note this is different from
%% Matlab's Symbolic Math Toolbox which returns @code{NaN} for
%% @code{limit(1/x, x, 0)}
%% (and @code{+/-inf} if you specify @code{left/right}.  I'm not
%% sure how to get this nicer behaviour from SymPy.
%%
%% @seealso{diff}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function L = limit(f,x,a,dir)

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

end


%!shared x, oo
%! syms x
%! oo = sym(inf);
%!assert(isa(limit(x,x,pi), 'sym'))
%!assert(isequal(limit(x,x,pi), sym(pi)))

%!assert(limit(sin(x)/x, x, 0) == 1);
%!assert(limit(1/x, x, 0, 'right') == oo);
%!assert(limit(1/x, x, 0) == oo);
%!assert(limit(1/x, x, 0, 'left') == -oo);
%!assert(limit(1/x, x, oo) == 0);
%!assert(limit(sign(x), x, 0, 'left') == -1);
%!assert(limit(sign(x), x, 0, 'right') == 1);
%!assert(limit(sign(x), x, 0, '-') == -1);
%!assert(limit(sign(x), x, 0, '+') == 1);