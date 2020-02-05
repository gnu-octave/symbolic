%% Copyright (C) 2016 Utkarsh Gautam
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
%% @defmethod @@sym besselyn (@var{alpha}, @var{x})
%% Symbolic Spherical Bessel function of the second kind.
%%
%% Example:
%% @example
%% @group
%% syms n x
%% A = besselyn(n, x)
%%   @result{} A = (sym) yn(n, x)
%% diff(A)
%%   @result{} ans = (sym)
%%
%%                      (n + 1)⋅yn(n, x)
%%       yn(n - 1, x) - ────────────────
%%                             x
%% @end group
%% @end example
%%
%% @seealso{@@sym/besseljn, @@sym/bessely}
%% @end defmethod

function Y = besselyn(n, x)
  if (nargin ~= 2)
    print_usage ();
  end
  Y = elementwise_op ('yn', sym(n), sym(x));
end



%!test
%! % roundtrip
%! syms x
%! A = double(besselyn(sym(2), sym(10)));
%! q = besselyn(sym(2), x);
%! h = function_handle(q);
%! B = h(10);
%! assert (abs (A - B) <= eps)

%!error yn(sym('x'))
