%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{b} =} ismatrix (@var{x})
%% Return true if this symbolic expression is a matrix.
%%
%% That is, a 2D array including scalar and empty matrices.
%%
%% @seealso{isscalar, isvector, size}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function b = ismatrix(x)

  b = (length(size(x)) == 2);

end


%!assert(ismatrix(sym('x')))
%!assert(ismatrix(sym([1 2 3])))
%!assert(ismatrix(sym([1; 2])))
%!assert(ismatrix(sym([1 2; 3 4])))
%!assert(ismatrix(sym([])))
%!assert(ismatrix(sym(ones(1,0))))
%!assert(ismatrix(sym(ones(0,3))))
