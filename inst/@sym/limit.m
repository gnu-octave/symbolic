%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @defmethod  @@sym limit (@var{expr}, @var{x}, @var{a}, @var{dir})
%% @defmethodx @@sym limit (@var{expr}, @var{x}, @var{a})
%% @defmethodx @@sym limit (@var{expr}, @var{a})
%% @defmethodx @@sym limit (@var{expr})
%% Evaluate symbolic limits.
%%
%% The limit of @var{expr} as @var{x} tends to @var{a} from
%% @var{dir}.  @var{dir} can be @code{left} or @code{right}.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% L = limit(sin(x)/x, x, 0)
%%   @result{} L = (sym) 1
%% L = limit(1/x, x, sym(inf))
%%   @result{} L = (sym) 0
%% L = limit(1/x, x, 0, 'left')
%%   @result{} L = (sym) -∞
%% L = limit(1/x, x, 0, 'right')
%%   @result{} L = (sym) ∞
%% @end group
%% @end example
%%
%% If @var{x} is omitted, @code{symvar} is used to determine the
%% variable.  If @var{a} is omitted, it defaults to 0.
%%
%% @var{dir} defaults to @code{right}.  Note this is different from
%% Matlab's Symbolic Math Toolbox which returns @code{NaN} for
%% @code{limit(1/x, x, 0)}
%% (and @code{+/-inf} if you specify @code{left/right}).  I'm not
%% sure how to get this nicer behaviour from SymPy.
%% FIXME: this is https://github.com/cbm755/octsympy/issues/74
%%
%% @seealso{@@sym/diff}
%% @end defmethod


function L = limit(f, x, a, dir)

  if (nargin > 4 || nargin < 1)
    print_usage ();
  end

  f = sym(f);
  if (nargin < 4)
    dir= 'right';
  end
  if (nargin == 2)
    a = x;
    x = symvar(f, 1);
  end
  if (nargin == 1)
    x = symvar(f, 1);
    a = 0;
  end

  switch (lower (dir))
    case {'left' '-'}
      pdir = '-';
    case {'right' '+'}
      pdir = '+';
    otherwise
      print_usage ();
  end

  if (isempty (x))
    L = f;
    return
  end

  L = elementwise_op ('lambda f, x, a, dir: f.limit(x, a, dir=dir)', ...
                      sym(f), sym(x), sym(a), pdir);
end


%!error <Invalid> limit (sym(1), 2, 3, 4, 5)

%!shared x, oo
%! syms x
%! oo = sym(inf);

%!assert (isa (limit(x, x, pi), 'sym'))

%!assert (isequal (limit(x, x, pi), sym(pi)))

%!assert (isequal (limit(sin(x)/x, x, 0), 1))

%!test
%! % left/right-hand limit
%! assert (isequal (limit(1/x, x, 0, 'right'), oo))
%! assert (isequal (limit(1/x, x, 0), oo))
%! assert (isequal (limit(1/x, x, 0, 'left'), -oo))
%! assert (isequal (limit(1/x, x, oo), 0))
%! assert (isequal (limit(sign(x), x, 0, 'left'), -1))
%! assert (isequal (limit(sign(x), x, 0, 'right'), 1))
%! assert (isequal (limit(sign(x), x, 0, '-'), -1))
%! assert (isequal (limit(sign(x), x, 0, '+'), 1))

%!test
%! % matrix
%! syms y
%! A = [x 1/x x*y];
%! B = sym([3 sym(1)/3 3*y]);
%! assert (isequal (limit(A, x, 3), B))

%!test
%! % omitting arguments
%! syms a
%! assert (isequal (limit(a), 0))
%! assert (isequal (limit(a*x+a+2), a+2))
%! assert (isequal (limit(a*x+a+2, 6), 7*a+2))

%!test
%! % constants
%! assert (isequal (limit(sym(6)), 6))
%! assert (isequal (limit(sym(6), 7), 6))
%! assert (isequal (limit([sym(6) sym(2)], 7), [6 2]))

%!test
%! % double constant, with sym limit
%! a = limit (6, sym(0));
%! assert (isa (a, 'sym'))
%! assert (isequal (a, sym(6)))
