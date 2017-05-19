%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defop  Method   @@sym lt {(@var{a}, @var{b})}
%% @defopx Operator @@sym {@var{a} < @var{b}} {}
%% Test/define symbolic inequality, less than.
%%
%% Examples:
%% @example
%% @group
%% sym(1) < sym(pi)
%%   @result{} (sym) True
%%
%% syms x real
%% x < 10
%%   @result{} (sym) x < 10
%% @end group
%% @end example
%%
%%
%% Note that having symbols in the expressions for @var{a}
%% or @var{b} does not necessarily give an inequation:
%% @example
%% @group
%% x < x + 2
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% Assumptions can also play a role:
%% @example
%% @group
%% syms x real
%% x^2 < 0
%%   @result{} (sym) False
%%
%% syms n negative
%% syms p positive
%%   n < p
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% @seealso{@@sym/le, @@sym/gt, @@sym/ge, @@sym/eq, @@sym/ne,
%%          @@sym/logical, @@sym/isAlways}
%% @end defop

function t = lt(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  t = ineq_helper('<', 'Lt', sym(x), sym(y));

end


%% Note:
% in general, put tests in lt unless they are specific to
% another inequality.

%!test
%! % simple
%! x = sym(1); y = sym(1); e = x < y;
%! assert (~logical (e))
%! x = sym(1); y = sym(2); e = x < y;
%! assert (logical (e))

%!test
%! % mix sym and double
%! x = sym(1); y = 1; e = x < y;
%! assert (~logical (e))
%! x = sym(1); y = 2; e = x < y;
%! assert (logical (e))
%! x = 1; y = sym(1); e = x < y;
%! assert (~logical (e))
%! x = 1; y = sym(2); e = x < y;
%! assert (logical (e))

%!test
%! % Type of the output is sym or logical?
%! % FIXME: in current version, they are sym
%! x = sym(1); y = sym(1); e1 = x < y;
%! x = sym(1); y = sym(2); e2 = x < y;
%! %assert (islogical (e1))
%! %assert (islogical (e2))
%! assert (isa (e1, 'sym'))
%! assert (isa (e2, 'sym'))

%!test
%! % ineq w/ symbols
%! syms x y
%! e = x < y;
%! assert (~islogical (e))
%! assert (isa (e, 'sym'))

%!test
%! % array -- array
%! syms x
%! a = sym([1 3 3 2*x]);
%! b = sym([2 x 3 10]);
%! e = a < b;
%! assert (isa (e, 'sym'))
%! assert (logical (e(1)))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), 3 < x))
%! assert (~logical (e(3)))
%! assert (isa (e(4), 'sym'))
%! assert (isequal (e(4), 2*x < 10))

%!test
%! % array -- scalar
%! syms x oo
%! a = sym([1 x oo]);
%! b = sym(3);
%! e = a < b;
%! assert (isa (e, 'sym'))
%! assert (logical (e(1)))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), x < 3))
%! assert (~logical (e(3)))

%!test
%! % scalar -- array
%! syms x oo
%! a = sym(1);
%! b = sym([2 x -oo]);
%! e = a < b;
%! assert (isa (e, 'sym'))
%! assert (logical (e(1)))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), 1 < x))
%! assert (~logical (e(3)))

%!test
%! % ineq w/ nan
%! syms x
%! snan = sym(nan);
%! e = x < snan;
%! assert (~logical (e))
%! e = snan < x;
%! assert (~logical (e))
%! b = [sym(0) x];
%! e = b < snan;
%! assert (isequal (e, [false false]))

%!test
%! % oo
%! syms oo x
%! e = oo < x;
%! assert (isa (e, 'sym'))
%! assert (strcmp (strtrim (disp (e, 'flat')), 'oo < x'))

%!test
%! % sympy true matrix
%! a = sym([1 3 3]);
%! b = sym([2 4 1]);
%! e = a < b;
%! %assert (~isa (e, 'sym'))
%! %assert (islogical (e))
%! assert (isequal (e, [true true false]))

%!test
%! % oo, finite real variables
%! syms oo
%! syms z real
%! assumeAlso(z, 'finite')
%! e = -oo < z;
%! assert (isequal (e, sym(true)))
%! e = z < oo;
%! assert (isequal (e, sym(true)))

%!test
%! % -oo, positive var (known failure w/ sympy 0.7.6.x)
%! syms oo
%! syms z positive
%! e = -oo < z;
%! assert (logical (e))
%! assert (isequal (e, sym(true)))

%!test
%! % positive
%! syms z positive
%! e = -1 < z;
%! assert (isequal (e, sym(true)))

%!test
%! syms oo
%! z = sym('z', 'negative');
%! e = z < oo;
%! assert (isequal (e, sym(true)))
