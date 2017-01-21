%% Copyright (C) 2017 NVS Abhilash
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
%% @defmethod @@sym prevprime (@var{x})
%% Return the previous prime number.
%%
%% Example:
%% @example
%% @group
%% prevprime(sym(3))
%%   @result{} ans = (sym) 2
%
%% prevprime([sym(3) 10 100 1000 65530])
%%   @result{} (sym) [2  7  97  997  65521]  (1×5 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/isprime, @@sym/nextprime}
%% @end defmethod


function y = prevprime(x)

  if (nargin ~= 1)
    print_usage ()
  end

  %y = elementwise_op ('prevprime', x);

  % workaround as upstream SymPy returns int, not sym
  y = elementwise_op ('lambda a: S(prevprime(a))', x);

end


%!assert (isequal (prevprime(sym(3)), 2));
%!assert (isequal (prevprime(sym(20)), 19));
%!assert (isequal (prevprime(sym([3 5 10])), [2 3 7]));

%!error prevprime(sym(2))
%!error prevprime(sym(-2))

%!test
%! % result is a sym
%! p = prevprime(sym(3));
%! assert (isa (p, 'sym'))
