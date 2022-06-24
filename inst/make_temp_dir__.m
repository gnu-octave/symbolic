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
%% @documentencoding UTF-8
%% @deftypefun {@var{path} =} make_temp_dir__ (@var{tmpdir}, @var{prefix})
%% Try to create temporary directory in temporary directory @var{tmpdir} with
%% prefix @var{prefix} in the most secure and portable way possible.
%%
%% This function is not really intended for end users.
%%
%% @end deftypefun


function path = make_temp_dir__ (tmpdir, prefix)
  cmd = {'import tempfile'
         '(tmpdir, prefix) = _ins'
         'return tempfile.mkdtemp(dir=tmpdir, prefix=prefix)'};
  path = pycall_sympy__ (cmd, tmpdir, prefix);
end


%!test
%! % general test
%! path = make_temp_dir__ (tempdir (), 'octsympy-');
%! assert (~isempty (strfind (path, tempdir ())));
%! assert (~isempty (strfind (path, 'octsympy-')));
%! assert (isfolder (path));
%! assert (isequal (ls (path), ''));
%! assert (rmdir (path));

%!error <Python exception: FileNotFoundError>
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   make_temp_dir__ ('/nonexistent', '');
%! end
