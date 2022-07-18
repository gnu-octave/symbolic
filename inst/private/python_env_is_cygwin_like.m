%% Copyright (C) 2022 Alex Vong
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
%% If not, see <https://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @defun  python_env_is_cygwin_like (pyexec)
%% Check if Python @var{pyexec} is running in a Cygwin-like POSIX environment,
%% such as Cygwin or MSYS2.  The result is memoized to speed up subsequent
%% calls.
%%
%% @seealso{cygpath}
%% @end defun

function r = python_env_is_cygwin_like (pyexec)
  persistent python_env_is_cygwin_like_memo

  if ~isempty (python_env_is_cygwin_like_memo)
    r = python_env_is_cygwin_like_memo;
    return
  end

  if ispc ()
    if system ('where /q cygpath') ~= 0
      r = false;
      python_env_is_cygwin_like_memo = r;
      return
    end

    [status, out] = system ([pyexec ' -c "import os; print(os.name)"']);
    if status ~= 0
      error ('python_env_is_cygwin_like: %s exited with status %d', ...
             pyexec, status);
    end
    r = ~isempty (regexp (out, 'posix', 'match'));
    python_env_is_cygwin_like_memo = r;
  else
    r = false;
    python_env_is_cygwin_like_memo = r;
  end
end
