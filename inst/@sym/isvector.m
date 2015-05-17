%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{b} =} isvector (@var{x})
%% Return true if this symbolic expression is a vector.
%%
%% @seealso{size, numel, isscalar}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function b = isvector(x)

  d = size(x);
  b = any(d == 1);

end


%!assert(isvector(sym('x')))
%!assert(isvector(sym([1 2 3])))
%!assert(isvector(sym([1; 2])))
%!assert(~isvector(sym([1 2; 3 4])))
%!assert(~isvector(sym([])))
%!assert(isvector(sym(ones(1,0))))
%!assert(~isvector(sym(ones(0,3))))
