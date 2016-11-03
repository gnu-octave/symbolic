%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym besselj (@var{alpha}, @var{x})
%% Symbolic Bessel function of the first kind.
%%
%% Example:
%% @example
%% @group
%% syms n x
%% A = 2*besselj(n,x)
%%   @result{} A = (sym) 2⋅besselj(n, x)
%% diff(A)
%%   @result{} (sym) besselj(n - 1, x) - besselj(n + 1, x)
%% @end group
%% @end example
%%
%% @seealso{@@sym/bessely, @@sym/besseli, @@sym/besselk}
%% @end defmethod

function J = besselj(n, x)

  if (nargin ~= 2)
    print_usage ();
  end

  J = elementwise_op ('besselj', sym(n), sym(x));

end


%!test
%! X = [1 2 3; 4 5 6];
%! ns = [sym(0) 1 -2; sym(1)/2 -sym(3)/2 pi];
%! n = double(ns);
%! A = double(besselj(ns, X));
%! B = besselj(n, X);
%! assert (all (all (abs (A - B) < 50*eps*abs(A))))

%!test
%! % roundtrip
%! syms x
%! A = besselj(2, 10);
%! q = besselj(2, x);
%! h = function_handle(q);
%! B = h(10);
%! assert (abs (A - B) <= eps*abs(A))

%!error besselj(sym('x'))
