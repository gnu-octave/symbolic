%% Copyright (C) 2016 Colin B. Macdonald
%% Copyright (C) 2016 Abhinav Tripathi
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
%% @deftypefn  {Function File}  {[@var{A}, @var{info}] =} python_ipc_pytave (@dots{})
%% Private helper function for Python IPC.
%%
%% @var{A} is the resulting object, which might be an error code.
%%
%% @var{info} usually contains diagnostics to help with debugging
%% or error reporting.
%%
%% @code{@var{info}.prelines}: the number of lines of header code
%% before the command starts.
%%
%% @end deftypefn

function [A, info] = python_ipc_pytave(what, cmd, varargin)

  persistent show_msg
  persistent have_headers

  info.prelines = 0;

  if (strcmp(what, 'reset'))
    A = true;
    have_headers = [];
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  verbose = ~sympref('quiet');

  if (verbose && isempty(show_msg))
    fprintf('OctSymPy v%s: this is free software without warranty, see source.\n', ...
            sympref('version'))
    disp('Using experimental PyTave communications with SymPy.')
    show_msg = true;
  end

  newl = sprintf('\n');

  if isempty(have_headers)
    pyexec(strjoin({'import sys'
                    'import sympy'
                    'import sympy as sp'
                    'from sympy import __version__ as spver'
                    'from sympy import *'
                    'from sympy.logic.boolalg import Boolean, BooleanFunction'
                    'from sympy.core.relational import Relational'
                    '# temporary? for piecewise support'
                    'from sympy.functions.elementary.piecewise import ExprCondPair'
                    'from sympy.integrals.risch import NonElementaryIntegral'
                    'from sympy.matrices.expressions.matexpr import MatrixElement'
                    '# for hypergeometric'
                    'from sympy.functions.special.hyper import TupleArg'
                    'from sympy.utilities.iterables import uniq'
                    'import copy'
                    'import struct'
                    'import codecs'
                    'from distutils.version import LooseVersion'
                    'def dictdiff(a, b):'
                    '    """ keys from a that are not in b, used by evalpy() """'
                    '    n = dict()'
                    '    for k in a:'
                    '        if not k in b:'
                    '            n[k] = a[k]'
                    '    return n'
                    'def Version(v):'
                    '    # short but not quite right: https://github.com/cbm755/octsympy/pull/320'
                    '    return LooseVersion(v.replace(".dev", ""))'
                  }, newl))
    have_headers = true;
  end

  ins = store_vars_in_python(varargin);
  pyexec (strjoin (cmd, newl));
  outs = pycall ('_fcn', ins);
  A = check_and_convert(outs);
end
