%% Copyright (C) 2016 Abhinav Tripathi, Colin B. Macdonald
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

function store_vars_in_python (var_pyobj, L)
  for i = 1:numel(L)
    x = L{i};
    if (isa(x, 'sym'))
      var_pyobj.append(pyeval(char(x)))
    elseif (iscell (x))
      temp_var = py.list();
      store_vars_in_python (temp_var, x)
      var_pyobj.append(temp_var);
    else
      var_pyobj.append(x);
    end
  end
end
