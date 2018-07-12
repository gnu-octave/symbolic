%% Copyright (C) 2016, 2018 Colin B. Macdonald
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
%% @defmethod  @@sym polylog (@var{s}, @var{z})
%% Symbolic polylogarithm function.
%%
%% Returns the polylogarithm of order @var{s} and argument @var{z}.
%%
%% Example:
%% @example
%% @group
%% syms z s
%% polylog(s, z)
%%   @result{} ans = (sym) polylog(s, z)
%% diff(ans, z)
%%   @result{} (sym)
%%       polylog(s - 1, z)
%%       ─────────────────
%%               z
%% @end group
%% @end example
%%
%% The polylogarithm satisfies many identities, for example:
%% @example
%% @group
%% syms s positive
%% polylog (s+1, 1)
%%   @result{} (sym) ζ(s + 1)
%% zeta (s+1)
%%   @result{} (sym) ζ(s + 1)
%% @end group
%% @end example
%%
%% @seealso{@@sym/dilog, @@sym/zeta}
%% @end defmethod

function L = polylog(s, z)
  if (nargin ~= 2)
    print_usage ();
  end

  L = elementwise_op ('polylog', sym(s), sym(z));
end


%!assert (isequal (polylog (sym('s'), 0), sym(0)))

%!assert (isequal (double (polylog (1, sym(-1))), -log(2)))

%!assert (isequal (double (polylog (0, sym(2))), -2))
%!assert (isequal (double (polylog (-1, sym(2))), 2))
%!assert (isequal (double (polylog (-2, sym(3))), -1.5))
%!assert (isequal (double (polylog (-3, sym(2))), 26))
%!assert (isequal (double (polylog (-4, sym(3))), -15))

%!assert (isequal (double (polylog (1, sym(1)/2)), log(2)))

%!test
%! % round trip
%! syms s z
%! f = polylog (s, z);
%! h = function_handle (f, 'vars', [s z]);
%! A = h (1.1, 2.2);
%! B = polylog (1.1, 2.2);
%! assert (A, B)
