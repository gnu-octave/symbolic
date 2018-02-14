%% Copyright (C) 2018 Mike Miller
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

function r = python_have_quiet_flag (pyexec)
%private function

  if (ispc () && ~ isunix ())
    [st, out] = system ([pyexec ' -q -c True 2> NUL']);
  else
    [st, out] = system ([pyexec ' -q -c True 2> /dev/null']);
  end

  r = (st == 0);

end
