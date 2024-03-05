%% Copyright (C) 2016-2022, 2024 Colin B. Macdonald
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
%% @defmethod @@sym sinint (@var{x})
%% Symbolic sine integral function.
%%
%% The sine integral function can be created with:
%% @example
%% @group
%% syms x
%% y = sinint (x)
%%   @result{} y = (sym) Si(x)
%% @end group
%% @end example
%%
%% It is an antiderivative of @code{sin(x)/x}:
%% @example
%% @group
%% diff (y, x)
%%   @result{} (sym)
%%       sin(x)
%%       ──────
%%         x
%% @end group
%% @end example
%%
%% Specifically, the sine integral function is:
%% @example
%% @group
%% syms t
%% int (sin (t)/t, t, 0, x)
%%   @result{} (sym) Si(x)
%% @end group
%% @end example
%%
%% This can instead be written in terms of the @code{sinc}
%% function (@pxref{@@sym/sinc}) where:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.12.1")'))
%% rewrite (y, 'Integral')
%%   @result{} (sym)
%%       x
%%       ⌠
%%       ⎮     ⎛t⎞
%%       ⎮ sinc⎜─⎟ dt
%%       ⎮     ⎝π⎠
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% @seealso{@@sym/cosint, @@sym/sinc}
%% @end defmethod


function y = sinint(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('Si', x);
end


%!error sinint (sym(1), 2)
%!xtest
%! assert (isequaln (sinint (sym(nan)), sym(nan)))

%!shared x, d
%! d = 1;
%! x = sym('1');

%!test
%! f1 = sinint(x);
%! f2 = 0.9460830703671830149414;
%! assert( abs(double(f1) - f2) < 1e-15 )

%!test
%! D = [d d; d d];
%! A = [x x; x x];
%! f1 = sinint(A);
%! f2 = 0.9460830703671830149414;
%! f2 = [f2 f2; f2 f2];
%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))

%!test
%! % round trip
%! y = sym('y');
%! A = sinint (d);
%! f = sinint (y);
%! h = function_handle (f);
%! B = h (d);
%! assert (A, B, -eps)

%!test
%! % rewrite
%! syms x
%! y1 = sinint (x);
%! y2 = rewrite (y1, 'Integral');
%! d1 = diff (y1, x);
%! d2 = diff (y2, x);
%! v1 = double (subs (d1, x, 2));
%! v2 = double (subs (d2, x, 2));
%! assert (v1, v2, -eps)
