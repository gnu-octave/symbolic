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
%% @deftypefn {Function File} {@var{g} =} gt (@var{a}, @var{b})
%% Test/define symbolic inequality, greater than.
%%
%% @seealso{lt, le, ge, eq, ne, logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = gt(x,y)

  t = ineq_helper('>', 'Gt', x, y);

end


%!test
%! % simple
%! x = sym(1); y = sym(1); e = x > y;
%! assert (islogical (e))
%! assert (~e)
%! x = sym(1); y = sym(2); e = x > y;
%! assert (islogical (e))
%! assert (~e)

%!test
%! % array -- array
%! syms x
%! a = sym([1 3 3 2*x]);
%! b = sym([2 x 3 10]);
%! e = a > b;
%! assert (isa (e, 'sym'))
%! assert (~e(1))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), 3 > x))
%! assert (~e(3))
%! assert (isa (e(4), 'sym'))
%! assert (isequal (e(4), 2*x > 10))

%!test
%! % oo
%! syms oo x
%! e = oo > x;
%! assert (isa (e, 'sym'))
%! assert (strcmp (strtrim (disp (e)), 'oo > x'))

