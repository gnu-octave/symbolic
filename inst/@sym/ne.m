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
%% @deftypefn {Function File} {@var{g} =} ne (@var{a}, @var{b})
%% Test/define symbolic inequality, not equal to.
%%
%% @seealso{eq, lt, le, gt, ge, logical, isAlways, isequal}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function t = ne(x,y)

  % nanspecial is (python) 'True' here b/c nan is not equal
  % to everything, even itself.
  t = ineq_helper('[donotuse]', 'Ne', x, y, 'S.true');

end


%!test
%! % simple
%! x = sym(1); y = sym(1); e = x ~= y;
%! assert (~logical (e))
%! x = sym(1); y = sym(2); e = x ~= y;
%! assert (logical(e))

%!xtest
%! % array -- array
%! syms x
%! a = sym([1 3 3 2*x]);
%! b = sym([2 x 3 10]);
%! e = a ~= b;
%! assert (isa (e, 'sym'))
%! assert (logical (e(1)))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), 3 ~= x))
%! assert (~logical (e(3)))
%! assert (isa (e(4), 'sym'))
%! assert (isequal (e(4), 2*x ~= 10))

%!test
%! % oo
%! syms oo x
%! e = oo ~= x;
%! assert (isa (e, 'sym'))
%! s = strtrim (disp (e, 'flat'));
%! % SymPy <= 0.7.6 will be '!=', newer gives 'Ne', test both
%! assert (strcmp (s, 'oo != x') || strcmp (s, 'Ne(oo, x)'))

%!test
%! % nan
%! syms oo x
%! snan = sym(nan);
%! e = snan ~= sym(0);
%! assert (logical (e))
%! e = snan ~= snan;
%! assert (logical (e))

