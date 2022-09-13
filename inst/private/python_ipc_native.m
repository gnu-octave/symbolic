%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2021 Johannes Maria Frank
%% Copyright (C) 2022 Chris Gorman
%% Copyright (C) 2022 Alex Vong
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
                    'try:'
                    '    # quick fix for https://github.com/cbm755/octsympy/issues/1053'
                    '    # TODO: investigate the sym ctor in this case, likely a better fix in there'
                    '    from sympy.core.symbol import Str'
                    'except ImportError:'
                    '    pass'
                    'import copy'
                    'import struct'
                    'import codecs'
                    'try:'
                    '    from packaging.version import Version'
                    'except ImportError:'
		    '    try:'
		    '        from sympy.external.importtools import version_tuple as Version'
		    '    except ImportError:'
                    '        from distutils.version import LooseVersion'
                    '        def Version(v):'
                    '            return LooseVersion(v.replace(".dev", ""))'
                    'import itertools'
                    'import collections'
                    'from re import split'
                    '# patch pretty printer, issue #952'
                    'from sympy.printing.pretty.pretty import PrettyPrinter'
                    '_mypp = PrettyPrinter'
                    'def _my_rev_print(cls, f, **kwargs):'
                    '    g = f.func(*reversed(f.args), evaluate=False)'
                    '    return cls._print_Function(g, **kwargs)'
                    '_mypp._print_LambertW = lambda cls, f: _my_rev_print(cls, f, func_name="lambertw")'
                    '_mypp._print_sinc = lambda cls, f: cls._print_Function(f.func(f.args[0]/sp.pi, evaluate=False))'
                    'del _mypp'
                    'def dbout(l):'
                    '    # should be kept in sync with the same function'
                    '    # defined in inst/private/python_header.py'
                    '    sys.stderr.write("pydebug: " + str(l) + "\n")'
                    'def make_matrix_or_array(it_of_it, dbg_no_array=False):'
                    '    # should be kept in sync with the same function'
                    '    # defined in inst/private/python_header.py'
                    '    # FIXME: dbg_no_array is currently used for debugging,'
                    '    # remove it once sympy drops non-Expr supp in Matrix'
                    '    """'
                    '    Given an iterable of iterables of syms IT_OF_IT'
                    '    If all elements of IT_OF_IT are Expr,'
                    '    construct the corresponding Matrix.'
                    '    Otherwise, construct the corresponding 2D array.'
                    '    """'
                    '    ls_of_ls = [[elt for elt in it] for it in it_of_it]'
                    '    elts = flatten(ls_of_ls, levels=1)'
                    '    if Version(spver) <= Version("1.11.1"):'
                    '        # never use Array on older SymPy'
                    '        dbg_no_array = True'
                    '    if (dbg_no_array'
                    '        or all(isinstance(elt, Expr) for elt in elts)):'
                    '        return Matrix(ls_of_ls)'
                    '    else:'
                    '        dbout(f"make_matrix_or_array: making 2D Array...")'
                    '        return Array(ls_of_ls)'
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
