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

  % TODO: bit wasteful to repeat this every call
  headers = python_header();
  pyexec(headers)

  % load all the inputs into python
  loc = python_copy_vars_to('_ins', false, varargin{:});
  s = strjoin(loc, newl);
  pyexec(s)

  s = strjoin(cmd, newl);
  pyexec(s)
  
  info.raw = pyeval('str(_outs)');
  A = check_and_convert();
end
