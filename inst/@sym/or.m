%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{z} =} or (@var{x}, @var{y})
%% Logical or of symbolic arrays.
%%
%% @seealso{and, not, xor, eq, ne, logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = or(x, y)

    r = binop_helper(x, y, 'lambda a,b: Or(a, b)');

end


%!shared t, f
%! t = sym(true);
%! f = sym(false);

%!test
%! % simple
%! assert (isequal (t | f, t))
%! assert (isequal (t | t, t))
%! assert (isequal (f | f, f))

%!test
%! % array
%! w = [t t f f];
%! z = [t f t f];
%! assert (isequal (w | z, [t t t f]))

%!xtest
%! % output is sym even for scalar t/f
%! % ₣IXME: should match other bool fcns
%! assert (isa (t | f, 'sym'))

%!test
%! % eqns
%! syms x
%! e = or(x == 4, x == 5);
%! assert (isequal (subs(e, x, [3 4 5 6]), [f t t f]))

