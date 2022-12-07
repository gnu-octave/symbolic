%% Copyright (C) 2016 Utkarsh Gautam
%% Copyright (C) 2016, 2019, 2022 Colin B. Macdonald
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
%% @defmethod  @@sym kron (@var{a}, @var{b})
%% @defmethodx @@sym kron (@var{a}, @var{b}, @dots{}, @var{c})
%% Kronecker tensor product of two or more symbolic matrices.
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
%%
%% @example
%% @group
%% kron([1, 2], [x, y; y, x], [1; 7])
%%   @result{} ans = (sym 4×4 matrix)
%%
%%       ⎡ x    y   2⋅x   2⋅y ⎤
%%       ⎢                    ⎥
%%       ⎢7⋅x  7⋅y  14⋅x  14⋅y⎥
%%       ⎢                    ⎥
%%       ⎢ y    x   2⋅y   2⋅x ⎥
%%       ⎢                    ⎥
%%       ⎣7⋅y  7⋅x  14⋅y  14⋅x⎦
%%
%% @end group
%% @end example
%% @end defmethod

%% Author: Utkarsh Gautam
%% Keywords:  kron product

function c = kron (varargin)

  if (nargin < 2)
    print_usage ();
  end

  for i = 1:nargin
    varargin{i} = sym (varargin{i});
  end

  cmd = { '_ins = (a if isinstance(a, (MatrixBase, NDimArray)) else Matrix([a]) for a in _ins)'
          'from sympy.physics.quantum import TensorProduct'
          'return TensorProduct(*_ins)' };
  c = pycall_sympy__ (cmd, varargin{:});
end


%!error kron (sym (2))

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

%!test
%! syms x y z
%! assert (isequal (kron (x, y, z), x*y*z))
%! assert (isequal (kron (x, y, z, 4), 4*x*y*z))
%! assert (isequal (kron ([2 3], y, z), [2 3]*y*z))
%! assert (isequal (kron ([2 3], [4; 5], y), [8 12; 10 15]*y))

%!test
%! syms x y
%! A = kron ([x y], [1, -1; -1, 1], [2 3; 4 5]);
%! D = kron ([7 9], [1, -1; -1, 1], [2 3; 4 5]);
%! A = double (subs (A, [x y], [7 9]));
%! assert (isequal (A, D))
