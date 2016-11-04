%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod  elementwise_op (@var{scalar_fcn}, @var{A})
%% @defmethodx elementwise_op (@var{scalar_fcn}, @var{A}, @var{B})
%% @defmethodx elementwise_op (@var{scalar_fcn}, @var{A}, @var{B}, @dots{})
%% Apply a scalar function element-by-element to the inputs.
%%
%% Examples:
%% @example
%% A = sym(3)
%% B = sym([4 5 6; 7 4 2])
%% elementwise_op('lambda a, b: a % b', A, B)
%%
%% elementwise_op('round', B)
%% @end example
%%
%% If you need use a complicated function you can declare an @code{_op}
%% python function in a cell array and use it:
%%
%% @example:
%% scalar_fcn = @{ 'def _op(a,b,c,d):'; '    return a % c + d / b' @};
%% A = 3;
%% B = [1 2;3 4];
%% C = inv(B);
%% D = 1;
%% elementwise_op(scalar_fcn, sym(A), sym(B), sym(C), sym(D))
%% @end example
%%
%% As you can see you need declare when you need a sym object,
%% or the function will use it in a literal way.
%%
%% @example
%% syms x
%% A = [x -x sin(x)/x];
%% B = x;
%% C = [-inf, 0, inf];
%% D = '+';
%% elementwise_op('lambda a, b, c, d: a.limit(b, c, d)', sym(A), sym(B), sym(C), D)
%% @end example
%%
%% This example will send @code{D} (@qcode{'+'}) to the function without
%% converting the string to a symbol.
%%
%% Notes:
%%   This function doesn't work with MatrixSymbol.
%%   If you send matrices as arguments, all must have equal sizes
%%   except if have a 1x1 size, in that case it always will ise that value.
%%   Empty arrays are treated as elements.
%%
%% @end defmethod


function z = elementwise_op(scalar_fcn, varargin)

  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['_op = ' scalar_fcn]};
  end

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          'shapes = [A.shape for A in _ins if isinstance(A, MatrixBase)]'
          'sameshape = all([s == shapes[0] for s in shapes])'
          'assert sameshape, "Matrices in input must all have the same shape"'
          '# could be no matrices in the input'
          'shape = shapes[0] if len(shapes) > 0 else (1, 1)'
          'q = zeros(*shape)'
          'for i in range(0, len(q)):'
          '    q[i] = _op(*[A[i] if isinstance(A, MatrixBase) else A for A in _ins])'
          'return q' ];

  z = python_cmd (cmd, varargin{:});

end
