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
%% @defmethod  @@sym expint (@var{x})
%% @defmethodx @@sym expint (@var{n}, @var{x})
%% Symbolic generalized exponential integral (expint) function.
%%
%% Integral definition:
%% @example
%% @group
%% syms x
%% E1 = expint(x)
%%   @result{} E1 = (sym) E₁(x)
%% rewrite(E1, 'Integral')            % doctest: +SKIP
%%   @result{} (sym)
%%       ∞
%%       ⌠
%%       ⎮  -t⋅x
%%       ⎮ ℯ
%%       ⎮ ───── dt
%%       ⎮   t
%%       ⌡
%%       1
%% @end group
%% @end example
%%
%% This can also be written (using the substitution @code{u = t⋅x}) as:
%% @example
%% @group
%% @c doctest: +SKIP
%%       ∞
%%       ⌠
%%       ⎮  -u
%%       ⎮ ℯ
%%       ⎮ ─── du
%%       ⎮  u
%%       ⌡
%%       x
%% @end group
%% @end example
%%
%% With two arguments, we have:
%% @example
%% @group
%% E2 = expint(2, x)
%%   @result{} E2 = (sym) E₂(x)
%% @end group
%% @end example
%%
%% In general:
%% @example
%% @group
%% syms n x
%% En = expint(n, x)
%%   @result{} En = (sym) expint(n, x)
%% rewrite(En, 'Integral')            % doctest: +SKIP
%%   @result{} (sym)
%%       ∞
%%       ⌠
%%       ⎮  -n  -t⋅x
%%       ⎮ t  ⋅ℯ     dt
%%       ⌡
%%       1
%% @end group
%% @end example
%%
%% Other example:
%% @example
%% @group
%% diff(En, x)
%%   @result{} (sym) -expint(n - 1, x)
%% @end group
%% @end example
%%
%% @seealso{expint, @@sym/ei}
%% @end defmethod


function y = expint(n, x)

  if (nargin == 1)
    x = n;
    n = 1;
  elseif (nargin == 2)
    % no-op
  else
    print_usage ();
  end

  y = elementwise_op ('expint', sym(n), sym(x));
end


%!test
%! f1 = expint(sym(1));
%! f2 = expint(1);
%! assert( abs(double(f1) - f2) < 1e-15 )

%!test
%! f1 = expint(sym(1i));
%! f2 = expint(1i);
%! assert( abs(double(f1) - f2) < 1e-15 )

%!test
%! D = [1 2; 3 4];
%! A = sym(D);
%! f1 = expint(A);
%! f2 = expint(D);
%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))

%!test
%! syms x
%! A = expint(x);
%! B = expint(1, x);
%! assert (isequal (A, B))

%!test
%! syms x
%! A = exp(-x)/x;
%! B = expint(0, x);
%! assert (isequal (A, B))

%!error <Invalid call> expint(sym(1), 2, 3)

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms x
%! A = expint (3);
%! f = expint (x);
%! h = function_handle (f);
%! B = h (3);
%! assert (A, B, -eps)
%! end

%!error <failed>
%! % round trip
%! syms n x
%! f = expint (n, x);
%! h = function_handle (f);
