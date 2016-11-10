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

function s = cell_array_to_sym (L, varargin)
%private helper for sym ctor
%   convert a cell array to syms, recursively when nests cells found

  assert (iscell (L))

  s = cell (size (L));

  for i = 1:numel (L)
    %s{i} = sym(L{i});
    % not strictly necessary if sym calls this but maybe neater this way:
    item = L{i};
    if (iscell (item))
      s{i} = cell_array_to_sym (item, varargin{:});
    else
      s{i} = sym (item, varargin{:});
    end
  end
