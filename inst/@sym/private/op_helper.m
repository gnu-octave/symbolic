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
%%
%% Notes:
%%   This function don't actually works with MatrixSymbol.
%%   If you send matrices as arguments, all must have equal sizes
%%   except if have a 1x1 size, in that case it always will ise that value.
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
          'for A in _ins:'
          '    if isinstance(A, MatrixBase):'
          '        if q.shape == (1, 1):'
          '            q = A'
          '        else:'
          '            assert q.shape == A.shape, "Matrices must have equal sizes"'
          'for i in range(0, len(q)):'
          '    q[i] = _op(*[k[i] if isinstance(k, MatrixBase) else k for k in _ins])'
          'return q,' ];

  z = python_cmd (cmd, varargin{:});

end
