%% Copyright (C) 2016, 2019 Colin B. Macdonald
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

function r = uniop_bool_helper(x, scalar_fcn, opt, varargin)
% SCALAR_FCN can either be the name of a function or a lambda
% definition of a new function.  It can be multiline cell array
% defining a a new function called "sf".
%
% Many SymPy commands return True/False/None (or S.true/S.false/None),
% where None is used for "don't know" or "can't tell".
% The string OPT describes what to do about this.
%   'bool': the default, always return Octave bool (logical) array,
%           maps None to false.
%   'sym': always return symbolic array, which might contain True,
%          False, None.
%   'symIfAnyNone': if the result has any None, return a symbolic
%                   array, otherwise return a bool array.
%
% If you'd like to raise an error on None, do so in SCALAR_FCN.
% See isprime.m for example.
%
% Any additional arguments after OPT are passed to SCALAR_FCN as-is.

  if (iscell(scalar_fcn))
    cmd = scalar_fcn;
  else
    cmd = {['sf = ' scalar_fcn]};
  end

  if ((nargin < 3) || isempty(opt))
    opt = 'bool';
  end

  switch opt
    case 'bool'
      cmd = [ cmd
              'x = _ins[0]'
              'pp = _ins[1:]'
              'if x is not None and x.is_Matrix:'
              '    # bool will map None to False'
              '    return [bool(sf(a, *pp)) for a in x.T],'
              'return bool(sf(x, *pp))' ];

      r = pycall_sympy__ (cmd, x, varargin{:});

      if (~isscalar(x))
        r = reshape(cell2mat(r), size(x));
      end

    case 'sym'
      warning('FIXME: not working for scalars')

      cmd = [ cmd
              'x = _ins[0]'
              'pp = _ins[1:]'
              'if x if not None and x.is_Matrix:'
              '    return x.applyfunc(sf, *pp)'
              'return sf(x, *pp)' ];

      r = pycall_sympy__ (cmd, x, varargin{:});

    case 'symIfAnyNone'
      error('FIXME: not implemented')

    otherwise
      error('uniop_bool_helper: option "%s" not implemented', opt)

  end
end
