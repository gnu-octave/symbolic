%% Copyright (C) 2014, 2019 Colin B. Macdonald
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

  assert (ischar (As), 'Cannot create symbolic matrix with non-string')
  assert (isequal (size(sz), [1 2]), 'Cannot create symbolic matrix with that size')
  % regexp: non-digit followed by any word
  assert (~ isempty (regexp (As, '^\D\w*$')), 'Cannot create symbolic matrix with expression "%s"', As)

  if (isa(sz, 'sym'))
    cmd = { 'As, (n, m), = _ins'
            'if n.is_Integer and m.is_Integer:'
	    '    return (0, int(n), int(m)) '
	    'else:'
	    '    return (1, sympy.MatrixSymbol(As, n, m), 0)' };
    [flag, n, m] = pycall_sympy__ (cmd, As, sz);
    if (flag)
      A = n;
      return
    end
  else
    n = int32(sz(1));
    m = int32(sz(2));
  end

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
    A = pycall_sympy__ (cmd, As, n, m);

end
