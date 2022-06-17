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
%% @defun  show_system_info ()
%% Show information about the current system.
%%
%% @seealso{computer, ver}
%% @end defun

function show_system_info ()
  [platform, array_maxsize, endian] = computer ();
  arch = computer ('arch');

  disp ('System info');
  disp ('-----------');
  disp ('');
  fprintf ('Platform: %s\n', platform);
  fprintf ('Array Maximum Size: %d\n', array_maxsize);
  fprintf ('Endianness: %s\n', endian);
  fprintf ('Architecture: %s\n', arch);
  ver ();
  disp ('');
end
