%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym sinc (@var{x})
%% Symbolic normalized sinc function.
%%
%% The normalized sinc function is defined by
%% @example
%% @group
%% syms x
%% rewrite (sinc (x), 'sin')
%%   @result{} (sym)
%%       ⎧sin(π⋅x)
%%       ⎪────────  for π⋅x ≠ 0
%%       ⎨  π⋅x
%%       ⎪
%%       ⎩   1       otherwise
%% @end group
%% @end example
%%
%% Caution, the notation @code{sinc} is also commonly used to represent
%% the unnormalized sinc function
%% @iftex
%% @math{\frac{\sin(x)}{x}}.
%% @end iftex
%% @ifnottex
%% @code{sin(x)/x}.
%% @end ifnottex
%%
%% Further examples:
%% @example
%% @group
%% rewrite (sin (x)/x, 'sinc')
%%   @result{} ans = (sym)
%%            ⎛x⎞
%%        sinc⎜─⎟
%%            ⎝π⎠
%% @end group
%%
%% @group
%% rewrite (sin (pi*x)/(pi*x), 'sinc')
%%   @result{} ans = (sym) sinc(x)
%% @end group
%%
%% @group
%% syms x nonzero
%% diff (sinc (x))
%%   @result{} ans = (sym)
%%        π⋅x⋅cos(π⋅x) - sin(π⋅x)
%%        ───────────────────────
%%                     2
%%                  π⋅x
%% @end group
%% @end example
%%
%% @seealso{sinc}
%% @end defmethod


function y = sinc(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('sinc', pi*x);
end


%!error <Invalid> sinc (sym(1), 2)
%!assert (isequaln (sinc (sym(nan)), sym(nan)))

%!assert (isequal (sinc (sym(0)), sym(1)))
%!assert (isequal (sinc (sym(1)), sym(0)))
%!assert (isequal (sinc (-sym(1)), sym(0)))

%!assert (double (sinc (sym(pi))), sinc (pi), -10*eps)

%!test
%! A = [-sym(1)/2 sym(1)/2 pi; -sym(7)/2 sym(71)/2 sym(101)/3];
%! D = double (A);
%! assert (sinc (D), double (sinc (A)), -200*eps)

%!test
%! A = [sym(51)/2 sym(1001)/3 sym(10001)/3 sym(100001)/3];
%! D = double (A);
%! assert (sinc (D), double (sinc (A)), 1e-10)

%!test
%! % round trip
%! syms x
%! A = sinc (1);
%! f = sinc (x);
%! h = function_handle (f);
%! B = h (1);
%! assert (A, B, -eps)

%!test
%! % round trip
%! syms x
%! f = sinc (x);
%! h = function_handle (f);
%! A = sinc (1.5);
%! B = h (1.5);
%! assert (A, B, -eps)

%!test
%! syms x
%! h = function_handle (sinc (x));
%! A = double (sinc (sym (12)/10));
%! B = h (1.2);
%! C = sinc (1.2);
%! assert (A, B, -eps)
%! assert (A, C, -eps)
