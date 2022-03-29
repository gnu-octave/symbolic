%% Copyright (C) 2020 Mike Miller
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
%% @deftypefun {@var{A} =} python_ipc_popen2_reset (@var{fin}, @var{fout}, @var{pid})
%% Private helper function for Python IPC.
%%
%% @var{A} is the resulting object, which might be an error code.
%% @end deftypefun

function A = python_ipc_popen2_reset (fin, fout, pid)

  verbose = ~ sympref ('quiet');

  if (~ isempty (pid))
    if (verbose)
      disp ('Closing the Python communications link.')
    end
  end

  if (~ isempty (fin))
    % produces a single newline char: not sure why
    t = fclose (fin); fin = [];
    waitpid (pid);
    pid = [];
    A = (t == 0);
  else
    A = true;
  end

  if (~ isempty (fout))
    t = fclose (fout); fout = [];
    A = A && (t == 0);
  end

end
