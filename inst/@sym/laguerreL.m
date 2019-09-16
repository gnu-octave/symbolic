%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@sym laguerreL (@var{n}, @var{x})
%% @defmethodx @@sym laguerreL (@var{n}, @var{alpha}, @var{x})
%% Symbolic Laguerre polynomials and associated Laguerre polynomials.
%%
%% Example:
%% @example
%% @group
%% syms x n
%% laguerreL(5, x)
%%   @result{} ans = (sym)
%%           5      4      3
%%          x    5⋅x    5⋅x       2
%%       - ─── + ──── - ──── + 5⋅x  - 5⋅x + 1
%%         120    24     3
%% laguerreL(n, x)
%%   @result{} ans = (sym) laguerre(n, x)
%% @end group
%% @end example
%%
%% When @var{alpha} is nonzero, we get generalized (associated) Laguerre
%% polynomials:
%% @example
%% @group
%% laguerreL(n, 1, x)
%%   @result{} ans = (sym) assoc_laguerre(n, 1, x)
%% @end group
%% @end example
%%
%% The polynomials can be manipulated symbolically, for example:
%% @example
%% @group
%% L = laguerreL(n, x);
%% diff(L, x)
%%   @result{} ans = (sym) -assoc_laguerre(n - 1, 1, x)
%% @end group
%% @end example
%%
%% Laguerre @emph{Functions} have non-positive integer @var{N},
%% such as
%% @example
%% @group
%% syms x
%% N = -3;
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% y = laguerreL(N, x)
%%   @result{} y = (sym)
%%       ⎛ 2          ⎞
%%       ⎜x           ⎟  x
%%       ⎜── + 2⋅x + 1⎟⋅ℯ
%%       ⎝2           ⎠
%% @end group
%% @end example
%% These satisfy Laguerre's differential equation:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% x*diff(y, x, x) + (1 - x)*diff(y, x) + N*y == 0
%%   @result{} (sym) ...
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% simplify(ans)
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% Note: the Generalized Laguerre @emph{Function} is not implemented.
%%
%% @seealso{laguerreL, @@sym/chebychevT, @@sym/chebychevU}
%% @end defmethod

function L = laguerreL(n, alpha, x)

  if (nargin == 2)
    x = alpha;
    L = elementwise_op ('laguerre', sym(n), sym(x));
  elseif (nargin == 3)
    L = elementwise_op ('assoc_laguerre', sym(n), sym(alpha), sym(x));
  else
    print_usage ();
  end

end


%!shared x
%! syms x

%!assert (isequal (laguerreL(0, x), sym(1)))
%!assert (isequal (laguerreL(1, x), 1-x))
%!assert (isequal (laguerreL(2, x), x^2/2 - 2*x + 1))

%!error laguerreL(x)
%!error laguerreL(1, 2, x, 3)

%!shared

%!test
%! if (pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%! syms x
%! assert (isequal (laguerreL (-3, x), exp(x)*(x^2/2 + 2*x + 1)))
%! end

%!test
%! syms x n
%! L = laguerreL([2 n], x);
%! expected = [laguerreL(2, x)  laguerreL(n, x)];
%! assert (isequal (L, expected))

%!test
%! syms x y
%! L = laguerreL([1; 2], [x; y]);
%! expected = [laguerreL(1, x);  laguerreL(2, y)];
%! assert (isequal (L, expected))

%!test
%! syms x n
%! assert (isequal (laguerreL(n, 0, x), laguerreL(n, x)))

%!shared x, y, n
%! syms x y n

%!assert (isequal (laguerreL([1 n], 0, x), laguerreL([1 n], x)))

%!test
%! L = laguerreL([1; n], [pi; 0], [x; y]);
%! expected = [laguerreL(1, pi, x);  laguerreL(n, 0, y)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL([1 n], [pi 0], x);
%! expected = [laguerreL(1, pi, x)  laguerreL(n, 0, x)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL([1 n], pi, [x y]);
%! expected = [laguerreL(1, pi, x)  laguerreL(n, pi, y)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL(1, [pi 0], [x y]);
%! expected = [laguerreL(1, pi, x)  laguerreL(1, 0, y)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL([1 n], pi, x);
%! expected = [laguerreL(1, pi, x)  laguerreL(n, pi, x)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL(1, [pi 0], x);
%! expected = [laguerreL(1, pi, x)  laguerreL(1, 0, x)];
%! assert (isequal (L, expected))

%!test
%! L = laguerreL(1, pi, [x y]);
%! expected = [laguerreL(1, pi, x)  laguerreL(1, pi, y)];
%! assert (isequal (L, expected))

%!test
%! % round trip
%! f = laguerreL (n, x);
%! h = function_handle (f);
%! A = h (1, 3.2);
%! B = laguerreL (1, 3.2);
%! assert (A, B)
%! A = h ([1 2], [3.3 4.4]);
%! B = laguerreL ([1 2], [3.3 4.4]);
%! assert (A, B)

%!error <codegen failed>
%! % round trip
%! f = laguerreL (n, y, x);
%! h = function_handle (f);
