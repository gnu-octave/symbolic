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
%% @deftypefn  {Function File} {@var{q} =} horner (@var{p})
%% @deftypefnx {Function File} {@var{q} =} horner (@var{p}, @var{x})
%% Convert a symbolic polynomial to Horner form.
%%
%% The Horner form minimizes the number of arthimetic operators to
%% evaluate the polynomial.
%%
%% Example:
%% @example
%% @group
%% syms x
%% p = poly2sym ([2 4 6 8], x)
%%    @result{}
%%          3      2
%%       2⋅x  + 4⋅x  + 6⋅x + 8
%% horner (p)
%%    @result{} x⋅(x⋅(2⋅x + 4) + 6) + 8
%% @end group
%% @end example
%%
%% You can specify the variable as a second input:
%% @example
%% @group
%% syms x a
%% p = expand((a+2)*(2*a+x)*(3*a+7))
%% horner(p, a)
%%    @result{} a⋅(a⋅(6⋅a + 26) + 28) + x⋅(a⋅(3⋅a + 13) + 14)
%% @end group
%% @end example
%%
%% @seealso{poly2sym}
%% @end deftypefn

function y = horner(p, x)

  if (nargin == 1)
    x = symvar(p, 1);
  end

  if (isempty(x))
    y = python_cmd ('return ( sp.horner(*_ins), )', p);
  else
    y = python_cmd ('return ( sp.horner(*_ins), )', p, x);
  end

end


%!assert (isAlways (horner(sym(1)) == 1))

%!test
%! syms x
%! assert (isAlways (horner(x) == x))

%!test
%! syms x a
%! p = a^2 + a*x + 2*a + 2*x;
%! assert (isequal (horner (p, a), a*(a+x+2) + 2*x))
%! q = a^2 + 2*a + x*(a + 2);
%! assert (isequal (horner (p, x), q))
%! assert (isequal (horner (p), q))

%!test
%! syms x
%! p = poly2sym ([2 4 6 8], x);
%! q = horner (p);
%! assert (isAlways (p == q))
%! assert (isAlways (horner(2*x^3 + 4*x^2 + 6*x + 8) == q))
