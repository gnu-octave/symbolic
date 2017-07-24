%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @defmethod @@sym nextprime (@var{x})
%% Return the next prime number.
%%
%% Example:
%% @example
%% @group
%% nextprime(sym(2))
%%   @result{} ans = (sym) 3
%
%% nextprime([sym(2) 10 0 -1 65530])
%%   @result{} (sym) [3  11  2  2  65537]  (1×5 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/isprime, @@sym/prevprime}
%% @end defmethod


function y = nextprime(x)

  %y = elementwise_op ('nextprime', x);

  % workaround as upstream SymPy returns int, not sym
  y = elementwise_op ('lambda a: S(nextprime(a))', x);

end


%!assert (isequal (nextprime(sym(2)), 3));
%!assert (isequal (nextprime(sym(18)), 19));
%!assert (isequal (nextprime(sym([1 2 3])), [2 3 5]));

%!assert (isequal (nextprime(sym([-1 0])), [2 2]));

%!test
%! % result is a sym
%! p = nextprime(sym(2));
%! assert (isa (p, 'sym'))
