%% Copyright (C) 2016, 2019 Colin Macdonald
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
%% @defmethod @@sym rewrite (@var{f}, @var{how})
%% Rewrite a symbolic expression.
%%
%% Attempts to rewrite an expression @var{f} in terms of functions
%% indicated by the @emph{case-sensitive} string @var{how}.
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
%% Often @code{sincos} is more useful than @code{sin} or @code{cos}:
%% @example
%% @group
%% rewrite(tan(x), 'sin')
%%   @result{} (sym)
%%            2
%%       2⋅sin (x)
%%       ─────────
%%        sin(2⋅x)
%% rewrite(tan(x), 'sincos')
%%   @result{} (sym)
%%       sin(x)
%%       ──────
%%       cos(x)
%% @end group
%% @end example
%%
%% The argument @var{f} can be a matrix:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% rewrite([exp(x) cos(x) asin(x)], 'log')
%%   @result{} ans = (sym 1×3 matrix)
%%       ⎡                  ⎛         ________⎞⎤
%%       ⎢ x                ⎜        ╱      2 ⎟⎥
%%       ⎣ℯ   cos(x)  -ⅈ⋅log⎝ⅈ⋅x + ╲╱  1 - x  ⎠⎦
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
%% @strong{Note} the case-sensitivity of @var{how}:
%% use @code{Integral} not @code{integral}.
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
%% @seealso{@@sym/simplify, @@sym/expand, @@sym/factor}
%% @end defmethod

function F = rewrite(f, how)

  if (nargin ~= 2)
    print_usage ();
  end

  F = elementwise_op ('lambda f, how: f.rewrite(how)', sym(f), how);

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
