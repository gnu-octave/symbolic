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
%% @deftypefun {[@var{fd}, @var{filename}] =} make_temp_file__ (@var{tmpdir}, @var{prefix})
%% Try to create temporary file in temporary directory @var{tmpdir} with prefix
%% @var{prefix} in the most secure and portable way possible.
%%
%% This function is not really intended for end users.
%%
%% @end deftypefun


%% This function is used in private/python_ipc_*.m
%% Assume Python IPC is not initialized yet

function [fd, filename] = make_temp_file__ (tmpdir, prefix)
  if (exist ('OCTAVE_VERSION', 'builtin'))
    template = [tmpdir '/' prefix 'XXXXXX'];
    [fd, filename, msg] = mkstemp (template);
    if (fd == -1 || isequal (filename, ''))
      error ('make_temp_file__: cannot create temp file: %s', msg);
    end

  elseif (usejava ('jvm')) % java is required when not running octave
    attrs = javaArray ('java.nio.file.attribute.FileAttribute', 0);
    path = javaMethod ('createTempFile', 'java.nio.file.Files',
                       prefix, '',
                       attrs);
    filename = javaMethod ('toString', path);
    fd = fopen (filename, 'r+');

  else
    error ('make_temp_file__: cannot create temp file: please enable java');
  end
end


%!test
%! % general test
%! [fd, filename] = make_temp_file__ (tempdir (), 'octsympy-');
%! assert (~isempty (strfind (filename, tempdir ())));
%! assert (~isempty (strfind (filename, 'octsympy-')));
%! assert (mod (fd, 1) == 0 && fd > 2);
%! s = 'hello, world';
%! fprintf (fd, s);
%! assert (fclose (fd) == 0);
%! fd2 = fopen (filename);
%! s2 = fgets (fd2);
%! assert (isequal (s, s2));
%! assert (fgets (fd2) == -1);
%! assert (fclose (fd2) == 0);
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   assert (unlink (filename) == 0);
%! else
%!   delete (filename);
%! end

%!error <cannot create temp file>
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%!   make_temp_file__ ('/nonexistent', '');
%! end
