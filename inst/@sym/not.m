%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defop  Method   @@sym not {(@var{x})}
%% @defopx Operator @@sym {~@var{x}} {}
%% @defopx Operator @@sym {!@var{x}} {}
%% Logical "not" of a symbolic array.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% eqn = 2*x == y
%%   @result{} eqn = (sym) 2⋅x = y
%% not(eqn)
%%   @result{} ans = (sym) 2⋅x ≠ y
%% @end group
%% @end example
%%
%% More briefly:
%% @example
%% @group
%% ~(x==y)
%%   @result{} ans = (sym) x ≠ y
%% !(x==y)
%%   @result{} ans = (sym) x ≠ y
%% @end group
%% @end example
%%
%% Applies to each entry of a matrix:
%% @example
%% @group
%% A = [x < y, 2*x + y >= 0, true]
%%   @result{} A = (sym) [x < y  2⋅x + y ≥ 0  True]  (1×3 matrix)
%% ~A
%%   @result{} ans = (sym) [x ≥ y  2⋅x + y < 0  False]  (1×3 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/eq, @@sym/ne, @@sym/logical, @@sym/isAlways}
%% @end defop

function r = not(x)

  if (nargin ~= 1)
    print_usage ();
  end

  r = elementwise_op ('Not', x);

end


%!shared t, f
%! t = sym(true);
%! f = sym(false);

%!test
%! % simple
%! assert (isequal( ~t, f))
%! assert (isequal( ~t, f))

%!test
%! % array
%! w = [t t f t];
%! z = [f f t f];
%! assert (isequal( ~w, z))

%!test
%! % number
%! assert (isequal( ~sym(5), f))
%! assert (isequal( ~sym(0), t))

%!test
%! % output is sym
%! syms x
%! e = ~(x == 4);
%! assert (isa (e, 'sym'))
%! assert (strncmp (sympy(e), 'Unequality', 10))

%!test
%! % output is sym even for scalar t/f (should match other bool fcns)
%! assert (isa (~t, 'sym'))

%!test
%! % symbol ineq
%! syms x
%! a = [t  f  x == 1  x ~= 2  x < 3   x <= 4  x > 5   x >= 6];
%! b = [f  t  x ~= 1  x == 2  x >= 3  x > 4   x <= 5  x < 6];
%! assert (isequal( ~a, b))

%!test
%! syms x
%! y = ~x;
%! s = disp(y, 'flat');
%! assert (strcmp (strtrim (s), '~x') || strcmpi (strtrim (s), 'Not(x)'))

%!error not (sym(1), 2)
