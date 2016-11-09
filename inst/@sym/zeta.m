%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym zeta (@var{n})
%% @defmethodx @@sym zeta (@var{z}, @var{n})
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
%% With 2 arguments you get the @var{z} derivative
%% of the zeta function evaluated in @var{n}:
%%
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
%% @end defmethod


function y = zeta(z, n)
  if (nargin > 2)
    print_usage ();
  end

  if (nargin == 1)
      n = z;
      z = 0;
  end

  cmd = {'def _op(a, b):'
         '    x = Symbol("x")'
         '    return Derivative(zeta(x), x, a).subs(x, b)'};

  y = elementwise_op (cmd, sym (z), sym (n));

end


%!error <Invalid> zeta (sym(1), 2, 3)
%!assert (isequaln (zeta (sym(nan)), sym(nan)))

%!shared x, d
%! d = 2;
%! x = sym('2');

%!test
%! f1 = zeta(x);
%! f2 = pi^2/6;
%! assert( abs(double(f1) - f2) < 1e-15 )

%!test
%! D = [d d; d d];
%! A = [x x; x x];
%! f1 = zeta(A);
%! f2 = pi^2/6;
%! f2 = [f2 f2; f2 f2];
%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))

%!test
%! % round trip
%! if (python_cmd ('return Version(spver) > Version("1.0")'))
%! y = sym('y');
%! A = zeta (d);
%! f = zeta (y);
%! h = function_handle (f);
%! B = h (d);
%! assert (A, B, -eps)
%! end

%!xtest
%! %% https://github.com/sympy/sympy/issues/11802
%! assert (double (zeta (sym (3), 4)), -0.07264084989132137196244616781177, 10e-33)

%!test
%! syms x
%! assert (isequal (zeta (0, x), zeta(x)))
