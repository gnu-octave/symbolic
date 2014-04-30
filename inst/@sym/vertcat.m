%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z}} vertcat (@var{x}, @var{y}, ...)
%% Vertically concatentate symbolic arrays.
%%
%% @seealso{horzcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = vertcat(varargin)

  cmd = [ '_proc = []\n'  ...
          'for i in _ins:\n'  ...
          '    if i.is_Matrix:\n'  ...
          '        _proc.append(i)\n'  ...
          '    else:\n'  ...
          '        _proc.append(sp.Matrix([[i]]))\n'  ...
          'M = sp.Matrix.vstack(*_proc)\n'  ...
          'return (M,)' ];

  varargin = sym(varargin);
  h = python_cmd (cmd, varargin{:});

