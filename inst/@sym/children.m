%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{r} =} children (@var{f})
%% Return "children" (terms, lhs/rhs, etc) of symbolic expression.
%%
%% For a scalar expression, return a row vector of sym expressions.
%%
%% For a matrix/vector, return a cell array where each entry is
%% a row vector.
%%
%% @seealso{lhs, rhs}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = children(f)

  cmd = {
    'f, = _ins'
    'f = sympify(f)'  % mutable -> immutable
    'if f.is_Matrix:'
    '    r = [sympy.Matrix([a.args]) for a in f.T]'  % note transpose
    'else:'
    '    r = sympy.Matrix([f.args])'
    'return r,' };

  r = python_cmd (cmd, f);

  if (~isscalar(f))
    r = reshape(r, size(f));
  end

end


%!test
%! % basics, sum
%! syms x y
%! f = 2*x + x*x + sin(y);
%! assert (isequal (children(f), [2*x x*x sin(y)]))

%!test
%! % basics, product
%! syms x y
%! f = 2*x*sin(y);
%! assert (isequal (children(f), [2 x sin(y)]))

%!test
%! % basics, product and powers
%! syms x y
%! f = 2*x^2*y^3;
%! assert (isequal (children(f), [2 x^2 y^3]))

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
%! f = [2*x + y^2  1 + x; 2 + x  3 + x];
%! c = children(f);
%! ec = {[2*x y^2], [1 x]; [2 x], [3 x]};
%! assert (isequal (c, ec))

%!xtest
%! % matrix, sum/prod
%! syms x y
%! disp('what do we want here?')
%! f = [2*x+y; x*sin(y)]
%! c = children(f)
%! assert(false)

%!xtest
%! % scalar, no expr
%! syms x
%! disp('what do we want here?')
%! c = children(x)
%! c = children(sym(1))
%! assert(false)

