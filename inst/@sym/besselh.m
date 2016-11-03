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
%% @defmethod  @@sym besselh (@var{alpha}, @var{k}, @var{x})
%% @defmethodx @@sym besselh (@var{alpha}, @var{x})
%% Symbolic Hankel functions of first/second kind.
%%
%% The kind @var{k} can be 1 or 2 and defaults to 1.
%%
%% Example:
%% @example
%% @group
%% syms x alpha
%% H1 = besselh(alpha, 1, x)
%%   @result{} H1 = (sym) hankel₁(α, x)
%%
%% H2 = besselh(alpha, 2, x)
%%   @result{} H2 = (sym) hankel₂(α, x)
%% @end group
%% @end example
%%
%% @seealso{@@sym/airy, @@sym/besselj, @@sym/bessely, @@sym/besseli,
%%          @@sym/besselk}
%% @end defmethod

function A = besselh(alpha, k, x)

  if (nargin == 3)
    % no-op
  elseif (nargin == 2)
    x = k;
    k = 1;
  else
    print_usage ();
  end

  assert(isscalar(k))

  if (logical(k == 1))
    A = elementwise_op ('hankel1', sym(alpha), sym(x));
  elseif (logical(k == 2))
    A = elementwise_op ('hankel2', sym(alpha), sym(x));
  else
    error('besselh: expecting k = 1 or 2')
  end

end


%!test
%! % default to k=1
%! syms z a
%! A = besselh(a, z);
%! B = besselh(a, 1, z);
%! assert (isequal (A, B))

%!error besselh(sym('z'))
%!error <expecting k = 1 or 2> besselh(2, 0, sym('z'))
%!error <expecting k = 1 or 2> besselh(2, 3, sym('z'))

%!test
%! % doubles, relative error
%! X = [1 2 pi; 4i 5 6+6i];
%! Xs = sym(X);
%! Alpha = [pi 3 1; 3 2 0];
%! Alphas = sym(Alpha);
%! for k = 1:2
%!   A = double(besselh(Alphas, k, Xs));
%!   B = besselh(Alpha, k, X);
%!   assert (all (all (abs(A - B) < 10*eps*abs(A))))
%! end

%!test
%! % round-trip
%! syms x
%! for k = 1:2
%!   A = besselh(4, k, 10);
%!   q = besselh(4, k, x);
%!   h = function_handle(q);
%!   B = h(10);
%!   assert (abs(A - B) <= eps*abs(A))
%! end
