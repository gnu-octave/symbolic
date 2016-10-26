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


function z = op_helper(scalar_fcn, varargin)
%op_helper, private
%
%   'scalar_fcn' can either be the name of a function or a lambda.
%     example: 'lambda a,b: a % b');
%     example: 'lambda a,b,c: a % b + c');
%   It can also be the defn of a function called "_op"
%     e.g., { 'def _op(a,b):' '    return a % b' }
%     e.g., { 'def _op(a,b,c,d):' '    return a % c + d / b' }
%
%   Caution: Just because you are implementing an operation,
%   does not mean you want to use this helper.  You shoudl use this
%   helper when you by default want per-component calculations.
%
%   FIXME: even faster if move to python_header (load once)?

  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['_op = ' scalar_fcn]};
  end

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          'q = Matrix([0])'
          'for i in _ins:'
          '    if isinstance(i, MatrixBase) and i:'
          '        if q.shape == (1, 1):'
          '            q = i'
          '        else:'
          '            assert q.shape == i.shape, "Matrices must have equal sizes"'
          'for i in range(0, len(q)):'
          '    q[i] = _op(*[k[i] if isinstance(k, MatrixBase) and k else k for k in _ins])'
          'return q,' ];

  z = python_cmd (cmd, varargin{:});

end
