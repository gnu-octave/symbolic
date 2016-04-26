%% Copyright (C) 2016 Lagu
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
%% @deftypefn  {Function File} {@var{y} =} frac (@var{x})
%% Return the fractional part of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% y = frac(sym(3)/2)
%%   @result{} y = (sym) 1/2
%%
%% syms x
%% rewrite(frac(x), 'floor')
%%   @result{} ans = (sym) x - ⌊x⌋
%% @end group
%% @end example
%%
%% *Note*: this function relies on SymPy >= 1.0.
%%
%% @seealso{ceil, floor, fix, round}
%% @end deftypefn

function y = frac(x)
  y = uniop_helper (x, 'frac');
end

%!test
%! if (python_cmd ('return Version(spver) < Version("0.7.7.dev"),'))
%!   fprintf('\n  skipping: no "frac" in SymPy <= 0.7.6.x\n')
%! else
%! f1 = frac(sym(11)/10);
%! f2 = sym(1)/10;
%! assert (isequal (f1, f2))
%! end

%!test
%! if (python_cmd ('return Version(spver) < Version("0.7.7.dev"),'))
%! else
%! % fails on SymPy 0.7.6.1
%! d = sym(-11)/10;
%! c = sym(9)/10;
%! assert (isequal (frac (d), c))
%! end

%!test
%! if (python_cmd ('return Version(spver) < Version("0.7.7.dev"),'))
%! else
%! d = sym(-19)/10;
%! c = sym(1)/10;
%! assert (isequal (frac (d), c))
%! end
