%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym adjoint (@var{A})
%% Adjoint/Adjugate of a symbolic square matrix.
%%
%% @strong{Caution}: This computes the Adjugate or ``Classical Adjoint''
%% of the matrix.  For the Conjugate Transpose (which is commonly
%% referred to the ``Adjoint''), @pxref{@@sym/ctranspose}.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = [x x^3; 2*x i];
%% X = adjoint(A)
%%   @result{} X = (sym 2×2 matrix)
%%       ⎡        3⎤
%%       ⎢ ⅈ    -x ⎥
%%       ⎢         ⎥
%%       ⎣-2⋅x   x ⎦
%% @end group
%% @end example
%% And note the matrix adjugate @code{X} satisfies:
%% @example
%% @group
%% A*X - det(A)*eye(2)
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡0  0⎤
%%       ⎢    ⎥
%%       ⎣0  0⎦
%% @end group
%% @end example
%% @seealso{@@sym/ctranspose}
%% @end defmethod

%% Reference: http://docs.sympy.org/dev/modules/matrices/matrices.html


function y = adjoint(x)
  if (nargin ~= 1)
    print_usage();
  end

  y = pycall_sympy__ ('_ins[0] = _ins[0] if _ins[0].is_Matrix else Matrix([_ins[0]]); return _ins[0].adjugate(),', x);
end


%!test
%! syms x
%! A = [x x^2; x^3 x^4];
%! B = [x^4 -x^2; -x^3 x];
%! assert( isequal( adjoint(A), B ))

%!test syms x
%! assert( isequal( adjoint(x), 1))
