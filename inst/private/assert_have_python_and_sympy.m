%% Copyright (C) 2016-2017 Colin B. Macdonald
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
%% @defun assert_have_python_and_sympy (pyexec, verbose)
%% Check that Python and SymPy are installed and working.
%%
%% @seealso{sympref}
%% @end defun

function assert_have_python_and_sympy (pyexec, verbose)

  minsympyver = '1.0';

  if (verbose)
    disp ('')
    disp ('Symbolic package diagnostics')
    disp ('============================')
    disp ('')
    disp ('Python and SymPy are needed for most features of the Symbolic package.')
    disp ('')
    fprintf ('The Python interpreter is currently: "%s".\n', pyexec)
    disp ('')
    disp ('Computers may have more than one Python interpreter installed.  Depending')
    disp ('on how your system is configured, you may need to select a different one.')
    disp ('See "help sympref" for details, but for example, to use Python 3, try')
    disp ('    setenv PYTHON python3')
    disp ('    sympref reset')
    disp ('')
    fprintf ('Attempting to run %s -c "print(\\"Python says hello\\")"\n\n', pyexec);
  end

  [status, output] = system ([pyexec ' -c "print(\"Python says hello\")"']);
  if (verbose)
    status
    output
  end

  if ( (status ~= 0) || (~ strcmp(strtrim(output), 'Python says hello')) )
    if (~ verbose)
      error ('OctSymPy:nopython', ...
             ['Cannot run the Python executable "%s"\n' ...
              '    Try "sympref diagnose" for more information.'], ...
             pyexec)
    end
    disp ('')
    disp ('Unfortunately, that command failed!')
    disp ('We expected to see "status = 0" and "output = Python says hello".')
    disp ('Is there an error message above?  Do you have Python installed?')
    disp ('Please try using "setenv" as described above.')
    % TODO: does "getenv PATH" work on Windows?  report that output here.
    return
  end

  if (verbose)
    disp ('Good, Python ran correctly.')
    disp ('')
    disp ('')
    disp ('SymPy Python Library')
    disp ('--------------------')
    disp ('')
    disp ('SymPy is a Python library used by Symbolic for almost all features.')
    disp ('')
    fprintf ('Attempting to run %s -c "import sympy; print(sympy.__version__)"\n\n', pyexec);
  end

  [status, output] = system([pyexec ' -c "import sympy; print(sympy.__version__)"']);
  if (verbose)
    status
    output
  end

  if (status ~= 0)
    if (~ verbose)
      error ('OctSymPy:nosympy', ...
            ['Python cannot import SymPy: have you installed SymPy?\n' ...
             '    Try "sympref diagnose" for more information.'])
    end
    disp ('')
    disp ('Unfortunately status was non-zero: probably Python cannot import sympy.')
    disp ('Have you installed SymPy?  Please try to install it and try again.')
    disp ('If you have installed SymPy, perhaps for a different Python interpreter?')
    disp ('Please try "setenv" as described above to change your python interpreter.')
    return
  end

  spver = strtrim(output);

  if (verbose)
    fprintf ('SymPy must be at least version %s; you have version %s.\n', ...
             minsympyver, spver);
  end

  if (~ exist ('OCTAVE_VERSION', 'builtin'))
    % no compare_versions on matlab, just assume its ok (!)
    if (verbose)
      disp ('We cannot automatically compare versions on Matlab: please verify above.')
    end
  else
    if (compare_versions (spver, minsympyver, '<'))
      if (~ verbose)
        error('OctSymPy:oldsympy', ...
              ['SymPy version %s found but is too old (%s required)\n' ...
               '    Try "sympref diagnose" for more information.'], ...
              spver, minsympyver)
      end
      disp ('**** Your SymPy is too old! ****')
      disp ('Installed newer version already?  Perhaps it was for a different Python?')
      disp ('Try "setenv" as described above to change your python interpreter.')
      return
    end
  end

  if (verbose)
    fprintf ('\nYour kit looks good for running the Symbolic package.  Happy hacking!\n\n')
  end
end
