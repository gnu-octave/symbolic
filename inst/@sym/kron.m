%% Copyright (C) 2016 Utkarsh Gautam
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
%% @defmethod @@sym kron (@var{a}, @var{b})
%% Kronecker tensor product of two matrices.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% kron(eye(2)*x, [1, -1; -1, 1])
%%   @result{} ans = (sym 4×4 matrix)
%%
%%       ⎡x   -x  0   0 ⎤
%%       ⎢              ⎥
%%       ⎢-x  x   0   0 ⎥
%%       ⎢              ⎥
%%       ⎢0   0   x   -x⎥
%%       ⎢              ⎥
%%       ⎣0   0   -x  x ⎦
%%
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x y
%% kron([1, 2], [x, y; y, x])
%%   @result{} ans = (sym 2×4 matrix)
%%
%%       ⎡x  y  2⋅x  2⋅y⎤
%%       ⎢              ⎥
%%       ⎣y  x  2⋅y  2⋅x⎦
%%
%% @end group
%% @end example
%% @end defmethod

%% Author: Utkarsh Gautam
%% Keywords:  kron product

function c = kron (a, b)

  if (isscalar (a) || isscalar (b))
    c = a*b;
  else
    cmd = { 'a, b = _ins'
            'from sympy.physics.quantum import TensorProduct'
            'return TensorProduct(Matrix(a), Matrix(b))'
          };
    c = pycall_sympy__ (cmd, sym(a), sym(b));
  end
end


%!test
%! syms x y
%! A = [sin(x), sin(y); x, y];
%! B = ones(2);
%! expected = sym([sin(x), sin(x), sin(y), sin(y); sin(x), sin(x), sin(y), sin(y); x, x, y, y; x, x, y, y]);
%! assert (isequal (kron(A, B), expected))

%!test
%! syms x y
%! A = [sin(x), sin(y); x, y];
%! B = 2;
%! assert (isequal (kron(A, B), 2*A))

%!test
%! syms x y
%! A = [sin(x), sin(y)];
%! B = 2;
%! assert (isequal( kron(B, A), 2*A))

%!test
%! syms x y;
%! X = [tan(x), tan(x)];
%! Y = [cot(x); cot(x)];
%! expected = sym(ones(2));
%! assert (isequal (simplify(kron(X, Y)), expected))

%!test
%! syms x y z
%! X = [x, y, z];
%! Y = [y, y; x, x];
%! expected = [x*y, x*y, y^2, y^2, y*z, y*z; x^2, x^2, x*y, x*y, x*z, x*z];
%! assert (isequal (kron(X, Y), expected))

%!test
%! syms x y
%! X = [x, x^2; y, y^2];
%! Y = [1, 0; 0, 1];
%! expected = [x, x^2, 0, 0; y, y^2, 0, 0; 0, 0, x, x^2; 0, 0, y, y^2];
%! assert (isequal (kron(Y, X), expected))
