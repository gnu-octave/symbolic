%% Copyright (C) 2014-2019 Colin B. Macdonald
%% Copyright (C) 2018 Mike Miller
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
%% @deftypefun {[@var{A}, @var{info}] =} python_ipc_popen2 (@dots{})
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
%% @end deftypefun

function [A, info] = python_ipc_popen2(what, cmd, varargin)

  persistent fin fout pid

  py_startup_timeout = 30;  % seconds

  verbose = ~sympref('quiet');

  info = [];

  if (strcmp(what, 'reset'))
    if (~isempty(pid))
      if (verbose)
        disp ('Closing the Python communications link.')
      end
    end
    if (~isempty(fin))
      % produces a single newline char: not sure why
      t = fclose(fin); fin = [];
      waitpid(pid);
      pid = [];
      A = (t == 0);
    else
      A = true;
    end
    if (~isempty(fout))
      t = fclose(fout); fout = [];
      A = A && (t == 0);
    end
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  newl = sprintf('\n');

  if isempty(pid)
    if (verbose)
      fprintf ('Symbolic pkg v%s: ', sympref('version'))
    end
    pyexec = sympref('python');

    assert_have_python_and_sympy (pyexec)

    % formatting matters
    args = {'-i', '-c', 'import sys; sys.ps1=''''; sys.ps2='''''};
    [fin, fout, pid] = popen2 (pyexec, args);
    fflush (stdout);

    if (pid < 0)
      error('popen2() failed');
    end

    headers = python_header();
    fputs (fin, headers);
    fprintf (fin, '\n\n');
    %fflush(fin);

    % print a block then read it to make sure we're live
    fprintf (fin, 'octoutput_drv(("Communication established.", sympy.__version__, sys.version))\n\n');
    fflush(fin);
    % if any exceptions in start-up, we probably get those instead
    [out, err] = readblock(fout, py_startup_timeout);
    if (err)
      error('OctSymPy:python_ipc_popen2:timeout', ...
        'ipc_popen2: something wrong? timed out starting python')
    end
    A = extractblock(out);
    if (iscell(A) && strcmp(A{1}, 'Communication established.'))
      if (verbose)
        fprintf ('Python communication link active, SymPy v%s.\n', A{2});
      end
    elseif (iscell(A) && strcmp(A{1}, 'INTERNAL_PYTHON_ERROR'))
      info.raw = out;
      % We want to return so that pycall_sympy__ can report the error instead of us.
      % But if cannot load python_header correctly, we cannot assume the pipe is
      % ok (e.g., probably have other errors sitting on the stdout).  So reset.
      python_ipc_popen2('reset');
      return
    else
      A
      out
      python_ipc_popen2('reset');
      error('ipc_popen2: something unexpected has gone wrong in starting python')
    end
  end



  %% load all the inputs into python as pickles
  % they will be in the list '_ins'
  % there is a try-except block here, sends a block if sucessful
  loc = python_copy_vars_to('_ins', true, varargin{:});
  write_lines(fin, loc, true);
  fflush(fin);
  [out, err] = readblock(fout, inf);
  if (err)
    error('OctSymPy:python_ipc_popen2:xfer', ...
      'ipc_popen2: xfer vars: something wrong? timed out?')
  end

  %% did we succeed in copying all the inputs?
  A = extractblock(out);
  if (ischar(A) && strcmp(A, 'PYTHON: successful variable import'))
    % pass
  elseif (iscell(A) && strcmp(A{1}, 'INTERNAL_PYTHON_ERROR'))
    info.raw = out;
    % the pipe should still be in working order, no need to reset
    return
  else
    disp ('Debugging output:')
    A
    out
    msg = ['ipc_popen2: something unexpected happened sending variables to python.\n' ...
           '    This can happen after interrupting with Ctrl-C.\n' ...
           '    Do "sympref reset" and try your command again.'];
    error (sprintf (msg))
  end

  % The number of lines of code before the command itself: because
  % we send variables before, this is always zero.
  info.prelines = 0;

  % code for output, or perhaps a thrown error
  output_code = python_copy_vars_from('_outs');

  % cmd is a snippet of python code defining a function '_fcn'
  cmd = [cmd {''} '_outs = _fcn(_ins)'];
  write_lines(fin, cmd, true)

  write_lines(fin, output_code, true)

  fflush(fin);
  [out, err] = readblock(fout, inf);
  if (err)
    error('OctSymPy:python_ipc_popen2:cmderr', ...
      'ipc_popen2: cmd error? read block returned error');
  end
  A = extractblock(out);
  info.raw = out;
