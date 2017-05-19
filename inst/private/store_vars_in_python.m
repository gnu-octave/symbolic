%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2016 Colin B. Macdonald
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

function var_pyobj = store_vars_in_python (L)
  var_pyobj = py.list ();
  for i = 1:numel(L)
    x = L{i};
    if (isa(x, 'sym'))
      var_pyobj.append (pyeval (sympy (x)))
    elseif (iscell (x))
      var_pyobj.append (store_vars_in_python (x))
    else
      var_pyobj.append(x);
    end
  end
end
