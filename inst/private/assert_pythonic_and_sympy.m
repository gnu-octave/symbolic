%% Copyright (C) 2019 Colin B. Macdonald
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
%% @defun  assert_pythonic_and_sympy ()
%% @defunx assert_pythonic_and_sympy (verbose)
%% Check that Python and SymPy are installed and working.
%%
%% @seealso{sympref}
%% @end defun

function assert_pythonic_and_sympy (verbose)

  minsympyver = '1.2';

  if (nargin < 1)
    verbose = false;
  end

  if (verbose)
    disp ('')
    disp ('Symbolic package diagnostics')
    disp ('============================')
    disp ('')
    disp ('Python and SymPy are needed for most features of the Symbolic package.')
    disp ('')
    disp ('You seem to have loaded the Pythonic package; we will try to use it')
    disp ('instead of directly calling a Python interpreter.  You can override')
    disp ('this using "sympref" or by unloading Pythonic:')
    disp ('    pkg unload pythonic')
    disp ('or')
    disp ('    sympref ipc popen2')
    disp ('    sympref reset')
    disp ('')
    disp ('Attempting to run "py.str(''Python says hello'')":')
    disp ('')
  end

  try
    output = py.str('Python says hello');
    if (verbose)
      output
    end
    assert (strcmp (strtrim (char (output)), 'Python says hello'))
  catch
    if (~ verbose)
      error ('OctSymPy:nopython', ...
             ['Cannot use the Pythonic "py" command\n' ...
              '    Try "sympref diagnose" for more information.']) ...
    end
    disp ('')
    disp ('Unfortunately, that command failed!')
    disp ('We expected to see "output = [Python object of type str] ... hello"')
    disp ('')
    disp ('  * Are you using the most recent Pythonic?')
    disp ('    check: https://gitlab.com/mtmiller/octave-pythonic')
    disp ('')
    disp ('  * Please try unloading "pythonic" or using "sympref ipc" as above.')
    disp ('')
    return
  end

  if (verbose)
    disp ('')
    disp ('Good, Python ran correctly.')
    disp ('')
    disp ('Python version')
    disp ('--------------')
    disp ('')
    pyversion ()
  else
    pyver = pyversion ();
  end

  if (verbose)
    disp ('')
    disp ('SymPy Python Library')
    disp ('--------------------')
    disp ('')
    disp ('SymPy is a Python library used by Symbolic for almost all features.')
    disp ('')
    disp ('Attempting to run "py.sympy.__version__":')
    disp ('')
  end

  try
    output = py.sympy.__version__;
    if (verbose)
      output
    end
  catch
    if (~ verbose)
      error ('OctSymPy:nosympy', ...
            ['Python cannot import SymPy: have you installed SymPy?\n' ...
             '    Try "sympref diagnose" for more information.'])
    end
    disp ('')
    disp ('Unfortunately we cannot import sympy.')
    disp ('')
    disp ('  * Do you have SymPy installed?  If not, please try to install it and')
    disp ('    try again.')
    disp ('')
    disp ('  * If you do have SymPy installed, maybe it''s installed for a different')
    disp ('    Python environment than the one Pythonic is linked to?  Please try')
    disp ('    without Pythonic as described above.')
    return
  end

  spver = strtrim (char (output));

  if (verbose)
    disp ('')
    fprintf ('SymPy must be at least version %s; you have version %s.\n', ...
             minsympyver, spver);
  end

  if (~ exist ('OCTAVE_VERSION', 'builtin'))
    % no compare_versions on matlab, just assume its ok (!)
    if (verbose)
      disp ('We cannot easily compare versions on your system: please verify the above.')
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
      disp ('Installed newer version already?  Perhaps it was for a different Python')
      disp ('environment?  You could try without Pythonic (see above).')
      return
    end
  end

  if (verbose)
    disp ('')
    disp ('Good, a working version of SymPy is installed.')
    disp ('')
  end

  if (verbose)
    fprintf ('\nYour kit looks good for running the Symbolic package.  Happy hacking!\n\n')
  end
end
