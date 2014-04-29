%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{y}} expand (@var{x})
%% Combine parts of a symbolic product
%%
%% @seealso{factor}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = expand(x)

  evalpy('y = expand(x);;', x)

end


%!test syms x
%! assert( logical (x^2 + 6*x + 5 == expand ((x+5)*(x+1))))
