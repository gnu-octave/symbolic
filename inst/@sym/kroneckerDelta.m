%% Copyright (C) 2017-2019 Colin B. Macdonald
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
%% @defmethod  @@sym kroneckerDelta (@var{n}, @var{m})
%% @defmethodx @@sym kroneckerDelta (@var{n})
%% Kronecker Delta function.
%%
%% Examples:
%% @example
%% @group
%% kroneckerDelta (sym(4), sym(5))
%%   @result{} ans = (sym) 0
%% kroneckerDelta (sym(4), sym(4))
%%   @result{} ans = (sym) 1
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms n m integer
%% kroneckerDelta (m, n)
%%   @result{} ans = (sym)
%%
%%       δ
%%        m,n
%% @end group
%% @end example
%%
%% The second input defaults to zero:
%% @example
%% @group
%% kroneckerDelta (n)
%%   @result{} ans = (sym)
%%
%%       δ
%%        0,n
%% @end group
%% @end example
%%
%% @seealso{@@sym/dirac}
%% @end defmethod


function a = kroneckerDelta (n, m)

  if (nargin == 1)
    m = sym(0);
  elseif (nargin > 2)
    print_usage ();
  end

  a = elementwise_op ('KroneckerDelta', sym(n), sym(m));

end


%!error <Invalid> kroneckerDelta (sym(1), 2, 3)

%!test
%! syms x
%! assert (isequal (kroneckerDelta (x, x), sym(1)))

%!assert (isequal (kroneckerDelta ([sym(1) 2 3], [1 2 0]), sym([1 1 0])))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms x y
%! f = kroneckerDelta (x, y);
%! h = function_handle (f);
%! assert (h (1, 2), 0)
%! assert (h (2, 2), 1)
%! end
