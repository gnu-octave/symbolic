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
%% @defop  Method   @@sym ge {(@var{a}, @var{b})}
%% @defopx Operator @@sym {@var{a} >= @var{b}} {}
%% Test/define symbolic inequality, greater than or equal to.
%%
%% Examples:
%% @example
%% @group
%% sym(1) >= sym(pi)
%%   @result{} (sym) False
%%
%% syms x
%% x >= 10
%%   @result{} (sym) x ≥ 10
%% @end group
%% @end example
%%
%% @seealso{@@sym/gt, @@sym/lt, @@sym/le, @@sym/eq, @@sym/ne,
%%          @@sym/logical, @@sym/isAlways}
%% @end defop

function t = ge(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  t = ineq_helper('>=', 'Ge', sym(x), sym(y));

end


%!test
%! % simple
%! x = sym(1); y = sym(1); e = x >= y;
%! assert (logical (e))
%! x = sym(1); y = sym(2); e = x >= y;
%! assert (~logical(e))

%!test
%! % array -- array
%! syms x
%! a = sym([1 3 3 2*x]);
%! b = sym([2 x 3 10]);
%! e = a >= b;
%! assert (isa (e, 'sym'))
%! assert (~logical (e(1)))
%! assert (isa (e(2), 'sym'))
%! assert (isequal (e(2), 3 >= x))
%! assert (logical (e(3)))
%! assert (isa (e(4), 'sym'))
%! assert (isequal (e(4), 2*x >= 10))
