%% Copyright (C) 2014, 2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod @@sym children (@var{f})
%% Return "children" (terms, lhs/rhs, etc) of symbolic expression.
%%
%% For a scalar expression, return a row vector of sym expressions:
%% @example
%% @group
%% syms x y
%% f = 2*x*y + sin(x);
%% C = children(f)
%%   @result{} C = (sym) [2⋅x⋅y  sin(x)]  (1×2 matrix)
%%
%% children(C(1))
%%   @result{} ans = (sym) [2  x  y]  (1×3 matrix)
%% children(C(2))
%%   @result{} ans = (sym) x
%% @end group
%% @end example
%%
%% A symbol/number/boolean has itself as children:
%% @example
%% @group
%% children(x)
%%   @result{} ans = (sym) x
%% @end group
%% @end example
%%
%% For matrices/vectors, return a cell array where each entry is
%% a row vector.  The cell array is the same shape as the input.
%% @example
%% @group
%% A = [x*y 2; 3 x]
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡x⋅y  2⎤
%%       ⎢      ⎥
%%       ⎣ 3   x⎦
%%
%% C = children (A)
%%   @result{} C = @{ ... @}
%% @end group
%%
%% @group
%% class (C), size (C)
%%   @result{} ans = cell
%%   @result{} ans =
%%        2   2
%%
%% C@{:@}
%%   @result{} ans = (sym) [x  y]  (1×2 matrix)
%%   @result{} ans = (sym) 3
%%   @result{} ans = (sym) 2
%%   @result{} ans = (sym) x
%% @end group
%% @end example
%%
%%
%% For sets, @code{children} can be used to extract
%% an matrix (array) containing the set elements, @pxref{finiteset}.
%% This is useful for accessing the elements of a set.
%%
%% @seealso{@@sym/lhs, @@sym/rhs, @@sym/eq, @@sym/lt, finiteset}
%% @end defmethod


function r = children(f)

  cmd = {
    'f, = _ins'
    'f = sympify(f)'  % mutable -> immutable
    'def scalarfcn(a):'
    '    if not hasattr(a, "args") or len(a.args) == 0:'
    '        return sympy.Matrix([a])'  % children(x) is [x]
    '    return sympy.Matrix([a.args])'
    '# note, not for MatrixExpr'
    'if isinstance(f, sp.MatrixBase):'
    '    r = [scalarfcn(a) for a in f.T]'  % note transpose
    'else:'
    '    r = scalarfcn(f)'
    'return r,' };

  r = pycall_sympy__ (cmd, f);

  if (~isscalar(f))
    r = reshape(r, size(f));
  end

end


%!test
%! % basics, sum
%! syms x y
%! f = 2*x + x*x + sin(y);
%! assert (isempty (setxor (children(f), [2*x x*x sin(y)])))

%!test
%! % basics, product
%! syms x y
%! f = 2*x*sin(y);
%! assert (isempty (setxor (children(f), [2 x sin(y)])))

%!test
%! % basics, product and powers
%! syms x y
%! f = 2*x^2*y^3;
%! assert (isempty (setxor (children(f), [2 x^2 y^3])))

%!test
%! % eqn, ineq
%! syms x y
%! lhs = 2*x^2; rhs = y^3 + 7;
%! assert (isequal (children(lhs == rhs), [lhs rhs]))
%! assert (isequal (children(lhs < rhs),  [lhs rhs]))
%! assert (isequal (children(lhs >= rhs), [lhs rhs]))

%!test
%! % matrix
%! syms x y
%! f = [4 + y  1 + x;  2 + x  3 + x];
%! c = children(f);
%! ec = {[4 y], [1 x]; [2 x], [3 x]};
%! assert (isequal (size(c), size(ec)))
%! for i=1:length(c)
%!   assert (isempty (setxor (c{i}, ec{i})))
%! end

%!test
%! % matrix, sum/prod
%! syms x y
%! f = [x + y; x*sin(y); sin(x)];
%! ec = {[x y]; [x sin(y)]; [x]};
%! c = children(f);
%! assert (isequal (size(c), size(ec)))
%! for i=1:length(c)
%!   assert (isempty (setxor (c{i}, ec{i})))
%! end

%!test
%! % scalar symbol
%! syms x
%! assert (isequal (children(x), x))

%!test
%! % scalar number
%! x = sym(6);
%! assert (isequal (children(x), x))

%!test
%! % symbolic size matrix
%! syms n m integer
%! A = sym('a', [n m]);
%! assert (isequal (children(A), [sym('a') n m]))
