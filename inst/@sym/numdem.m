%% Copyright (C) 2018-2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {[@var{N}, @var{D}] =} numdem (@var{f})
%% Numerator and denominator of an expression.
%%
%% Examples:
%% @example
%% @group
%% f = sym(5)/6;
%% [N, D] = numdem (f)
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
%% [N, D] = numdem (f)
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
%% [N, D] = numdem (f)
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
%% @seealso{@@sym/partfrac, @@sym/children}
%% @end deftypemethod

function [N, D] = numdem(f)

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


%!error <Invalid> numdem (sym(1), 2)

%!test
%! syms x
%! [n, d] = numdem(1/x);
%! assert (isequal (n, sym(1)) && isequal (d, x))

%!test
%! syms x y
%! n1 = [sym(1); x];
%! d1 = [x; y];
%! [n, d] = numdem(n1 ./ d1);
%! assert (isequal (n, n1) && isequal (d, d1))
