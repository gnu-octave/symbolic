%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym signIm (@var{z})
%% Return the sign of the imaginary part of a complex expression.
%%
%% Examples:
%% @example
%% @group
%% signIm (sym(3) + 2i)
%%   @result{} (sym) 1
%% signIm (3 - 1i*sym(pi))
%%   @result{} (sym) -1
%% signIm (sym(3))
%%   @result{} (sym) 0
%% @end group
%%
%% @group
%% syms x y real
%% signIm (x)
%%   @result{} (sym) 0
%% signIm (x + 1i*y)
%%   @result{} (sym) sign(y)
%% @end group
%% @end example
%%
%% @seealso{@@sym/imag, @@sym/sign}
%% @end defmethod

function y = signIm(z)
  if (nargin ~= 1)
    print_usage ();
  end
  y = sign (imag (z));
end


%!assert (isequal (signIm (sym(1)), sym(0)))
%!assert (isequal (signIm (sym(1) + 2i), sym(1)))
%!assert (isequal (signIm (sym(1) - 2i), sym(-1)))

%!test
%! % intermediate A looks bit weird, but it works
%! syms z
%! A = signIm (z);
%! assert (isequal (subs(A, z, 3+sym(4i)), sym(1)))
%! assert (isequal (subs(A, z, 3-sym(4i)), sym(-1)))

%!test
%! % really a @sym/sign test, but that one is autogen
%! z = 3 + sym(4i);
%! A = sign (z);
%! B = z / abs(z);
%! assert (double (A), double (B), eps)
