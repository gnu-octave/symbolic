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

function A = make_sym_matrix(As, sz)
% private helper function for making symbolic matrix

  s = size(sz)(2);
  assert (s <= 2, 'SymbolicMatrix actually only support max 2 dimesions');

  sz = sym([sz zeros(1, 2-s)]);

  if ~isempty(findsymbols(sz))
    cmd = { 'As, sz = _ins'
            'return sympy.MatrixSymbol(As, *sz),' };
    A = python_cmd (cmd, As, sz);
  else
    cmd = { 'As, sz = _ins'
            'if sz[0] == 0 or sz[1] == 0:'
            '    return sympy.Matrix(sz[0], sz[1], []),'
            '    #sympy.MatrixSymbol(As, sz[0], sz[1]),'  %%Probably linked to https://github.com/cbm755/octsympy/issues/159
            'if sz[0] > 20 or sz[1] > 20:'  %%Limit to show the expression
            '    return sympy.MatrixSymbol(As, *sz),'
            'if sz[0] < 10 and sz[1] < 10:'
            '    extra = ""'
            'else:'
            '    extra = "_"'
            'L = [[Symbol("%s%d%s%d" % (As, i+1, extra, j+1)) \'
            '      for j in range(0, sz[1])] \'
            '      for i in range(0, sz[0])]'
            'A = sympy.Matrix(L)'
            'return A,' };
    A = python_cmd (cmd, As, sz);
  end

end
