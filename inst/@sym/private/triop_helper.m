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

function z = triop_helper(x, y, z, scalar_fcn)
%triop_helper, private
%
%   'scalar_fcn' can either be the name of a function or a lambda.
%     example: 'lambda a,b,c: a*b+c');
%   It can also be the defn of a function called "_op"
%     e.g., { 'def _op(a,b):' '    return a*b+c' }
%
%   Caution: Just because you are implementing a tertiary operation,
%   does not mean you want to use this helper.  You should use this
%   helper when you by default want per-component calculations.
%
%   FIXME: even faster if move to python_header (load once)?

  assert (nargin == 4)

  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['_op = ' scalar_fcn]};
  end

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          '(x, y, z) = _ins'
          'if x.is_Matrix and y.is_Matrix and z.is_Matrix:'
          '    assert x.shape == y.shape'
          '    assert x.shape == z.shape'
          '    A = sp.Matrix(x.shape[0], x.shape[1],'
          '        lambda i,j: _op(x[i,j], y[i,j], z[i,j]))'
          '    return A'
          'if x.is_Matrix and y.is_Matrix:'
          '    assert x.shape == y.shape'
          '    return sp.Matrix(x.shape[0], x.shape[1],'
          '                     lambda i,j: _op(x[i,j], y[i,j], z))'
          'if x.is_Matrix and z.is_Matrix:'
          '    assert x.shape == z.shape'
          '    return sp.Matrix(x.shape[0], x.shape[1],'
          '                     lambda i,j: _op(x[i,j], y, z[i,j]))'
          'if y.is_Matrix and z.is_Matrix:'
          '    assert y.shape == z.shape'
          '    return sp.Matrix(y.shape[0], y.shape[1],'
          '                     lambda i,j: _op(x, y[i,j], z[i,j]))'
          'elif x.is_Matrix:'
          '    return x.applyfunc(lambda a: _op(a, y, z))'
          'elif y.is_Matrix:'
          '    return y.applyfunc(lambda a: _op(x, a, z))'
          'elif z.is_Matrix:'
          '    return z.applyfunc(lambda a: _op(x, y, a))'
          'else:'
          '    return _op(x, y, z)' ];

  z = python_cmd (cmd, sym(x), sym(y), sym(z));

end


% many tests are in @sym/laguerreL
