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

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = binop_helper(x, y, scalar_fcn_str)
%binop_helper, private

  % FIXME: even faster in if move to python_header (load once)?

  % string can either be the name of a function or the definition
  % of a new function.
  if (strncmp(scalar_fcn_str, 'def ', 4))
    cmd = scalar_fcn_str;
  else
    cmd = ['sf = ' scalar_fcn_str];
  end

  % string should not end with newline
  cmd = [ cmd '\n' ...
          '(x,y) = _ins\n' ...
          'if x.is_Matrix and y.is_Matrix:\n' ...
          '    assert x.shape == y.shape\n' ...
          '    A = sp.Matrix(x.shape[0], y.shape[1],\n' ...
          '        lambda i, j: sf(x[i,j], y[i,j]))\n' ...
          '    return (A, )\n' ...
          'if x.is_Matrix and not y.is_Matrix:\n' ...
          '    return (x.applyfunc(lambda a: sf(a, y)), )\n' ...
          'if not x.is_Matrix and y.is_Matrix:\n' ...
          '    return (y.applyfunc(lambda a: sf(x, a)), )\n' ...
          'return (sf(x, y), )' ];

  z = python_cmd_string (cmd, sym(x), sym(y));

end
