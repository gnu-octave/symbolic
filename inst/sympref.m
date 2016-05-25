%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @deftypefn  Command {} sympref @var{cmd}
%% @deftypefnx Command {} sympref @var{cmd} @var{args}
%% @deftypefnx Function {@var{r} =} sympref ()
%% @deftypefnx Function {@var{r} =} sympref (@var{cmd})
%% @deftypefnx Function {@var{r} =} sympref (@var{cmd}, @var{args})
%% Preferences for the Symbolic package.
%%
%% @code{sympref} can set or get various preferences and
%% configurations.  The various choices for @var{cmd} and
%% @var{args} are documented below.
%%
%%
%% Get the name of the @strong{Python executable}:
%% @example
%% @comment doctest: +SKIP
%% sympref python
%%   @result{} ans = python
%% @end example
%%
%% This value can be changed by setting the environment variable
%% @code{PYTHON}, which can be configured in the OS, or it can be
%% set within Octave using:
%% @example
%% @comment doctest: +SKIP
%% setenv PYTHON /usr/bin/python
%% setenv PYTHON C:\Python\python.exe
%% sympref reset
%% @end example
%% (In older versions, @code{sympref python /bin/python} could be
%% used: this is deprecated and will be removed in a future version.)
%%
%% If the environment variable is empty or not set, the package
%% uses a default setting (usually @code{python}).
%%
%%
%% @strong{Display} of syms:
%%
%% @example
%% @group
%% sympref display
%%   @result{} ans = unicode
%%
%% @end group
%% @group
%% syms x
%% sympref display flat
%% sin(x/2)
%%   @result{} (sym) sin(x/2)
%%
%% sympref display ascii
%% sin(x/2)
%%   @result{} (sym)
%%          /x\
%%       sin|-|
%%          \2/
%%
%% sympref display unicode
%% sin(x/2)
%%   @result{} (sym)
%%          ⎛x⎞
%%       sin⎜─⎟
%%          ⎝2⎠
%%
%% sympref display default
%% @end group
%% @end example
%%
%% By default, a unicode pretty printer is used to display
%% symbolic expressions.  If that doesn't work (e.g., if you
%% see @code{?} characters) then try the @code{ascii} option.
%%
%%
%% @strong{Communication mechanism}:
%%
%% @example
%% @group
%% sympref ipc
%%   @result{} ans = default
%% @end group
%% @end example
%%
%% The default will typically be the @code{popen2} mechanism which
%% uses a pipe to communicate with Python and should be fairly fast.
%% If that doesn't work, try @code{sympref display system} which is
%% much slower, as a new Python
%% process is started for each operation (many commands use more
%% than one operation).
%% Other options for @code{sympref ipc} include:
%% @itemize
%% @item @code{sympref ipc popen2}: force popen2 choice (e.g.,
%% on Matlab were it would not be the default).
%% @item @code{sympref ipc system}: construct a long string of
%% the command and pass it directly to the python interpreter with
%% the @code{system()} command.  This typically assembles a multiline
%% string for the commands, except on Windows where a long one-line
%% string is used.
%% @item @code{sympref ipc systmpfile}: output the python commands
%% to a @code{tmp_python_cmd.py} file and then call that [for
%% debugging, may not be supported long-term].
%% @item @code{sympref ipc sysoneline}: put the python commands all
%% on one line and pass to @code{python -c} using a call to @code{system()}.
%% [for debugging, may not be supported long-term].
%% @end itemize
%%
%%
%% @strong{Reset}: reset the SymPy communication mechanism.  This can be
%% useful after an error occurs and the connection with Python
%% becomes confused.
%%
%% @example
%% @group
%% sympref reset                              % doctest: +SKIP
%% @end group
%% @end example
%%
%%
%% @strong{Snippets}: when displaying a sym object, we can optionally
%% quote a small part of the SymPy representation:
%%
%% @example
%% @group
%% syms x;  y = [pi x];
%% sympref snippet on
%% y
%%   @result{} y = (sym 1×2 matrix)       “...([[pi, Symbol('x')]])”
%%       [π  x]
%% sympref snippet off
%% y
%%   @result{} y = (sym) [π  x]  (1×2 matrix)
%% sympref snippet default
%% @end group
%% @end example
%%
%%
%% @strong{Default precision}: control the number of digits used by
%% variable-precision arithmetic (see also the @ref{digits} command).
%%
%% @example
%% @group
%% sympref digits          % get
%%   @result{} ans = 32
%% sympref digits 64       % set
%% sympref digits default
%% @end group
%% @end example
%%
%% Be @strong{quiet} by minimizing startup and diagnostics messages:
%% @example
%% @group
%% sympref quiet
%%   @result{} ans = 0
%% sympref quiet on
%% sympref quiet default
%% @end group
%% @end example
%%
%% Report the @strong{version} number:
%%
%% @example
%% @group
%% sympref version
%%   @result{} 2.4.0
%% @end group
%% @end example
%%
%% @seealso{sym, syms}
%% @end deftypefn

