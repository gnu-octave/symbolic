%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym igamma (@var{nu}, @var{x})
%% Symbolic upper incomplete gamma function.
%%
%% Example:
%% @example
%% @group
%% syms x nu
%% igamma (nu, x)
%%   @result{} (sym) Γ(ν, x)
%% @end group
%% @end example
%%
%% @strong{Note} the order of inputs and scaling is different from
%% @ref{@@sym/gammainc}, specifically:
%% @example
%% @group
%% igamma (nu, x)
%%   @result{} (sym) Γ(ν, x)
%% gammainc (x, nu, 'upper')
%%   @result{} (sym)
%%       Γ(ν, x)
%%       ───────
%%         Γ(ν)
%% @end group
%% @end example
%%
%% @seealso{@@sym/gammainc, @@sym/gamma}
%% @end defmethod

function y = igamma(a, z)
  if (nargin ~= 2)
    print_usage ();
  end

  y = elementwise_op ('uppergamma', sym(a), sym(z));
end


%!test
%! % mostly tested in @sym/gammainc
%! syms x
%! assert (isequal (igamma (2, x), gammainc(x, 2, 'upper')))

%!test
%! % unregularized
%! B = double (igamma (sym(3), 1));
%! A = gammainc (1, 3, 'upper')*gamma (3);
%! assert (A, B, -2*eps)

%!test
%! % something like a round trip: no igamma(<double>)
%! syms x a
%! f = igamma (a, x);
%! h = function_handle (f, 'vars', [a x]);
%! A = h (1.1, 2.2);
%! B = double (igamma (sym(11)/10, sym(22)/10));
%! C = gammainc (2.2, 1.1, 'upper')*gamma(1.1);
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%! assert (A, B, -10*eps)
%! assert (A, C, -10*eps)
%! end
