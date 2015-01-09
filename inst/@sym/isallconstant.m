%% Copyright (C) 2014, 2015 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn {Function File}  {@var{y} =} isallconstant (@var{x})
%% Whether all elements of a symbolic array are constant.
%%
%% @seealso{isconstant, symvar, findsymbols}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = isallconstant(x)

  z = isempty (findsymbols (x));

end


%!assert (isallconstant([sym(1) 2 3]))

%!test
%! syms x
%! assert (~isallconstant([sym(1) x 3]))

%!test
%! syms x
%! assert (~isallconstant([sym(1) x; sym(2) 3]))
