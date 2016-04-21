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

function assert_we_have_python(pyexec)
%private function

  [st, out] = system([pyexec ' -c "a = 42"']);
  if (st ~= 0)
    error('OctSymPy:nopython', ...
          ['Cannot run the Python executable "%s"\n' ...
           '    Python and SymPy are needed for most Symbolic features.\n' ...
           '    Is Python installed?  Is your "path" configured correctly?'], ...
          pyexec)
  end
end
