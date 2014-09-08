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

function z = binop_helper(x, y, scalar_fcn)
%binop_helper, private

  % FIXME: even faster in if move to python_header (load once)?

  % string can either be the name of a function or the definition
  % of a new function.
  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['sf = ' scalar_fcn]};
  end

  cmd = { cmd{:} ...
          '(x, y) = _ins' ...
          'if x.is_Matrix and y.is_Matrix:' ...
          '    assert x.shape == y.shape' ...
          '    A = sp.Matrix(x.shape[0], y.shape[1],' ...
          '        lambda i,j: sf(x[i,j], y[i,j]))' ...
          '    return A,' ...
          'if x.is_Matrix and not y.is_Matrix:' ...
          '    return x.applyfunc(lambda a: sf(a, y)),' ...
          'if not x.is_Matrix and y.is_Matrix:' ...
          '    return y.applyfunc(lambda a: sf(x, a)),' ...
          'return sf(x, y),' };

  z = python_cmd (cmd, sym(x), sym(y));

end
