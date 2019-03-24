%% Copyright (C) 2014-2016, 2018 Colin B. Macdonald
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
%% @defop  Method   @@sym and {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} & @var{y}} {}
%% Logical "and" of symbolic arrays.
%%
%% Examples:
%% @example
%% @group
%% sym(false) & sym(true)
%%   @result{} (sym) False
%%
%% syms x y z
%% x & (y | z)
%%   @result{} (sym) x ∧ (y ∨ z)
%% @end group
%% @end example
%%
%% @seealso{@@sym/or, @@sym/not, @@sym/xor, @@sym/eq, @@sym/ne,
%%          @@sym/logical, @@sym/isAlways, @@sym/isequal}
%% @end defop

function r = and(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  r = elementwise_op ('And', sym(x), sym(y));

end


%!shared t, f
%! t = sym(true);
%! f = sym(false);

%!test
%! % simple
%! assert (isequal (t & f, f))
%! assert (isequal (t & t, t))

%!test
%! % mix wih nonsym
%! assert (isequal (t & false, f))
%! assert (isequal (t & true, t))
%! assert (isequal (t & 0, f))
%! assert (isequal (t & 1, t))
%! assert (isa (t & false, 'sym'))
%! assert (isa (t & 1, 'sym'))

%!test
%! % array
%! w = [t t f f];
%! z = [t f t f];
%! assert (isequal (w & z, [t f f f]))

%!test
%! % number
%! assert (isequal( sym(1) & t, t))
%! assert (isequal( sym(0) & t, f))

%!test
%! % output is sym even for scalar t/f
%! assert (isa (t & f, 'sym'))

%!test
%! % eqns, exclusive
%! syms x
%! e = (x == 3) & (x^2 == 9);
%! assert (isequal (subs(e, x, [-3 0 3]), [f f t]))

%!error and (sym('x'), 2, 3)
