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

function B = indent_lines(A, n)
% indent each line in the cell array A by n spaces

  pad = repmat(' ', 1, n);
  if (0 == 1)
    % 27s
    B = cellfun(@(x) [pad x], A, 'UniformOutput', false);
  else
    % 23s
    B = cell(size(A));
    for i = 1:numel(A)
      B{i} = [pad A{i}];
    end
  end
end
