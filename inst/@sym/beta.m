%% Copyright (C) 2016 Lagu
%% Copyright (C) 2018-2019 Colin B. Macdonald
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
%% @defmethod @@sym beta (@var{x}, @var{y})
%% Beta function.
%%
%% Examples:
%% @example
%% @group
%% syms x y
%% beta(x, y)
%%   @result{} ans = (sym) Β(x, y)
%% @end group
%% @end example
%% @end defmethod


function r = beta(x, y)

  if (nargin ~= 2)
    print_usage ();
  end

  r = elementwise_op ('beta', sym(x), sym(y));

end


%!error <usage> beta (sym(1), 2, 3)

%!assert (isequal (double (beta (sym(1), 2)), 1/2))
%!assert (isinf (double (beta (sym(1), 0))))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms x y
%! f = beta (x, y);
%! h = function_handle (f);
%! A = h (1.1, 2.2);
%! B = beta (1.1, 2.2);
%! assert (A, B)
%! end
