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

function assert_have_python_and_sympy(pyexec)
%private function

  [st, out] = system([pyexec ' -c "print(\"hello world\")"']);
  if ( (st ~= 0) || (~ strcmp(strtrim(out), 'hello world')) )
    error('OctSymPy:nopython', ...
          ['Cannot run the Python executable "%s"\n' ...
           '    Try "sympref diagnose" for more information.'], ...
          pyexec)
  end


  minsympyver = '1.0';

  [st, out] = system([pyexec ' -c "import sympy; print(sympy.__version__)"']);

  if (st ~= 0)
    error('OctSymPy:nosympy', ...
          ['Python cannot import SymPy: have you installed SymPy?\n' ...
           '    Try "sympref diagnose" for more information.'])
  else
    spver = strtrim(out);
    % we have no compare_versions on matlab, just assume its ok (!)
    if (exist ('OCTAVE_VERSION', 'builtin') & ...
        (compare_versions (spver, minsympyver, '<')))
      error('OctSymPy:oldsympy', ...
            ['SymPy version %s found but is too old (%s required)\n' ...
             '    Try "sympref diagnose" for more information.'], ...
            spver, minsympyver)
    end
  end

end
