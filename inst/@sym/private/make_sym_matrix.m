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

  assert (ischar (As));
  assert (isequal (size(sz), [1 2]));
  if (isa(sz, 'sym'))
    cmd = { 'As, sz = _ins'
            'return sympy.MatrixSymbol(As, *sz),' };
    A = python_cmd (cmd, As, sz);
  else
    n = int32(sz(1));
    m = int32(sz(2));
    % FIXME: returning an appropriate MatrixSymbol is nice idea,
    % but would need more work on IPC, size().  The ideal thing
    % might be a string representation that looks like this
    % when displayed in Octave, but is represented with a
    % MatrixSymbol internally.
    cmd = { 'As, n, m = _ins'
            '#A = sympy.MatrixSymbol(As, n, m)'
            'if n == 0 or m == 0:'
            '    return sympy.Matrix(n, m, []),'
            '    #sympy.MatrixSymbol(As, n, m),' % broken?
            'if n < 10 and m < 10:'
            '    extra = ""'
            'else:'
            '    extra = "_"'
            'L = [[Symbol("%s%d%s%d" % (As, i+1, extra, j+1)) \'
            '      for j in range(0, m)] \'
            '      for i in range(0, n)]'
            'A = sympy.Matrix(L)'
            'return A,' };
    A = python_cmd (cmd, As, n, m);
  end

end
