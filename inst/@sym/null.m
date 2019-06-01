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
%% @defmethod @@sym null (@var{A})
%% Basis for the nullspace of a symbolic matrix.
%%
%% Return a matrix whose columns are a basis for the nullspace of
%% the matrix.
%% Examples:
%% @example
%% @group
%% A = sym([1 1; 2 0]);
%% null (A)
%%   @result{} (sym) []  (empty 2×0 matrix)
%% @end group
%%
%% @group
%% A = sym([1 2; 1 2]);
%% null (A)
%%   @result{} (sym 2×1 matrix)
%%
%%       ⎡-2⎤
%%       ⎢  ⎥
%%       ⎣1 ⎦
%% @end group
%%
%% @group
%% A = sym(zeros(2,2));
%% null (A)
%%   @result{} (sym 2×2 matrix)
%%
%%       ⎡1  0⎤
%%       ⎢    ⎥
%%       ⎣0  1⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/rank, @@sym/orth}
%% @end defmethod


function r = null(A)

  cmd = { 'A = _ins[0]'
          'if not A.is_Matrix:'
          '    A = sympy.Matrix([A])'
          'ns = A.nullspace()'
          'if len(ns) == 0:'
          '    return sympy.zeros(A.cols, 0),'
          'return sympy.Matrix.hstack(*ns),' };

  r = pycall_sympy__ (cmd, A);

end


%!test
%! A = sym([1 2; 3 4]);
%! assert (isempty (null (A)))

%!assert (isempty (null (sym(4))))

%!test
%! A = sym([1 2 3; 3 4 5]);
%! assert (isequal (null(A), sym([1;-2;1])))
