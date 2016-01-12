%% Copyright (C) 2016 Colin Macdonald
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
%% @deftypefn {Function File} {@var{g} =} rewrite (@var{f}, @var{how})
%% Rewrite a symbolic expression.
%%
%% Attempts to rewrite an expression @var{f} in terms of functions
%% indicated by the string @var{how}.
%%
%% Examples using trigonometry:
%% @example
%% @group
%% syms x
%% rewrite(exp(x), 'sin')
%%   @result{} ans = (sym) sinh(x) + cosh(x)
%% rewrite(sin(x), 'exp')
%%   @result{} ans = (sym)
%%          ⎛ ⅈ⋅x    -ⅈ⋅x⎞
%%       -ⅈ⋅⎝ℯ    - ℯ    ⎠
%%       ──────────────────
%%               2
%% @end group
%% @end example
%%
%% The argument @var{f} can be a matrix:
%% @example
%% @group
%% rewrite([exp(x) cos(x) asin(x)], 'log')
%%   @result{} ans = (sym 1×3 matrix)
%%       ⎡                  ⎛         __________⎞⎤
%%       ⎢ x                ⎜        ╱    2     ⎟⎥
%%       ⎣ℯ   cos(x)  -ⅈ⋅log⎝ⅈ⋅x + ╲╱  - x  + 1 ⎠⎦
%% @end group
%% @end example
%% (and note that some elements of @var{f} might be unchanged.)
%%
%% Example using integrals:
%% @example
%% @group
%% syms f(t) s
%% G = laplace(f)
%%   @result{} G = (sym) LaplaceTransform(f(t), t, s)
%% rewrite(G, 'Integral')
%%   @result{} ans = (sym)
%%       ∞
%%       ⌠
%%       ⎮       -s⋅t
%%       ⎮ f(t)⋅ℯ     dt
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Further examples:
%% @example
%% @group
%% syms n r
%% rewrite(factorial(n), 'gamma')
%%   @result{} ans = (sym) Γ(n + 1)
%% @end group
%% @group
%% nCr = nchoosek(n, r)
%%   @result{} nCr = (sym)
%%       ⎛n⎞
%%       ⎜ ⎟
%%       ⎝r⎠
%% rewrite(nCr, 'factorial')
%%   @result{} ans = (sym)
%%            n!
%%       ───────────
%%       r!⋅(n - r)!
%% @end group
%% @end example
%%
%% @seealso{simplify, expand, factor}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function F = rewrite(f, how)

  cmd = { '(f, how) = _ins'
          'if f.is_Matrix:'
          '    return f.applyfunc(lambda a: a.rewrite(how)),'
          'else:'
          '    return f.rewrite(how),' };

  F = python_cmd(cmd, sym(f), how);

  % maintainer note: binop_helper would sym(how)

end


%!test
%! syms x
%! assert (isequal (rewrite(x, 'exp'), x))

%!test
%! % empty
%! e = sym([]);
%! assert (isequal (rewrite(e, 'sin'), e))

%!test
%! syms x
%! A = [exp(x) exp(2*x)];
%! B = [sinh(x) + cosh(x)  sinh(2*x) + cosh(2*x)];
%! assert (isequal (rewrite(A, 'sin'), B))
