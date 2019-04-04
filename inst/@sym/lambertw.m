%% Copyright (C) 2015, 2016, 2018-2019 Colin B. Macdonald
%% Copyright (C) 2019 Mike Miller
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
%% @defmethod  @@sym lambertw (@var{x})
%% @defmethodx @@sym lambertw (@var{k}, @var{x})
%% Symbolic Lambert W function.
%%
%% The Lambert W function is the inverse of @code{W*exp(W)}.  The
%% branch @var{k} defaults to zero if omitted.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% lambertw(x)
%%   @result{} (sym) lambertw(x)
%% lambertw(2, x)
%%   @result{} (sym) lambertw(2, x)
%% @end group
%% @end example
%%
%% Also supports vector/matrix input:
%% @example
%% @group
%% syms x y
%% lambertw([0 1], [x y])
%%   @result{} (sym) [lambertw(x)  lambertw(1, y)]  (1×2 matrix)
%% @end group
%% @end example
%% @seealso{lambertw}
%% @end defmethod


function W = lambertw(k, x)
  if (nargin == 1)
    x = sym(k);
    W = elementwise_op ('LambertW', x);
  elseif (nargin == 2)
    x = sym(x);
    k = sym(k);
    W = elementwise_op ('LambertW', x, k);
  else
    print_usage ();
  end
end


%!test
%! % W(x)*exp(W(x)) == x
%! syms x
%! T = lambertw(x)*exp(lambertw(x));
%! T = double (subs (T, x, 10));
%! assert (isequal (T, 10));

%!test
%! % k, x not x, k to match SMT
%! syms x
%! T = lambertw(2, x)*exp(lambertw(2, x));
%! T = double (subs (T, x, 10));
%! assert (abs(T - 10) < 1e-15)

%!assert (isequal (lambertw(sym(0)), sym(0)))

%!assert ( isequal (lambertw (-1/exp(sym(1))), -sym(1)))
%!assert ( isequal (lambertw (0, -1/exp(sym(1))), -sym(1)))
%!assert ( isequal (lambertw (-1, -1/exp(sym(1))), -sym(1)))

%!xtest
%! % W(x)*exp(W(x)) == x;  FIXME: a failure in SymPy?
%! syms x
%! T = simplify(lambertw(x)*exp(lambertw(x)));
%! assert (isequal (T, x))

% should match @double/lambertw
%!assert (abs (lambertw(pi) - double(lambertw(sym(pi)))) < 5*eps)
%!assert (abs (lambertw(-1, 5) - double(lambertw(-1, sym(5)))) < 5*eps)
%!assert (abs (lambertw(2, 2) - double(lambertw(2, sym(2)))) < 5*eps)

%!test
%! % round trip
%! syms x k
%! A = lambertw (5);
%! f = lambertw (x);
%! h = function_handle (f);
%! B = h (5);
%! assert (A, B)
%!
%! A = lambertw (3, 5);
%! f = lambertw (k, x);
%! h = function_handle (f);
%! B = h (3, 5);
%! assert (A, B)
