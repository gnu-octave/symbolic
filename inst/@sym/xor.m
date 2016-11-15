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
%% @defmethod @@sym xor (@var{x}, @var{y})
%% Logical xor of symbolic arrays.
%%
%% Examples:
%% @example
%% @group
%% xor(sym(true), sym(true))
%%   @result{} ans = (sym) False
%% @end group
%%
%% @group
%% syms x y
%% xor (x, y)
%%   @result{} (sym) x ⊻ y
%% @end group
%% @end example
%%
%% @seealso{@@sym/and, @@sym/or, @@sym/not, @@sym/eq, @@sym/ne,
%%          @@sym/logical, @@sym/isAlways}
%% @end defmethod

function r = xor(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  r = elementwise_op ('Xor', sym(x), sym(y));

end


%!shared t, f
%! t = sym(true);
%! f = sym(false);

%!test
%! % simple
%! assert (isequal (xor(t, f), t))
%! assert (isequal (xor(t, t), f))

%!test
%! % array
%! w = [t t f f];
%! z = [t f t f];
%! assert (isequal (xor(w, z), [f t t f]))

%!xtest
%! % output is sym even for scalar t/f
%! % ₣IXME: should match other bool fcns
%! assert (isa (xor(t, f), 'sym'))

%!test
%! % eqns
%! syms x
%! e = xor(x == 4, x == 5);
%! assert (isequal (subs(e, x, [3 4 5 6]), [f t t f]))

%!test
%! % eqns, exclusive
%! syms x
%! e = xor(x == 3, x^2 == 9);
%! assert (isequal (subs(e, x, [-3 0 3]), [t f f]))

%!error xor (sym('x'), 1, 2)
