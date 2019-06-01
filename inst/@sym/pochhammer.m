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
%% @defmethod @@sym pochhammer (@var{x}, @var{n})
%% Rising Factorial or Pochhammer symbol.
%%
%% Example:
%% @example
%% @group
%% syms x n
%% pochhammer (x, n)
%%   @result{} (sym) RisingFactorial(x, n)
%% @end group
%% @end example
%%
%% The Pochhammer symbol can be defined in terms of the Gamma
%% function:
%% @example
%% @group
%% rewrite (pochhammer (x, n), 'gamma')
%%   @result{} (sym)
%%
%%       Γ(n + x)
%%       ────────
%%         Γ(x)
%% @end group
%% @end example
%%
%%
%% For positive integer @var{n}, the result has a simple form:
%% @example
%% @group
%% pochhammer (x, 4)
%%   @result{} (sym) x⋅(x + 1)⋅(x + 2)⋅(x + 3)
%% @end group
%% @end example
%%
%% @seealso{@@sym/gamma, @@double/pochhammer}
%% @end defmethod

function I = pochhammer(x, n)

  if (nargin ~= 2)
    print_usage ();
  end

  I = elementwise_op ('RisingFactorial', sym(x), sym(n));

end


%!error <Invalid> pochhammer (sym(1))
%!error <Invalid> pochhammer (sym(1), 2, 3)

%!assert (isequal (pochhammer (sym(3), 4), sym(360)))
%!assert (isequal (pochhammer (sym([2 3]), 3), sym([24 60])))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms n z
%! f = pochhammer (z, n);
%! h = function_handle (f, 'vars', [z n]);
%! A = h (1.1, 2.2);
%! B = pochhammer (1.1, 2.2);
%! assert (A, B)
%! end
