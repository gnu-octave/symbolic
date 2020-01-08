%% Copyright (C) 2014-2020 Colin B. Macdonald
%% Copyright (C) 2017 NVS Abhilash
%% Copyright (C) 2017 Mike Miller
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
%% Run @strong{diagnostics} on your system:
%% @example
%% @comment doctest: +SKIP
%% sympref diagnose
%%   @print{} ...
%% @end example
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
%% This default depends on your system.  If you have loaded the
%% @uref{https://gitlab.com/mtmiller/octave-pythonic, Pythonic package},
%% the default will be the @code{native} mechanism.
%% Otherwise, typically the @code{popen2} mechanism will be used,
%% which uses a pipe to communicate with Python.
%% If that doesn't work, try @code{sympref ipc system} which is
%% much slower, as a new Python process is started for each operation.
%%
%% Other options for @code{sympref ipc} include:
%% @itemize
%% @item @code{sympref ipc popen2}: force popen2 choice.
%% @item @code{sympref ipc native}: use the @code{py} interface to
%% interact directly with an embedded Python interpreter, e.g.,
%% provided by the Octave Pythonic package.
%% @item @code{sympref ipc system}: construct a long string of
%% the command and pass it directly to the python interpreter with
%% the @code{system()} command.  This typically assembles a multiline
%% string for the commands, except on Windows where a long one-line
%% string is used.
%% @item @code{sympref ipc systmpfile}: output the python commands
%% to a @code{tmp_python_cmd.py} file and then call that.
%% For debugging, will not be supported long-term.
%% @item @code{sympref ipc sysoneline}: put the python commands all
%% on one line and pass to @code{python -c} using a call to @code{system()}.
%% For debugging, will not be supported long-term.
%% @end itemize
%%
%% Except for @code{native}, all of these communication interfaces
%% depend on the current @strong{Python executable}, which can be queried:
%% @example
%% @comment doctest: +SKIP
%% sympref python
%%   @result{} ans = python
%% @end example
%% Changing this might help if you've installed
%% a local Python interpreter somewhere else on your system.
%% The value can be changed by setting the environment variable
%% @code{PYTHON}, which can be configured in the OS, or it can be
%% set within Octave using:
%% @example
%% @comment doctest: +SKIP
%% setenv PYTHON python3
%% setenv PYTHON $@{HOME@}/.local/bin/python
%% setenv PYTHON C:\Python\python.exe
%% sympref reset
%% @end example
%% If the environment variable is empty or not set, the package
%% uses a default setting (often @code{python}).
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
%%   @result{} 2.9.0
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

  if (isstruct (cmd))
    assert (isequal (sort (fieldnames (cmd)), ...
      sort ({'ipc'; 'display'; 'digits'; 'quiet'})), ...
      'sympref: structure has incorrect field names')
    settings = [];
    sympref ('quiet', cmd.quiet)
    sympref ('display', cmd.display)
    sympref ('digits', cmd.digits)
    sympref ('ipc', cmd.ipc)
    return
  end

  switch lower(cmd)
    case 'defaults'
      settings = [];
      settings.ipc = 'default';
      sympref ('display', 'default')
      sympref ('digits', 'default')
      sympref ('quiet', 'default')

    case 'version'
      assert (nargin == 1)
      varargout{1} = '2.9.0';

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
      warning ('OctSymPy:deprecated', ...
               'Debugging mode "snippet" has been removed');

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
        error('old syntax ''sympref python'' removed; use ''setenv PYTHON'' instead')
      end
      pyexec = getenv('PYTHON');
      if (isempty(pyexec))
        pyexec = defaultpython ();
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
          case 'native'
            msg = 'Forcing the native Python/C API communication mechanism';
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
            if (~ ischar (arg))
              arg = num2str (arg);
            end
            warning('OctSymPy:sympref:invalidarg', ...
                    'Unsupported IPC mechanism ''%s'': hope you know what you''re doing', ...
                    arg)
        end
        if (verbose)
          disp(msg)
        end
      end

    case 'reset'
      verbose = ~sympref('quiet');
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

    case 'diagnose'
      if (strcmp (lower (sympref ('ipc')), 'default') && ...
          exist ('pyversion') && exist ('pyexec') && exist ('pyeval'))
        % TODO: see note in ipc_native
        assert_pythonic_and_sympy (true)
      else
        assert_have_python_and_sympy (sympref ('python'), true)
      end

    otherwise
      error ('sympref: invalid preference or command ''%s''', lower (cmd));
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


%!shared sympref_orig
%! sympref_orig = sympref ();

%!test
%! % test quiet, side effect of making following tests a bit less noisy!
%! sympref quiet on
%! a = sympref('quiet');
%! assert(a == 1)

%% Test for correct line numbers in Python exceptions.  These first tests
%% happen with the default ipc---usually popen2.  We don't explicitly test
%% popen2 because test suite should be portable.
%!error <line 1> pycall_sympy__ ('raise ValueError');
%!error <line 1> pycall_sympy__ ('raise ValueError', sym('x'));
%!error <line 1> pycall_sympy__ ('raise ValueError', sym([1 2 3; 4 5 6]));
%!error <line 1> pycall_sympy__ ('raise ValueError', {1; 1; 1});
%!error <line 1> pycall_sympy__ ('raise ValueError', struct('a', 1, 'b', 'word'));
%!error <line 2> pycall_sympy__ ( {'x = 1' 'raise ValueError'} );
%!error <line 3> pycall_sympy__ ( {'x = 1' 'pass' '1/0'} );
%!error <line 3> pycall_sympy__ ( {'a=1' 'b=1' 'raise ValueError' 'c=1' 'd=1'} );

%% Test for correct line error in Python exceptions.
%!error <raise ValueError> pycall_sympy__ ('raise ValueError');
%!error <raise ValueError> pycall_sympy__ ('raise ValueError', sym('x'));
%!error <raise ValueError> pycall_sympy__ ('raise ValueError', sym([1 2 3; 4 5 6]));
%!error <raise ValueError> pycall_sympy__ ('raise ValueError', {1; 1; 1});
%!error <raise ValueError> pycall_sympy__ ('raise ValueError', struct('a', 1, 'b', 'word'));
%!error <raise ValueError> pycall_sympy__ ( {'x = 1' 'raise ValueError'} );
%!error <1/0> pycall_sympy__ ( {'x = 1' 'pass' '1/0'} );
%!error <raise ValueError> pycall_sympy__ ( {'a=1' 'b=1' 'raise ValueError' 'c=1' 'd=1'} );

%!test
%! % system should work on all system, but just runs sysoneline on windows
%! sympref('ipc', 'system');
%! syms x

%!error <line 1> pycall_sympy__ ('raise ValueError')
%!error <line 1> pycall_sympy__ ('raise ValueError', sym('x'))
%!error <line 1> pycall_sympy__ ('raise ValueError', struct('a', 1, 'b', 'word'))

%!error <c=1; raise ValueError> pycall_sympy__ ({'a=1' 'b=1' 'c=1; raise ValueError' 'd=1'});


%!test
%! % sysoneline should work on all systems
%! sympref('ipc', 'sysoneline');
%! syms x

%!error <line 1> pycall_sympy__ ('raise ValueError')
%!error <line 1> pycall_sympy__ ('raise ValueError', struct('a', 1, 'b', 'word'))


%!test
%! sympref('ipc', 'systmpfile');
%! syms x
%! delete('tmp_python_cmd.py')

%!error <line 1> pycall_sympy__ ('raise ValueError')
%!error <line 1> pycall_sympy__ ('raise ValueError', struct('a', 1, 'b', 'word'))

%!test
%! % (just to cleanup after the error tests)
%! delete('tmp_python_cmd.py')

%!test
%! s = warning ('off', 'OctSymPy:sympref:invalidarg');
%! sympref ('ipc', 'bogus');
%! assert (strcmp (sympref ('ipc'), 'bogus'))
%! warning (s)

%!error <invalid ipc mechanism> syms ('x')

%!test
%! sympref('defaults')
%! assert(strcmp(sympref('ipc'), 'default'))
%! sympref('quiet', 'on')

%!test
%! % restore sympref from structure
%! old = sympref ();
%! sympref ('display', 'ascii');
%! sympref ('digits', 64);
%! old = orderfields (old);  % re-ordering the fields should be ok
%! sympref (old);
%! new = sympref ();
%! assert (isequal (old, new))

%!error <incorrect field names>
%! s.a = 'hello';
%! s.b = 'world';
%! sympref (s)

%!test
%! syms x
%! r = sympref('reset');
%! % restore original sympref settings
%! sympref ('ipc',   sympref_orig.ipc);
%! syms x
%! sympref ('quiet', sympref_orig.quiet);
%! assert(r)

%!error <invalid preference or command> sympref ('nosuchsetting')
%!error <invalid preference or command> sympref ('nosuchsetting', true)
