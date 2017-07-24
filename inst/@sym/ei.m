%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @defmethod @@sym ei (@var{x})
%% Symbolic exponential integral (Ei) function.
%%
%% Definition and example:
%% @example
%% @group
%% syms x
%% f = ei(x)
%%   @result{} f = (sym) Ei(x)
%% rewrite(f, 'Integral')         % doctest: +SKIP
%%   @result{} (sym)
%%       x
%%       ⌠
%%       ⎮   t
%%       ⎮  ℯ
%%       ⎮  ── dt
%%       ⎮  t
%%       ⌡
%%       -∞
%% @end group
%% @end example
%% (@strong{Note} rewriting as an integral is not yet supported.)
%%
%% Other examples:
%% @example
%% @group
%% diff(f)
%%   @result{} (sym)
%%        x
%%       ℯ
%%       ──
%%       x
%% @end group
%% @end example
%%
%% @seealso{@@sym/expint}
%% @end defmethod


function y = ei(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('Ei', x);
end


%!test
%! syms x
%! f = ei(sym(0));
%! assert (double(f) == -inf)

%!test
%! D = [1.895117816355937  4.954234356001890];
%! A = ei(sym([1 2]));
%! assert (all (abs(double(A) - D) < 1e-15))
