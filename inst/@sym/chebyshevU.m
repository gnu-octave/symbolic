%% Copyright (C) 2016 Abhinav Tripathi
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
%% @defmethod @@sym chebyshevU (@var{n}, @var{x})
%% Find the nth symbolic Chebyshev polynomial of the second kind.
%%
%% If @var{n} is a vector then it returns a vector with Chebyshev polynomials
%% of the second kind for each element of @var{n}.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% chebyshevU(1, x)
%%   @result{} (sym) 2⋅x
%% chebyshevU(2, x)
%%   @result{} (sym)
%%          2
%%       4⋅x  - 1
%% syms n
%% chebyshevU(n, x)
%%   @result{} (sym) chebyshevu(n, x)
%% @end group
%% @end example
%%
%% The inputs can be vectors, for example:
%% @example
%% @group
%% syms x
%% chebyshevU([0 1 2], x)
%%   @result{} (sym 1×3 matrix)
%%       ⎡           2    ⎤
%%       ⎣1  2⋅x  4⋅x  - 1⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/chebyshevT, @@double/chebyshevU}
%% @end defmethod


function y = chebyshevU(n, x)
  if (nargin ~= 2)
    print_usage ();
  end
  y = elementwise_op ('chebyshevu', sym(n), sym(x));
end


%!error <Invalid> chebyshevU (sym(1))
%!error <Invalid> chebyshevU (sym(1), 2, 3)

%!assert (isequaln (chebyshevU (2, sym(nan)), sym(nan)))

%!shared x
%! syms x

%!assert(isequal(chebyshevU(0, x), sym(1)))
%!assert(isequal(chebyshevU(1, x), 2*x))
%!assert(isequal(chebyshevU(2, x), 4*x*x - 1))
%!assert(isequal(chebyshevU([0 1 2], x), [sym(1) 2*x (4*x*x-1)]))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms n z
%! f = chebyshevU (n, z);
%! h = function_handle (f, 'vars', [n z]);
%! A = h (1.1, 2.2);
%! B = chebyshevU (1.1, 2.2);
%! assert (A, B)
%! end
