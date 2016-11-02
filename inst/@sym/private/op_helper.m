%% Copyright (C) 2014 Colin B. Macdonald
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

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod op_helper (@var{scalar_fcn}, @var{dor})
%% Apply function element-by-element with the input vars in @var{scalar_fcn}
%% Private helper
%%
%% Example:
%% A = sym([3])
%% B = sym([4 5 6;7 4 2])
%% op_helper('lambda a,b: a % b', A, B)
%%
%% op_helper('round', B)
%% 
%% If you need use a complex function you can declare a _op
%% python function in a cell and use it:
%%
%% scalar_fcn = { 'def _op(a,b,c,d):' '    return a % c + d / b' }
%% A = 3
%% B = [1 2;3 4]
%% C = inv(B)
%% D = 1
%%
%% op_helper(scalar_fcn, sym(A), sym(B), sym(C), sym(D))
%%
%% As you can see you need declare when you need a sym object,
%% or the function will use it in a literal way.
%%
%% syms x
%% A = [x -x sin(x)/x]
%% B = x
%% C = [-inf, 0, inf]
%% D = '+'
%% op_helper('lambda a, b, c, d: a.limit(b, c, d)', sym(A), sym(B), sym(C), D)
%%
%% This example will send D ('+') to the function without convert the string
%% to a symbol.
%%
%% If you need use a matrix as element, you can send is in a cell:
%%
%% A = [1, 2; 3, 4]
%% B = [1, 1; 1, 1]
%% op_helper('lambda a, b: a == b', sym(A), {sym(B)})
%%
%% This example will compare every element of A with the entire matrix B.
%% You can send more expressions in {} in various dimensions.
%% Be careful with this, actually we don't have a safe way to check if
%% the cell have regular dimensions, so the actual behavior will use
%% the first found dimensions in the cell, others will be ignored.
%%
%% Notes:
%%   This function don't actually works with MatrixSymbol.
%%   If you send matrices as arguments, all must have equal sizes
%%   except if have a 1x1 size, in that case always will use that value.
%%
%% @end defmethod


function z = op_helper(scalar_fcn, varargin)

  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['_op = ' scalar_fcn]};
  end

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          'q = Matrix([0])'
          'shape = lambda a: a.shape if isinstance(a, MatrixBase) else ((len(a),) + shape(a[0]) if isinstance(a, list) else ())'
          'get = lambda a, b: (a[b[0]] if len(b) == 1 else get(a[b[0]], b[1:])) if isinstance(a, list) else a[b]'
          'def get1(a, b):'
          '    q = shape(a)'
          '    return a[0] if q.count(1) == len(q) else get(a,b)'
          'for A in _ins:'
          '    if isinstance(A, (MatrixBase, list)):'
          '        tmp = shape(q)'
          '        if tmp.count(1) == len(tmp):'
          '            q = A'
          '        else:'
          '            assert shape(q) == shape(A), "Matrices must have equal sizes"'
          'for i in itertools.product(*map(Range, shape(q))):'
          '    q[i] = _op(*[get1(k,i) if isinstance(k, (MatrixBase, list)) else k for k in _ins])'
          'return (Matrix(q) if isinstance(q, list) else q),' ];

  z = python_cmd (cmd, varargin{:});

end
