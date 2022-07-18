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
%% @defun  cygpath ()
%% Convert Windows native path to Cygwin POSIX-style path.
%%
%% @seealso{python_env_is_cygwin_like}
%% @end defun

function posix_path = cygpath (native_path)
  %% FIXME: only allow safe characters inside "..."
  if ~isempty (strfind (native_path, '"'))
    error ('cygpath: native path %s must not contain "', native_path);
  end

  [status, out] = system (['cygpath -u "' native_path '"']);
  if status ~= 0
    error ('cygpath: cygpath exited with status %d', status);
  end

  posix_path = regexprep (out, '[\r]?[\n]$', ''); % strip trailing newline
  assert (logical (regexp (posix_path, '^[^\r\n]+$'))); % validate path
end
