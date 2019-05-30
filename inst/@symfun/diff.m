%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@symfun diff (@var{f})
%% @defmethodx @@symfun diff (@var{f}, @var{x})
%% @defmethodx @@symfun diff (@var{f}, @var{x}, @var{x}, @dots{})
%% @defmethodx @@symfun diff (@var{f}, @var{x}, @var{n})
%% @defmethodx @@symfun diff (@var{f}, @var{x}, @var{y})
%% @defmethodx @@symfun diff (@var{f}, @var{x}, @var{x}, @var{y}, @var{y}, @dots{})
%% @defmethodx @@symfun diff (@var{f}, @var{x}, @var{n}, @var{y}, @var{m}, @dots{})
%% Symbolic differentiation of symbolic functions.
%%
%% Mostly the same as @code{@@sym/diff} (and indeed it
%% calls that code) but returns a @code{symfun}.
%%
%% The derivative is itself a symfun so you can evaluate at a point like:
%% @example
%% @group
%% syms u(x)
%% up = diff(u)           % u'(x)
%%   @result{} up(x) = (symfun)
%%       d
%%       ──(u(x))
%%       dx
%% up(2)                  % u'(2)
%%   @result{} ans = (sym)
%%       ⎛d       ⎞│
%%       ⎜──(u(x))⎟│
%%       ⎝dx      ⎠│x=2
%% @end group
%% @end example
%%
%% On GNU Octave, a further shortcut is possible:
%% @example
%% @group
%% syms u(x)
%% diff(u)(2)
%%   @result{} ans = (sym)
%%       ⎛d       ⎞│
%%       ⎜──(u(x))⎟│
%%       ⎝dx      ⎠│x=2
%% @end group
%%
%% @group
%% syms f(x, y)
%% @c doctest: +SKIP_IF(pycall_sympy__ ('return Version(spver) <= Version("1.3")'))
%% diff(f, x, y, y)(3, 2)     % a third partial eval at (3, 2)
%%   @result{} ans = (sym)
%%       ⎛   3           ⎞│
%%       ⎜  ∂            ⎟│
%%       ⎜──────(f(x, y))⎟│
%%       ⎜  2            ⎟│
%%       ⎝∂y  ∂x         ⎠│x=3, y=2
%% @end group
%% @end example
%%
%% @seealso{@@sym/diff, @@symfun/int}
%% @end defmethod

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function z = diff(f, varargin)

  z = diff(formula (f), varargin{:});
  z = symfun(z, f.vars);

end


%!test
%! % concrete fcn
%! syms x
%! f(x) = x*x;
%! g(x) = 2*x;
%! assert (logical (diff(f) == g))
%! assert (isa (diff(f), 'symfun'))

%!test
%! % abstract fcn
%! syms y(x)
%! assert (logical (diff(y) == diff(y(x))))
%! assert (isa (diff(y), 'symfun'))
