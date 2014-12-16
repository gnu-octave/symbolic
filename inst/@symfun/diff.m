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
%% @deftypefn  {Function File} {@var{g} =} diff (@var{f})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, @var{x})
%% @deftypefnx {Function File} {@var{g} =} diff (@var{f}, ...)
%% Symbolic differentiation of symbolic functions.
%%
%% Mostly the same as @code{diff} for class @code{sym} (indeed it
%% calls that code) but returns a @code{symfun}.
%%
%% The derivative is itself a symfun so you can evaluate at a point like:
%% @example
%% syms u(x)
%% up = diff(u)  % u'(x)
%% up(2)         % u'(2)
%% @end example
%%
%% At least on GNU Octave, a further shortcut is possible:
%% @example
%% syms u(x)
%% diff(u)(2)  % u'(2)
%% syms f(x, y)
%% diff(f, x, y, y)(3, 2)  % a third partial eval at (3, 2)
%% @end example
%%
%% @seealso{int}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, differentiation

function z = diff(f, varargin)

  z = diff(f.sym, varargin{:});
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
