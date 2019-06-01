%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym cond (@var{A})
%% Symbolic condition number of a symbolic matrix.
%%
%% Examples:
%% @example
%% @group
%% A = sym([1 2; 3 0]);
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% cond(A)^2
%%   @result{} (sym)
%%
%%       √13 + 7
%%       ───────
%%       7 - √13
%% @end group
%% @end example
%%
%% @seealso{@@sym/svd}
%% @end defmethod


function k = cond(A)

  cmd = { '(A,) = _ins'  ...
          'if not A.is_Matrix:' ...
          '    A = sp.Matrix([A])' ...
          'return A.condition_number(),' };

  k = pycall_sympy__ (cmd, sym(A));

end


%!test
%! A = [1 2; 3 4];
%! B = sym(A);
%! k1 = cond(A);
%! k2 = cond(B);
%! k3 = double(k2);
%! assert (k1 - k3 <= 100*eps)

%!test
%! % matrix with symbols
%! syms x positive
%! A = [x 0; sym(0) 2*x];
%! k1 = cond(A);
%! assert (isequal (k1, sym(2)))
