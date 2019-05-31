%% Copyright (C) 2015, 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym degree (@var{p})
%% @defmethodx @@sym degree (@var{p}, @var{x})
%% Return the degree of a polynomial expression.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% degree(x^2 + 6)
%%   @result{} (sym) 2
%% @end group
%% @end example
%%
%% You can specify the variable or rely on the @code{symvar} default:
%% @example
%% @group
%% syms x y
%% degree(x^2 + y*x + 1)
%%   @result{} (sym) 2
%% degree(x^2 + y*x + 1, x)
%%   @result{} (sym) 2
%% degree(x^2 + y*x + 1, y)
%%   @result{} (sym) 1
%% @end group
%% @end example
%%
%% FIXME: @code{degree(x^n, x)} does not work here (nor in SMT).
%%
%% @seealso{@@sym/sym2poly, poly2sym}
%% @end defmethod


function n = degree(p, x)

  if (nargin > 2)
    print_usage ();
  end

  if (nargin == 1)
    x = symvar(p, 1);
  end

  if (isempty(x))
    % degree will fail if p is constant and no generator given
    x = sym('x');
  end

  n = pycall_sympy__ ('return sympy.degree(*_ins),', sym(p), sym(x));

end


%!error <Invalid> degree (sym(1), 2, 3)

%!test
%! syms x
%! assert (isequal (degree(x^3), 3))
%! assert (isequal (degree(x^3 + 6), 3))

%!test
%! % specify variable
%! syms x y
%! p = x^2 + y*x + 1;
%! assert (isequal (degree(p), 2))
%! assert (isequal (degree(p, x), 2))
%! assert (isequal (degree(p, y), 1))

%!test
%! syms x a oo
%! assert (isequal (degree(x^3, a), 0))
%! assert (isequal (degree(sym(1), a), 0))
%! assert (isequal (degree(sym(0), a), -oo))

%!xtest
%! % constant inputs
%! syms oo
%! assert (isequal (degree(sym(1)), 0))
%! assert (isequal (degree(sym(0)), -oo))

