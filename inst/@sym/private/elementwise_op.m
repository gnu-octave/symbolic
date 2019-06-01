%% Copyright (C) 2014, 2016, 2018-2019 Colin B. Macdonald
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
%% @defun  elementwise_op (@var{scalar_fcn}, @var{A})
%% @defunx elementwise_op (@var{scalar_fcn}, @var{A}, @var{B})
%% @defunx elementwise_op (@var{scalar_fcn}, @var{A}, @var{B}, @dots{})
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
%%   Matrix arguments must all have equal sizes.
%%
%% @end defun


function z = elementwise_op(scalar_fcn, varargin)

  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['_op = ' scalar_fcn]};
  end

  % Dear hacker from the distant future: to enable Tensor support, try
  % using `isinstance(A, (MatrixBase, NDimArray))` in a few places below.

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          % Make sure all matrices in the input are the same size, and set q to one of them
          'q = None'
          'for A in _ins:'
          '    if isinstance(A, MatrixBase):'
          '        if q is None:'
          '            q = A.as_mutable()'
          '        else:'
          '            assert q.shape == A.shape, "Matrices in input must all have the same shape"'
          % in case all inputs were scalars:
          'if q is None:'
          '    q = Matrix([0])'
          'for i in range(0, len(q)):'
          '    q[i] = _op(*[k[i] if isinstance(k, MatrixBase) else k for k in _ins])'
          'return q' ];

  z = pycall_sympy__ (cmd, varargin{:});

end
