%% Copyright (C) 2014-2016, 2018-2019, 2022, 2024-2025 Colin B. Macdonald
%% Copyright (C) 2022 Chris Gorman
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
%% @defmethod  @@sym heaviside (@var{x})
%% @defmethodx @@sym heaviside (@var{x}, @var{zero_value})
%% Symbolic Heaviside step function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = heaviside (x)
%%   @result{} y = (sym) θ(x)
%% @end group
%% @end example
%%
%% There are various conventions for 'heaviside(sym(0))'; this function
%% returns the midpoint by default on recent enough SymPy:
%% @example
%% @group
%% heaviside(sym(0))
%%   @result{} (sym) 1/2
%% @end group
%% @end example
%%
%% The optional second argument overrides the default.  For example
%% to make the function right-continuous,
%% @example
%% @group
%% heaviside(0, sym(1))
%%   @result{} (sym) 1
%% @end group
%% @end example
%% or left-continuous.
%% @example
%% @group
%% heaviside(0, sym(0))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% If passed a matrix, the heaviside function is computed for each
%% element.
%% @example
%% @group
%% heaviside([sym(-1) sym(0) sym(1) sym(x)])
%%   @result{} (sym) [0  1/2  1  θ(x)]  (1×4 matrix)
%% @end group
%% @end example
%% @seealso{heaviside, @@sym/dirac}
%% @end defmethod


function y = heaviside(x, h0)
  if (nargin == 1)
    y = elementwise_op ('Heaviside', x);
  elseif (nargin == 2)
    y = elementwise_op ('Heaviside', sym(x), sym(h0));
  else
    print_usage ();
  end
end


%!error heaviside (sym(1), 2, 3)

%!assert (isequal (heaviside (sym(1)), sym(1)))
%!assert (isequal (heaviside (-sym(1)), sym(0)))

%!assert (double (heaviside (1)), heaviside (1))

%!test
%! D = [1 -1; -10 20];
%! A = sym(D);
%! assert (double (heaviside (A)), heaviside (D))

%!test
%! H0 = sym([1 -2 0; 3 0 pi]);
%! A = heaviside (sym(0), H0);
%! assert (isequal (A, H0))

%!test
%! A = heaviside ([-1 0 1], sym(1)/2);
%! assert (isequal (A, [0 sym(1)/2 1]))

%!test
%! A = heaviside ([-1 0 1], sym(1)/2);
%! assert (isequal (A, [0 sym(1)/2 1]))

%!assert (isequaln (heaviside (sym(nan)), sym(nan)))

%!test
%! assert (isequaln (heaviside (sym(nan), sym(nan)), sym(nan)))
%! assert (isequaln (heaviside (0, sym(nan)), sym(nan)))
%! assert (isequaln (heaviside (2, sym(nan)), sym(1)))
%! assert (isequaln (heaviside (-2, sym(nan)), sym(0)))

%!test
%! % round trip
%! syms x
%! A = heaviside (1);
%! f = heaviside (x);
%! h = function_handle (f);
%! B = h (1);
%! assert (A, B, -eps)

%!test
%! % round trip
%! syms x h0
%! f = heaviside (x, h0);
%! h = function_handle (f, 'vars', {x h0});
%! A = heaviside (1, 1/2);
%! B = h (1, 1/2);
%! assert (A, B, -eps)
%! A = heaviside (0, 1/2);
%! B = h (0, 1/2);
%! assert (A, B, -eps)
