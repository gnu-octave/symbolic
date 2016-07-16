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

function store_vars_in_python (varname, L)
  persistent counter = 0

  for i = 1:numel(L)
    x = L{i};
    if (isa(x, 'sym'));
      pyexec([varname '.append(' char(x) ')'])
    elseif (iscell (x))
      tempname = [varname num2str(counter)];
      counter = counter + 1;
      pyexec ([tempname ' = []'])
      store_vars_in_python (tempname, x)
      pyexec([varname '.append(' tempname ')'])
    else
      pycall ('pystoretemp', x)
      pyexec ([varname '.append(_temp)'])
    end
  end
end
