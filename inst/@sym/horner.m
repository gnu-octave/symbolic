%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File} {@var{q} =} horner (@var{p})
%% Convert a symbolic polynomial to Horner form.
%%
%% The Horner form minimizes the number of arthimetic operators to
%% evaluate the polynomial.
%%
%% Example:
%% @example
%% syms x
%% p = poly2sym ([2 4 6 8], x)   % p = 2*x^3 + 4*x^2 + 6*x + 8
%% q = horner (p)                % q = x*(x*(2*x + 4) + 6) + 8
%% @end example
%%
%% @seealso{poly2sym}
%% @end deftypefn

function y = horner(x)

  y = python_cmd ('return ( sp.horner(*_ins), )', x);

end


%!shared x,p,q
%! syms x
%! p = poly2sym ([2 4 6 8], x);
%! q = horner (p);
%!assert (isAlways (p == q))
%!assert (isAlways (horner(2*x^3 + 4*x^2 + 6*x + 8) == q))
%!assert (isAlways (horner(x) == x))
%!assert (isAlways (horner(sym(1)) == 1))
