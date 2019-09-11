%% Copyright (C) 2017-2019 Colin B. Macdonald
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
%% @defmethod @@sym harmonic (@var{x})
%% Symbolic harmonic function.
%%
%% For integers, the harmonic function can be defined as:
%% @example
%% @group
%% syms n integer
%% y = harmonic (n)
%%   @result{} y = (sym) harmonic(n)
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% rewrite (y, 'Sum')
%%   @result{} (sym)
%%
%%         n
%%        ____
%%        ╲
%%         ╲
%%          ╲  1
%%          ╱  ─
%%         ╱   k
%%        ╱
%%        ‾‾‾‾
%%       k = 1
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% harmonic (sym(1:7))
%%   @result{} (sym 1×7 matrix)
%%
%%       ⎡              25  137  49  363⎤
%%       ⎢1  3/2  11/6  ──  ───  ──  ───⎥
%%       ⎣              12   60  20  140⎦
%% @end group
%%
%% @group
%% harmonic (sym(120))
%%   @result{} ans = (sym)
%%
%%       18661952910524692834612799443020757786224277983797
%%       ──────────────────────────────────────────────────
%%       3475956553913558034594585593659201286533187398464
%%
%% double (ans)
%%   @result{} ans = 5.3689
%% @end group
%% @end example
%%
%%
%% It is also defined for non-integers, for example:
%% @example
%% @group
%% y = harmonic (sym(1)/3)
%%   @result{} y = (sym) harmonic(1/3)
%% vpa (y)
%%   @result{} (sym) 0.44518188488072653761009301579513
%% @end group
%%
%% @group
%% y = harmonic (sym(i))
%%   @result{} y = (sym) harmonic(ⅈ)
%% vpa (y)
%%   @result{} (sym) 0.67186598552400983787839057280431 +
%%           1.07667404746858117413405079475⋅ⅈ
%% @end group
%% @end example
%%
%% An example establishing an identity:
%% @example
%% @group
%% syms x
%% A = psi (x) + eulergamma ()
%%   @result{} A = (sym) polygamma(0, x) + γ
%% rewrite (A, 'harmonic')
%%   @result{} ans = (sym) harmonic(x - 1)
%% @end group
%% @end example
%%
%% @seealso{bernoulli}
%% @end defmethod


function y = harmonic(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('harmonic', x);
end


%!error <Invalid> harmonic (sym(1), 2)

%!xtest
%! assert (isequaln (harmonic (sym(nan)), sym(nan)))

%!assert (isequal (harmonic (sym(0)), sym(0)))
%!assert (isinf (harmonic (sym(inf))))
%!assert (isequal (harmonic (sym([9 10])), [sym(7129)/2520 sym(7381)/2520]))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! y = sym('y');
%! A = harmonic (7);
%! f = harmonic (y);
%! h = function_handle (f);
%! B = h (7);
%! assert (A, B, -eps)
%! end
