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
%% @deftypefn  {Function File} {@var{z} =} axplusy (@var{a}, @var{x}, @var{y})
%% Helper function: scalar a times sym x plus sym y.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = axplusy(a, x, y)

  cmd = { '(a,x,y) = _ins' ...
          'if x.is_Matrix and y.is_Matrix:' ...
          '    return (a*x+y,)' ...
          'if x.is_Matrix and not y.is_Matrix:' ...
          '    return (a*x + y*sp.ones(*x.shape),)' ...
          'if not x.is_Matrix and y.is_Matrix:' ...
          '    return (a*x*sp.ones(*y.shape) + y,)' ...
          'else:' ...
          '    return (a*x + y,)' };

  z = python_cmd (cmd, sym(a), sym(x), sym(y));

end


%! % Should be tested by the functions that use it...
%!assert(isequal(axplusy(sym(3),4,5), sym(3)*4+5))
