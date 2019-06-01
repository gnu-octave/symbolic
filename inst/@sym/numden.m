%% Copyright (C) 2015, 2016, 2018-2019 Colin B. Macdonald
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
%% @deftypemethod @@sym {[@var{N}, @var{D}] =} numden (@var{f})
%% Extract numerator and denominator of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% f = sym(5)/6;
%% [N, D] = numden (f)
%%   @result{} N = (sym) 5
%%   @result{} D = (sym) 6
%% @end group
%%
%% @group
%% syms x
%% f = (x^2+2*x-1)/(2*x^3+9*x^2+6*x+3)
%%   @result{} f = (sym)
%%             2
%%            x  + 2⋅x - 1
%%       ─────────────────────
%%          3      2
%%       2⋅x  + 9⋅x  + 6⋅x + 3
%%
%% [N, D] = numden (f)
%%   @result{} N = (sym)
%%        2
%%       x  + 2⋅x - 1
%%
%%   @result{} D = (sym)
%%          3      2
%%       2⋅x  + 9⋅x  + 6⋅x + 3
%% @end group
%% @end example
%%
%% @var{f} can be a matrix, for example:
%% @example
%% @group
%% f = [1/x  exp(x)  exp(-x)];
%% @c  @result{} f = (sym 1×3 matrix)
%% @c      ⎡1   x   -x⎤
%% @c      ⎢─  ℯ   ℯ  ⎥
%% @c      ⎣x         ⎦
%% [N, D] = numden (f)
%%   @result{} N = (sym 1×3 matrix)
%%       ⎡    x   ⎤
%%       ⎣1  ℯ   1⎦
%%
%%   @result{} D = (sym 1×3 matrix)
%%       ⎡       x⎤
%%       ⎣x  1  ℯ ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/partfrac, @@sym/children, @@sym/coeffs, @@sym/children, @@sym/lhs, @@sym/rhs}
%% @end deftypemethod


function [N, D] = numden (f)

  if (nargin ~= 1)
    print_usage ();
  end

  cmd = { 'f, = _ins'
          'if not isinstance(f, MatrixBase):'
          '    return fraction(f)'
          'n = f.as_mutable()'
          'd = n.copy()'
          'for i in range(0, len(n)):'
          '    n[i], d[i] = fraction(f[i])'
          'return n, d' };

  [N, D] = pycall_sympy__ (cmd, f);

end


%!error <Invalid> numden (sym(1), 2)

%!test
%! syms x
%! [n, d] = numden (1/x);
%! assert (isequal (n, sym(1)) && isequal (d, x))

%!test
%! syms x y
%! n1 = [sym(1); x];
%! d1 = [x; y];
%! [n, d] = numden (n1 ./ d1);
%! assert (isequal (n, n1) && isequal (d, d1))

%!test
%! [n, d] = numden (sym(2));
%! assert (isequal (n, 2));
%! assert (isequal (d, 1));

%!test
%! syms x y
%! [n, d] = numden ((x + pi)/(y + 6));
%! assert (isequal (n, x + pi));
%! assert (isequal (d, y + 6));

%!test
%! syms x y
%! [n, d] = numden ((x^2 + y^2)/(x*y));
%! assert (isequal (n, x^2 + y^2));
%! assert (isequal (d, x*y));
