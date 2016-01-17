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
%% @deftypefn  {Function File} {@var{y} =} fix (@var{x})
%% Return the fractional part of a symbolic expression.
%%
%% Example:
%% @example
%% @group
%% y = frac(sym(3)/2)               % doctest: +SKIP
%%   @result{} y = (sym) 1/2
%% @end group
%% @end example
%%
%% *Note*: this function relies on a recent SymPy >= 0.7.7-dev.
%%
%% @seealso{ceil, floor, fix, round}
%% @end deftypefn

function y = frac(x)
  y = uniop_helper (x, 'frac');
end

%!test
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=761)
%!   disp('skipping: no "frac" in SymPy <= 0.7.6.x')
%! else
%! f1 = frac(sym(11)/10);
%! f2 = sym(1)/10;
%! assert (isequal (f1, f2))
%! end

%!test
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=761)
%! else
%! % fails on SymPy 0.7.6.1
%! d = sym(-11)/10;
%! c = sym(9)/10;
%! assert (isequal (frac (d), c))
%! end

%!test
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=761)
%! else
%! d = sym(-19)/10;
%! c = sym(1)/10;
%! assert (isequal (frac (d), c))
%! end
