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

  % FIXME: even faster in if move to python_header (load once)?
  % FIXME: uniop_helper?  autogenereted ones...

  cmd = [ '(x,y) = _ins\n' ...
          'sc = ' scalar_fcn_str '\n' ...
          'if x.is_Matrix and y.is_Matrix:\n' ...
          '    assert x.shape == y.shape\n' ...
          '    A = Matrix(x.shape[0], y.shape[1],\n' ...
          '        lambda i, j: sc(x[i,j], y[i,j]))\n' ...
          '    return (A, )\n' ...
          'if x.is_Matrix and not y.is_Matrix:\n' ...
          '    return (x.applyfunc(lambda a: sc(a, y)), )\n' ...
          'if not x.is_Matrix and y.is_Matrix:\n' ...
          '    return (y.applyfunc(lambda a: sc(x, a)), )\n' ...
          'return (sc(x, y), )' ];

  z = python_cmd (cmd, sym(x), sym(y));

end
