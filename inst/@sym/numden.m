%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{n}, @var{d} =} numden (@var{x})
%% Extract numerator and demoninator of symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% [n, d] = numden(sym(4)/5)
%%    @result{} 4
%%    @result{} 5
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x y
%% [n, d] = numden((x+y)/sin(x))
%%    @result{} x + y
%%    @result{} sin(x)
%% @end group
%% @end example
%%
%% @seealso{coeffs, children, lhs, rhs}
%% @end deftypefn

function [n, d] = numden(x)

  [n, d] = python_cmd ('return (sympy.numer(*_ins), sympy.denom(*_ins))', sym(x));

end


%!test
%! [n, d] = numden(sym(2));
%! assert (isequal (n, 2));
%! assert (isequal (d, 1));

%!test
%! syms x y
%! [n, d] = numden((x + pi)/(y + 6));
%! assert (isequal (n, x + pi));
%! assert (isequal (d, y + 6));

%!test
%! syms x y
%! [n, d] = numden((x^2 + y^2)/(x*y));
%! assert (isequal (n, x^2 + y^2));
%! assert (isequal (d, x*y));