function varargout = sympref(cmd, arg)

  persistent settings

  if (isempty(settings))
    settings = 42;
    sympref('defaults')
  end

  if (nargin == 0)
    varargout{1} = settings;
    return
  end


  switch lower(cmd)
    case 'defaults'
      settings = [];
      settings.ipc = 'default';
      settings.whichpython = '';
      sympref ('display', 'default')
      sympref ('digits', 'default')
      sympref ('snippet', 'default')
      sympref ('quiet', 'default')

    case 'version'
      assert (nargin == 1)
      varargout{1} = '2.4.0';

    case 'display'
      if (nargin == 1)
        varargout{1} = settings.display;
      else
        arg = lower (arg);
        if (strcmp (arg, 'default'))
          arg = 'unicode';
          if (ispc () && (~isunix ()))
            % Unicode not working on Windows, Issue #83.
            arg = 'ascii';
          end
        end
        assert(strcmp(arg, 'flat') || strcmp(arg, 'ascii') || ...
               strcmp(arg, 'unicode'))
        settings.display = arg;
      end

    case 'digits'
      if (nargin == 1)
        varargout{1} = settings.digits;
      else
        if (ischar(arg))
          if (strcmpi(arg, 'default'))
            arg = 32;
          else
            arg = str2double(arg);
          end
        end
        arg = int32(arg);
        assert(arg > 0, 'precision must be positive')
        settings.digits = arg;
      end

    case 'snippet'
      if (nargin == 1)
        varargout{1} = settings.snippet;
      else
        if (strcmpi(arg, 'default'))
          settings.snippet = false;  % Should be false for a release
        else
          settings.snippet = tf_from_input(arg);
        end
      end

    case 'quiet'
      if (nargin == 1)
        varargout{1} = settings.quiet;
      else
        if (strcmpi(arg, 'default'))
          settings.quiet = false;
        else
          settings.quiet = tf_from_input(arg);
        end
      end

    case 'python'
      if (nargin ~= 1)
        %error('old syntax ''sympref python'' removed; use ''setenv PYTHON'' instead')
        warning('OctSymPy:deprecation', ...
          '''sympref python foo'' deprecated; use ''setenv PYTHON foo'' instead');
        if (isempty(arg) || strcmp(arg,'[]'))
          settings.whichpython = '';
          sympref('reset')
        else
          settings.whichpython = arg;
          sympref('reset')
        end
        return
      end
      DEFAULTPYTHON = 'python';
      pyexec = getenv('PYTHON');
      if (isempty(pyexec))
        pyexec = settings.whichpython;   % FIXME: deprecated; remove
        if (isempty(pyexec))
          pyexec = DEFAULTPYTHON;
        end
      end
      varargout{1} = pyexec;

    case 'ipc'
      if (nargin == 1)
        varargout{1} = settings.ipc;
      else
        verbose = ~sympref('quiet');
        sympref('reset')
        settings.ipc = arg;
        switch arg
          case 'default'
            msg = 'Choosing the default [autodetect] communication mechanism';
          case 'system'
            msg = 'Forcing the system() communication mechanism';
          case 'popen2'
            msg = 'Forcing the popen2() communication mechanism';
          case 'systmpfile'
            msg = 'Forcing systmpfile ipc: warning: this is for debugging';
          case 'sysoneline'
            msg = 'Forcing sysoneline ipc: warning: this is for debugging';
          otherwise
            msg = '';
            warning('Unsupported IPC mechanism: hope you know what you''re doing')
        end
        if (verbose)
          disp(msg)
        end
      end

    case 'reset'
      verbose = ~sympref('quiet');
      if (verbose)
        disp('Resetting the communication mechanism');
      end
      r = python_ipc_driver('reset', []);

      if (nargout == 0)
        if (~r)
          disp('Problem resetting');
        end
      else
        varargout{1} = r;
      end

    %case 'path'
      %pkg_path = fileparts (mfilename ('fullpath'));
      % or
      %pkg_l = pkg ('list');
      %idx = strcmp ('octsympy', cellfun (@(x) x.name, pkg_l, "UniformOutput", false));
      %if (~ any (idx))
      %  error ('the package %s is not installed', your_pkg);
      %end
      %pkg_path = pkg_l{idx}.dir

    otherwise
      print_usage ();
  end
end


function r = tf_from_input(s)

  if (~ischar(s))
    r = logical(s);
  elseif (strcmpi(s, 'true'))
    r = true;
  elseif (strcmpi(s, 'false'))
    r = false;
  elseif (strcmpi(s, 'on'))
    r = true;
  elseif (strcmpi(s, 'off'))
    r = false;
  elseif (strcmpi(s, '[]'))
    r = false;
  else
    r = str2double(s);
    assert(~isnan(r), 'invalid expression to convert to bool')
    r = logical(r);
  end
end


%!test
%! % test quiet, side effect of making following tests a bit less noisy!
%! sympref quiet on
%! a = sympref('quiet');
%! assert(a == 1)

%% Test for correct line numbers in Python exceptions.  These first tests
%% happen with the default ipc---usually popen2.  We don't explicitly test
%% popen2 because test suite should be portable.
%!error <line 1> python_cmd('raise ValueError');
%!error <line 1> python_cmd('raise ValueError', sym('x'));
%!error <line 1> python_cmd('raise ValueError', sym([1 2 3; 4 5 6]));
%!error <line 1> python_cmd('raise ValueError', {1; 1; 1});
%!error <line 1> python_cmd('raise ValueError', struct('a', 1, 'b', 'word'));
%!error <line 2> python_cmd( {'x = 1' 'raise ValueError'} );
%!error <line 3> python_cmd( {'x = 1' 'pass' '1/0'} );
%!error <line 3> python_cmd( {'a=1' 'b=1' 'raise ValueError' 'c=1' 'd=1'} );


%!test
%! % system should work on all system, but just runs sysoneline on windows
%! fprintf('\nRunning some tests that reset the IPC and produce output\n');
%! sympref('ipc', 'system');
%! syms x

%!error <line 1> python_cmd('raise ValueError')
%!error <line 1> python_cmd('raise ValueError', sym('x'))
%!error <line 1> python_cmd('raise ValueError', struct('a', 1, 'b', 'word'))


%!test
%! % sysoneline should work on all systems
%! sympref('ipc', 'sysoneline');
%! syms x

%!error <line 1> python_cmd('raise ValueError')
%!error <line 1> python_cmd('raise ValueError', struct('a', 1, 'b', 'word'))


%!test
%! sympref('ipc', 'systmpfile');
%! syms x
%! delete('tmp_python_cmd.py')

%!error <line 1> python_cmd('raise ValueError')
%!error <line 1> python_cmd('raise ValueError', struct('a', 1, 'b', 'word'))

%!test
%! % (just to cleanup after the error tests)
%! delete('tmp_python_cmd.py')

%!test
%! sympref('defaults')
%! assert(strcmp(sympref('ipc'), 'default'))
%! sympref('quiet', 'on')

%!test
%! syms x
%! r = sympref('reset');
%! syms x
%! assert(r)
%! % ok, can be noisy again
%! sympref('quiet', 'default')
