%% Copyright (C) 2016 Colin B. Macdonald
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
%% @code{@var{info}.raw}: the raw output, for debugging.
%% @end deftypefn

function [A, info] = python_ipc_pytave(what, cmd, varargin)

  persistent show_msg
  persistent have_headers

  info = [];

  if (strcmp(what, 'reset'))
    A = true;
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

  info.prelines = 0;

  if isempty(have_headers)
    pyexec(strjoin({'import sympy as sp',
                    'from sympy import __version__ as spver',
                    'from sympy import *',
                    '_ins = []',
                    'def pyclear():',
                    '    global _ins',
                    '    _ins = []',
                    'def pystore(x):',
                    '    global _ins',
                    '    _ins.append(x[0])',
                    'def pyevalstore(x):',
                    '    global _ins',
                    '    obj = compile(x, "", "eval")',
                    '    _ins.append(eval(obj))'}, newl))
    have_headers = true;
  end

  pycall('pyclear');
  for i= 1:numel(varargin)
    x = varargin{i};
    if(isa(x, 'sym'))
      pycall('pyevalstore', sprintf(char(x)));
    elseif(isstr(x))
      pycall('pyevalstore', sprintf('str("%s")', x));
    else
      pycall('pystore', x);
    end
  end

  s = strjoin(cmd, newl);
  pyexec(s)

  A = check_and_convert('_outs');
end
