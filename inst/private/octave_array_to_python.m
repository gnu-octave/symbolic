%% Copyright (C) 2016 Lagu
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

function r = octave_array_to_python(a)
  t = '';

  [numrows, numcols] = size (a);

  if (numrows == 0)
    r = mat2str([]);
    return;

  elseif (numrows > 1)
    t = strcat('[', t);
    t = strcat(t, octave_array_to_python(a(1, :)));

    for i = 2:numrows
      t = strcat(t, ', ');
      t = strcat(t, octave_array_to_python(a(i, :)));
    end

    t = strcat(t, ']');

  else
    t = strcat('[', t);
    t = strcat(t, mat2str(a(1, 1)));

    for i = 2:numcols
      t = strcat(t, ', ');
      t = strcat(t, mat2str(a(1, i)));
    end

    t = strcat(t, ']');

  end

  r = t;
