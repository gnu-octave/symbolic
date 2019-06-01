%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym horner (@var{p})
%% @defmethodx @@sym horner (@var{p}, @var{x})
%% Convert a symbolic polynomial to Horner form.
%%
%% The Horner form minimizes the number of arthimetic operators to
%% evaluate the polynomial.
%%
%% Example:
%% @example
%% @group
%% syms x
%% p = poly2sym ([2 4 6 8], x)
%%   @result{} p = (sym)
%%          3      2
%%       2⋅x  + 4⋅x  + 6⋅x + 8
%% horner (p)
%%   @result{} ans = (sym) x⋅(x⋅(2⋅x + 4) + 6) + 8
%% @end group
%% @end example
%%
%% You can specify the variable as a second input:
%% @example
%% @group
%% syms x a
%% p = expand((a+2)*(2*a+x)*(3*a+7));
%% horner(p, a)
%%   @result{} ans = (sym) a⋅(a⋅(6⋅a + 3⋅x + 26) + 13⋅x + 28) + 14⋅x
%% @end group
%% @end example
%%
%% @seealso{poly2sym}
%% @end defmethod


function y = horner(p, x)

  if (nargin > 2)
    print_usage ();
  end

  if (nargin == 1)
    x = symvar(p, 1);
  end

  if (isempty(x))
    y = pycall_sympy__ ('return sp.horner(*_ins),', sym(p));
  else
    y = pycall_sympy__ ('return sp.horner(*_ins),', sym(p), sym(x));
  end

end


%!error <Invalid> horner (sym(1), 2, 3)

%!assert (isAlways (horner(sym(1)) == 1))

%!test
%! syms x
%! assert (isAlways (horner(x) == x))

%!test
%! syms x a
%! p = a^2 + a*x + 2*a + 2*x;
%! assert (isequal (horner (p, a), a*(a+x+2) + 2*x))
%! q = a^2 + 2*a + x*(a + 2);
%! assert (isequal (horner (p, x), q))
%! assert (isequal (horner (p), q))

%!test
%! syms x
%! p = poly2sym ([2 4 6 8], x);
%! q = horner (p);
%! assert (isAlways (p == q))
%! assert (isAlways (horner(2*x^3 + 4*x^2 + 6*x + 8) == q))

%!test
%! % non-sym input
%! syms x
%! assert (isequal (horner(6, x), sym(6)))
