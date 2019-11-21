%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {[@var{A}, @var{info}] =} python_ipc_native (@dots{})
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

function [A, info] = python_ipc_native(what, cmd, varargin)

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
    assert_pythonic_and_sympy ()
    fprintf ('Symbolic pkg v%s: ', sympref ('version'))
  end

  newl = sprintf('\n');

  if isempty(have_headers)
    pyexec(strjoin({'import sys'
                    'import sympy'
                    'import mpmath'
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
                    '# for sets'
                    'from sympy.utilities.iterables import uniq'
                    'import copy'
                    'import struct'
                    'import codecs'
                    'from distutils.version import LooseVersion'
                    'import itertools'
                    'import collections'
                    'from re import split'
                    '# patch pretty printer, issue #952'
                    '_mypp = pretty.__globals__["PrettyPrinter"]'
                    'def _my_rev_print(cls, f, **kwargs):'
                    '    g = f.func(*reversed(f.args), evaluate=False)'
                    '    return cls._print_Function(g, **kwargs)'
                    '_mypp._print_LambertW = lambda cls, f: _my_rev_print(cls, f, func_name="lambertw")'
                    '_mypp._print_sinc = lambda cls, f: cls._print_Function(f.func(f.args[0]/sp.pi, evaluate=False))'
                    'del _mypp'
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

  if (verbose && isempty (show_msg))
    fprintf ('using Pythonic interface, SymPy v%s.\n', ...
             char (py.sympy.__version__))
    show_msg = true;
  end

  ins = store_vars_in_python(varargin);
  pyexec (strjoin (cmd, newl));
  outs = pycall ('_fcn', ins);
  A = check_and_convert(outs);
end
