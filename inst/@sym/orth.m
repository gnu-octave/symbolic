%% Copyright (C) 2015, 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym orth (@var{A})
%% Orthonormal basis for column space (range) of symbolic matrix.
%%
%% Examples:
%% @example
%% @group
%% A = sym([1 1; 2 0]);
%% orth (A)
%%   @result{} (sym 2×2 matrix)
%%
%%       ⎡ √5   2⋅√5⎤
%%       ⎢ ──   ────⎥
%%       ⎢ 5     5  ⎥
%%       ⎢          ⎥
%%       ⎢2⋅√5  -√5 ⎥
%%       ⎢────  ────⎥
%%       ⎣ 5     5  ⎦
%% @end group
%%
%% @group
%% A = sym([1 2; 1 2]);
%% orth (A)
%%   @result{} ans = (sym 2×1 matrix)
%%
%%       ⎡√2⎤
%%       ⎢──⎥
%%       ⎢2 ⎥
%%       ⎢  ⎥
%%       ⎢√2⎥
%%       ⎢──⎥
%%       ⎣2 ⎦
%% @end group
%% @end example
%%
%% The basis is often not unique and in general @code{double(orth(A))} may
%% not match the output of @code{orth(double(A))}.
%%
%% @seealso{@@sym/rank, @@sym/null, @@sym/rref}
%% @end defmethod


function B = orth(A)

  cmd = { 'A = _ins[0]'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'L = A.rref()'
          'B = [A[:, i] for i in L[1]]' % get pivot columns in original
          'B = sp.GramSchmidt(B, True)'
          'B = sp.Matrix.hstack(*B)'
          'return B,'
        };

  B = pycall_sympy__ (cmd, A);

end


%!test
%! A = [1 2; 3 6];
%! K = orth(A);
%! L = orth(sym(A));
%! assert (isequal (size(L), [2 1]))
%! dif1 = abs (double(L) - K);
%! dif2 = abs (double(L) + K);
%! assert (all (dif1 < 1e-15) || all (dif2 < 1e-15))

%!test
%! A = [1; 3];
%! K = orth(A);
%! L = orth(sym(A));
%! assert (isequal (size(L), [2 1]))
%! dif1 = abs (double(L) - K);
%! dif2 = abs (double(L) + K);
%! assert (all (dif1 < 1e-16) || all (dif2 < 1e-16))

%!test
%! A = sym([1 2; 3 4]);
%! L = orth(sym(A));
%! assert (isequal (size(L), [2 2]))
%! v = L(:, 1);
%! w = L(:, 2);
%! assert (isAlways (v' * v == 1))
%! assert (isAlways (w' * w == 1))
%! assert (isAlways (v' * w == 0))

%!test
%! A = sym([1 1; 1 0; 1 0]);
%! L = orth(sym(A));
%! assert (isequal (size(L), [3 2]))
%! v = L(:, 1);
%! w = L(:, 2);
%! assert (isAlways (v' * v == 1))
%! assert (isAlways (w' * w == 1))
%! assert (isAlways (v' * w == 0))
%! % y and z components must be equal
%! assert (isAlways (v(2) == v(3)))
%! assert (isAlways (w(2) == w(3)))
