%% Copyright (C) 2016 Colin B. Macdonald and Lagu
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
%% @deftypefn {Function File}  {@var{r} =} unique (@var{A})
%% Return the unique elements of A.
%%
%% @seealso{union, intersect, setdiff, setxor, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = unique(A)

  S = python_cmd ('return list(uniq(*_ins)),', A);

  r = horzcat(S{:});

end


%!test
%! A = sym([1 2 3 3 5 3 2 6 5]);
%! B = sym([1 2 3 5 6]);
%! assert (isequal (unique(A), B))

%!test
%! syms x y
%! A = [1 2 3 3 4 5 5 6 7 7 x x y y];
%! B = [1  2  3  4  5  6  7  x  y];
%! assert (isequal (unique(A), B))
