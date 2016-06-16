%% Copyright (C) 2014, 2015 Colin B. Macdonald
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

function s = python_header()
%private

  persistent PyStrCache

  if (isempty(PyStrCache))
    thisdir = fileparts (mfilename ('fullpath'));
    pyfile = fullfile (thisdir, 'python_header.py');
    PyStrCache = fileread (pyfile);
    % octave 3.6 workaround
    sz = size(PyStrCache);
    if (sz(1) > sz(2))
      warning('Octave 3.6 support is deprecated');
      PyStrCache = PyStrCache';
    end
  end

  s = PyStrCache;

end
