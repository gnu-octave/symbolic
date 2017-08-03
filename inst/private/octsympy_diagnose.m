%% Copyright (C) 2017 Colin B. Macdonald
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

function octsympy_diagnose ()
%private function

  fprintf (['\nSymbolic package diagnostics\n============================\n\n' ...
            'Python and SymPy are needed for most features of the Symbolic package.\n\n'])

  fprintf ('Python Interpreter\n------------------\n\n')

  fprintf ('The Python interpreter is currently: "%s".\n\n', sympref ('python'))

  fprintf (['Computers may have more than one Python interpreter installed.  Depending\n' ...
            'on how your system is configured, you may need to select a different one\n' ...
            'using "setenv": e.g., to use Python 3, try\n' ...
            '    setenv PYTHON python3\n    sympref reset\n' ...
            '(see "help sympref")\n\n'])

  pyexec = sympref('python');
  fprintf ('Attempting to run %s -c "print(\\"hello world\\")"\n', pyexec);
  try
    [status, output] = system ([pyexec ' -c "print(\"hello world\")"']);
    status
    output
  catch
    fprintf (['Unfortunately, that failed!  Do you have Python installed?  Try using\n' ...
              '"setenv" as described above and see "help sympref" for more examples.\n'])
    % TODO: does "getenv PATH" work on Windows?  report that output here.
    return
  end

  if ( (status ~= 0) || (~ strcmp(strtrim(output), 'hello world')) )
    fprintf (['That command ran but unfortunately gave unexpected output.  We wanted\n' ...
              'to see "status = 0" and "output = hello world".  File a bug?\n'])
    return
  end

  fprintf ('Good, Python ran correctly.\n')


  fprintf (['\n\nSymPy Python Library\n--------------------\n\n' ...
           'SymPy is a Python library used by Symbolic for almost all features.\n'])

  fprintf ('Attempting to run %s -c "import sympy; print(sympy.__version__)"\n', pyexec);

  minsympyver = '1.7';

  try
    [status, output] = system([pyexec ' -c "import sympy; print(sympy.__version__)"']);
    status
    output
  catch
    % I don't think this should happen given above
    fprintf ('Unfortunately, that command failed to run!')
  end

  if (status ~= 0)
    fprintf (['status was non-zero: probably this means Python cannot import sympy.\n' ...
              'Have you installed SymPy?  Please try to install it and try again.\n' ...
              'If you have installed SymPy, perhaps for a different Python interpreter?\n' ...
              'Try "setenv" as described above to change your python interpreter.\n'])
    return
  end

  spver = strtrim(output);

  fprintf ('SymPy must be at least version %s; you have version %s.\n', ...
           minsympyver, spver);

  % we have no compare_versions on matlab, just assume its ok (!)
  if (~ exist ('OCTAVE_VERSION', 'builtin'))
    disp ('(cannot automatically compare version on Matlab: please verify above)')
  else
    if (compare_versions (spver, minsympyver, '<'))
      disp ('**** Your SymPy is too old! ****')
      disp ('Installed newer version already?  Perhaps it was for a different Python?')
      disp ('Try "setenv" as described above to change your python interpreter.')
      return
    else
      disp ('Your SymPy should work.')
    end
  end

  fprintf ('\nYour kit looks good for running the Symbolic package.  Happy hacking!\n\n')

end
