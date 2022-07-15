%% Copyright (C) 2022 Alex Vong
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
%% If not, see <https://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defun adjoint (@var{M})
%% Numerical Classical Adjoint / Adjugate of a square matrix.
%%
%% @strong{Note on Terminology}: This function computes the
%% ``Classical Adjoint'' / Adjugate of @var{M}. For the Conjugate Transpose /
%% Hermitian adjoint (which is commonly referred to as the ``Adjoint'' in
%% modern usage), @pxref{@@double/ctranspose}.
%%
%% Example:
%% @example
%% @group
%% M = [-3 2 -5; -1 0 -2; 3 -4 1];
%% A = adjoint (M)
%%   @result{} A =
%%        -8   18   -4
%%        -5   12   -1
%%         4   -6    2
%% @end group
%% @end example
%%
%% And note the following equalities involving the Classical Adjoint @code{A}:
%% @example
%% @group
%% M * A
%%   @result{} ans =
%%       -6   0   0
%%        0  -6   0
%%        0   0  -6
%% @end group
%%
%% @group
%% A * M
%%   @result{} ans =
%%       -6   0   0
%%        0  -6   0
%%        0   0  -6
%% @end group
%%
%% @group
%% det (M) * eye (3)
%%   @result{} ans =
%%     Diagonal Matrix
%%
%%       -6   0   0
%%        0  -6   0
%%        0   0  -6
%% @end group
%% @end example
%% @seealso{@@sym/adjoint}
%% @end defun

%% Reference: https://en.wikipedia.org/wiki/Adjugate_matrix


function A = adjoint (M)
  A = double (adjoint (vpa (M, 16)));
end


%!test
%! M = [1 2; 3 4];
%! A = [4 -2; -3 1];
%! assert (isequal (adjoint (M), A));

%!test
%! assert (isequal (adjoint (42), 1));
