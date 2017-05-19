%% Copyright (C) 2014 Colin B. Macdonald
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

function s = python_copy_vars_from(out, tryexcept)
%private function

  if (nargin == 1)
    tryexcept = true;
  end

  if (~tryexcept)
    %% no error checking
    s = { sprintf('octoutput_drv(%s)', out) };
  else
    %% with try-except block
    s = { 'try:' ...
          sprintf('    octoutput_drv(%s)', out) ...
          'except:' ...
          '    echo_exception_stdout("while copying variables from Python")' ...
          '    raise'
        };
  end
