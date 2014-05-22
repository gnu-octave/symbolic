%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{i} =} subsindex (@var{x})
%% Used to implement indexing by sym.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function b = subsindex(x)

  % zero-based indexing
  b = double(x) - 1;

end


%!test
%! i = sym(1);
%! a = 7;
%! assert(a(i)==a);
%! i = sym(2);
%! a = 2:2:10;
%! assert(a(i)==4);

%!test
%! i = sym([1 3 5]);
%! a = 1:10;
%! assert( isequal (a(i), [1 3 5]))

%!test
%! i = sym([1 3 5]);
%! a = sym(1:10);
%! assert( isequal (a(i), sym([1 3 5])));

%!test
%! % should be an error if it doesn't convert to double
%! syms x
%! a = 1:10;
%! try
%!   a(x)
%!   waserr = false;
%! catch
%!   waserr = true;
%! end
%! assert(waserr)
