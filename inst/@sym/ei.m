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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{y} =} ei (@var{x})
%% Symbolic exponential integral (Ei) function.
%%
%% Example:
%% @example
%% @group
%% >> syms x
%% >> f = ei(x)
%%    @result{} f = (sym) Ei(x)
%% >> diff(f)
%%    @result{} (sym)
%%       x
%%      ℯ
%%      ──
%%      x
%% @end group
%% @end example
%%
%% Note @code{ei} differs from @code{expint}:
%% @example
%% @group
%% >> g = expint(x)
%%    @result{} g = (sym) E₁(x)
%% >> diff(g)
%%    @result{} (sym)
%%        -x
%%      -ℯ
%%      ─────
%%        x
%% @end group
%% @end example
%%
%% @seealso{expint}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = ei(x)
  y = uniop_helper (x, 'Ei');
end


%!test
%! syms x
%! f = ei(sym(0));
%! assert (double(f) == -inf)

%!test
%! D = [1.895117816355937  4.954234356001890];
%! A = ei(sym([1 2]));
%! assert (all (abs(double(A) - D) < 1e-15))
