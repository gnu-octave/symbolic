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
%% @defmethod @@sym trace (@var{A})
%% Trace of symbolic matrix.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = [1 2 x; 3 sym(pi) 4; 13 5 2*x]
%%   @result{} A = (sym 3×3 matrix)
%%       ⎡1   2   x ⎤
%%       ⎢          ⎥
%%       ⎢3   π   4 ⎥
%%       ⎢          ⎥
%%       ⎣13  5  2⋅x⎦
%% trace(A)
%%   @result{} ans = (sym) 2⋅x + 1 + π
%% @end group
%% @end example
%%
%% As an example, we can check that the trace of the product is @emph{not}
%% the product of the traces:
%% @example
%% @group
%% A = sym([1 2; 3 4]);
%% B = sym([pi 3; 1 8]);
%% trace(A*B)
%%   @result{} ans = (sym) π + 43
%% trace(A) * trace(B)
%%   @result{} ans = (sym) 5⋅π + 40
%% @end group
%% @end example
%% However, such a property does hold if we use the Kronecker tensor product
%% (@pxref{@@sym/trace}):
%% @example
%% @group
%% kron(A, B)
%%   @result{} ans = (sym 4×4 matrix)
%%       ⎡ π   3   2⋅π  6 ⎤
%%       ⎢                ⎥
%%       ⎢ 1   8    2   16⎥
%%       ⎢                ⎥
%%       ⎢3⋅π  9   4⋅π  12⎥
%%       ⎢                ⎥
%%       ⎣ 3   24   4   32⎦
%% trace(kron(A, B))
%%   @result{} ans = (sym) 5⋅π + 40
%% trace(A) * trace(B)
%%   @result{} ans = (sym) 5⋅π + 40
%% @end group
%% @end example
%%
%% @seealso{@@sym/det}
%% @end defmethod


function z = trace(x)

  cmd = { 'x, = _ins'
          'if not x.is_Matrix:'
          '    x = sp.Matrix([[x]])'
          'return sp.trace(x),' };

  z = pycall_sympy__ (cmd, x);

end


%!test
%! % scalar
%! syms x
%! assert (isequal (trace(x), x))

%!test
%! syms x
%! A = [x 3; 2*x 5];
%! assert (isequal (trace(A), x + 5))
