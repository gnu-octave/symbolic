%% Copyright (C) 2016 Alex Vong
%% Copyright (C) 2017-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{J} =} jordan (@var{A})
%% @deftypemethodx @@sym {[@var{V}, @var{J}] =} jordan (@var{A})
%% Symbolic Jordan canonical form of a matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym ([6 5 -2 -3; -3 -1 3 3; 2 1 -2 -3; -1 1 5 5]);
%% jordan (A)
%%   @result{} ans = (sym 4×4 matrix)
%%       ⎡2  1  0  0⎤
%%       ⎢          ⎥
%%       ⎢0  2  0  0⎥
%%       ⎢          ⎥
%%       ⎢0  0  2  1⎥
%%       ⎢          ⎥
%%       ⎣0  0  0  2⎦
%% @end group
%% @end example
%%
%% We can also compute the generalized eigenvectors:
%% @example
%% @group
%% [V, J] = jordan (A)
%%   @result{} V = (sym 4×4 matrix)
%%       ⎡4   1  5   0⎤
%%       ⎢            ⎥
%%       ⎢-3  0  -3  1⎥
%%       ⎢            ⎥
%%       ⎢2   0  1   0⎥
%%       ⎢            ⎥
%%       ⎣-1  0  1   0⎦
%%   @result{} J = (sym 4×4 matrix)
%%       ⎡2  1  0  0⎤
%%       ⎢          ⎥
%%       ⎢0  2  0  0⎥
%%       ⎢          ⎥
%%       ⎢0  0  2  1⎥
%%       ⎢          ⎥
%%       ⎣0  0  0  2⎦
%% @end group
%%
%% @group
%% A*V - V*J
%%   @result{} ans = (sym 4×4 matrix)
%%       ⎡0  0  0  0⎤
%%       ⎢          ⎥
%%       ⎢0  0  0  0⎥
%%       ⎢          ⎥
%%       ⎢0  0  0  0⎥
%%       ⎢          ⎥
%%       ⎣0  0  0  0⎦
%% @end group
%% @end example
%%
%% The generalized eigenvectors are the columns of @var{V}.
%% Those corresponding to a Jordan block form a cycle.
%% We can check those columns corresponding to the leftmost Jordan block:
%% @example
%% @group
%% lambda = J(2, 2)
%%   @result{} lambda = (sym) 2
%% B = A - lambda*eye (4);
%% v2 = V(:, 2)
%%   @result{} v2 = (sym 4×1 matrix)
%%       ⎡1⎤
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎣0⎦
%% v1 = B * v2
%%   @result{} v1 = (sym 4×1 matrix)
%%       ⎡4 ⎤
%%       ⎢  ⎥
%%       ⎢-3⎥
%%       ⎢  ⎥
%%       ⎢2 ⎥
%%       ⎢  ⎥
%%       ⎣-1⎦
%% v0 = B * v1
%%   @result{} v0 = (sym 4×1 matrix)
%%       ⎡0⎤
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎣0⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/charpoly, @@sym/eig}
%% @end deftypemethod

%% Author: Alex Vong
%% Keywords: symbolic

function [V, J] = jordan (A)
  cmd = {'(A, calctrans) = _ins'
         'if not A.is_Matrix:'
         '    A = sp.Matrix([A])'
         'return A.jordan_form(calctrans)'};

  if (nargout <= 1)
    V = pycall_sympy__ (cmd, sym (A), false);
  else
    [V, J] = pycall_sympy__ (cmd, sym (A), true);
  end
end


%!test
%! % basic
%! A = sym ([2 1 0 0; 0 2 1 0; 0 0 3 0; 0 1 -1 3]);
%! [V, J] = jordan (A);
%! assert (isequal (inv (V) * A * V, J));
%! assert (isequal (J, sym ([2 1 0 0; 0 2 0 0; 0 0 3 0; 0 0 0 3])))
%! % the first 2 generalized eigenvectors form a cycle
%! assert (isequal ((A - J(1, 1) * eye (4)) * V(:, 1), zeros (4, 1)));
%! assert (isequal ((A - J(2, 2) * eye (4)) * V(:, 2), V(:, 1)));
%! % the last 2 generalized eigenvectors are eigenvectors
%! assert (isequal ((A - J(3, 3) * eye (4)) * V(:, 3), zeros (4, 1)));
%! assert (isequal ((A - J(4, 4) * eye (4)) * V(:, 4), zeros (4, 1)));

%!test
%! % scalars
%! assert (isequal (jordan (sym (-10)), sym (-10)));
%! assert (isequal (jordan (sym ('x')), sym ('x')));

%!test
%! % diagonal matrices
%! A = diag (sym ([6 6 7]));
%! [V1, D] = eig (A);
%! [V2, J] = jordan (A);
%! assert (isequal (V1, V2));
%! assert (isequal (D, J));

%!test
%! % matrices of unknown entries
%! A = [sym('a') sym('b'); sym('c') sym('d')];
%! [V, D] = eig (A);
%! J = jordan (A);
%! assert (isequal (simplify (D), simplify (J)));

%!test
%! % matrices of mixed entries
%! A = [sym('x')+9 sym('y'); sym(0) 6];
%! [V, D] = eig (A);
%! J = jordan (A);
%! assert (isequal (simplify (D), simplify (J)));
