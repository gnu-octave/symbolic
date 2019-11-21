%% Copyright (C) 2016-2019 Colin B. Macdonald
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
%% @defun  assert_have_python_and_sympy (pyexec)
%% @defunx assert_have_python_and_sympy (pyexec, verbose)
%% Check that Python and SymPy are installed and working.
%%
%% @seealso{sympref}
%% @end defun

function assert_have_python_and_sympy (pyexec, verbose)

  minsympyver = '1.2';

  if (nargin < 2)
    verbose = false;
  end

  if (verbose)
    disp ('')
    disp ('Symbolic package diagnostics')
    disp ('============================')
    disp ('')
    disp ('Python and SymPy are needed for most features of the Symbolic package.')
    disp ('')
    fprintf ('The Python interpreter is currently: "%s".\n', pyexec)
    disp ('')
    disp ('Computers may have more than one Python interpreter installed.  If you')
    disp ('need to, you can select a different one using the PYTHON environment')
    disp ('variable (see "help sympref").  For example, to use Python 2, try')
    disp ('    setenv PYTHON python2')
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
    disp ('')
    disp ('  * Is there an error message above?')
    disp ('')
    disp ('  * Do you have Python installed?')
    disp ('')
    disp ('  * Please try using "setenv" as described above.')
    disp ('')
    disp ('  * Most systems search the PATH environment when looking for commands.')
    disp ('    Your path seems to be:')
    disp ('')
    disp (getenv ('PATH'))

    if (ispc () && (~isunix ()))
      disp ('')
      disp ('  * Did you install the Symbolic bundle for Windows that includes Python?')
      disp ('    Please refer to the installation notes for Windows users at')
      disp ('    <https://github.com/cbm755/octsympy/wiki/Notes-on-Windows-installation>')
    end
    return
  end

  if (verbose)
    disp ('Good, Python ran correctly.')
    disp ('')
    disp ('')
    disp ('Python version')
    disp ('--------------')
    disp ('')
    disp ('Let''s check what version of Python we are calling...')
    disp ('')
    fprintf ('Attempting to run %s -c "import sys; print(sys.version)"\n\n', pyexec);
    [status, output] = system([pyexec ' -c "import sys; print(sys.version)"']);
    status
    output
  end

  if (verbose)
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
    disp ('')
    disp ('  * Is there an error message above?')
    disp ('')
    disp ('  * Do you have SymPy installed?  If not, please try to install it and')
    disp ('    try again.')
    disp ('')
    disp ('  * If you do have SymPy installed, maybe it''s installed for a different')
    disp ('    Python interpreter than the one we found?  Please try "setenv" as')
    disp ('    described above to change your python interpreter.')
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
      disp ('Installed newer version already?  Perhaps it was for a different Python?')
      disp ('Try "setenv" as described above to change your python interpreter.')
      return
    end
  end

  if (verbose)
    disp ('')
    disp ('Good, a working version of SymPy is installed.')
    disp ('')
    disp ('')
    disp ('Python XML Parsing and DOM Support')
    disp ('----------------------------------')
    disp ('')
    disp ('The XML DOM library is used by Symbolic for passing values to and from Python.')
    disp ('Some older versions of Python formatted XML output differently.  As long as you')
    disp ('have any reasonably recent version of Python, this should pass.')
    disp ('')
  end

  script = ['import xml.dom.minidom as minidom; ' ...
            'doc = minidom.parseString(\"<item>value</item>\"); ' ...
            'print(doc.toprettyxml(indent=\"\"))'];

  if (verbose)
    fprintf ('Attempting to run %s -c "%s"\n\n', pyexec, script);
  end

  if (ispc () && (~isunix ()))
    script = strrep (script, '<', '^<');
    script = strrep (script, '>', '^>');
  end

  [status, output] = system([pyexec ' -c "' script '"']);
  if (verbose)
    status
    output
  end

  if (status ~= 0)
    if (~ verbose)
      error ('OctSymPy:noxmldom', ...
             ['Something wrong, perhaps with XML DOM: is this an unusual Python setup?\n' ...
              '    Try "sympref diagnose" for more information.'])
    end
    disp ('')
    disp ('Unfortunately status was non-zero: perhaps Python cannot import xml.dom?')
    disp ('')
    disp ('  * Is there an error message above?')
    disp ('')
    disp ('  * Are you using an unusual Python installation?  If not, please try to')
    disp ('    reinstall it and try again.')
    return
  end

  xmlout = strtrim (output);

  if (isempty (strfind (xmlout, '<item>value</item>')))
    if (~ verbose)
      error ('OctSymPy:oldxmldom', ...
             ['Python XML output is not compatible, probably an old version of Python?\n' ...
              '    Try "sympref diagnose" for more information.'])
    end
    disp ('**** Your Python is too old! ****')
    disp ('')
    disp ('The XML output shown above must have "<item>value</item>" all on one line.')
    disp ('If your Python interpreter is an older release, please try upgrading to a more')
    disp ('recent version.  Symbolic should work with Python 2 (version 2.7.3 or newer)')
    disp ('and Python 3 (version 3.2.3 or newer).')
    return
  end

  if (verbose)
    fprintf ('\nYour kit looks good for running the Symbolic package.  Happy hacking!\n\n')
  end
end
