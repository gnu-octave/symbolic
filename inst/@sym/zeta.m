%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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
%% @defmethod  @@sym zeta (@var{x})
%% @defmethodx @@sym zeta (@var{n}, @var{z})
%% Symbolic zeta function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = zeta (x)
%%   @result{} y = (sym) ζ(x)
%% @end group
%% @end example
%%
%% With 2 arguments you get the @var{n}th derivative
%% of the zeta function evaluated in @var{x}:
%% @example
%% @group
%% syms x
%% y = zeta (4, x)
%%   @result{} y = (sym)
%%         4
%%        d
%%       ───(ζ(x))
%%         4
%%       dx
%% @end group
%% @end example
%%
%% @seealso{@@double/zeta}
%% @end defmethod


function y = zeta(n, z)
  if (nargin > 2)
    print_usage ();
  end

  if (nargin == 1)
    z = n;
    y = elementwise_op ('zeta', sym (z));
    return
  end

  %% I don't think upstream sympy has a form for the derivatives
  % (mpmath does, we'll use that directly in @double/zeta)
  cmd = {'def _op(a, n):'
         '    z = Dummy("z")'
         '    return Derivative(zeta(z), (z, n)).subs(z, a)'};

  y = elementwise_op (cmd, sym (z), sym (n));

end


%!error <Invalid> zeta (sym(1), 2, 3)
%!assert (isequaln (zeta (sym(nan)), sym(nan)))

%!test
%! f1 = zeta (sym(2));
%! f2 = pi^2/6;
%! assert (double (f1), f2, -1e-15)

%!test
%! A = sym([0 2; 4 6]);
%! f1 = zeta (A);
%! f2 = [-1/2 pi^2/6; pi^4/90 pi^6/945];
%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))

%!test
%! % round trip
%! y = sym('y');
%! f = zeta (y);
%! h = function_handle (f);
%! A = zeta (2);
%! B = h (2);
%! assert (A, B, -eps)

%%!xtest
%%! % Disabled: causes stack overflows and crashes Python in Fedora 30
%%! % https://github.com/sympy/sympy/issues/11802
%%! assert (double (zeta (sym (3), 4)), -0.07264084989132137196, -1e-14)

%!test
%! syms x
%! assert (isequal (zeta (0, x), zeta(x)))

%!test
%! % ensure its the nth deriv wrt x, not the n deriv
%! syms x n
%! F = zeta (n, x);
%! F = subs(F, n, 3);
%! assert (isequal (F, diff (zeta (x), x, x, x)))
