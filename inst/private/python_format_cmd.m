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

function s = python_format_cmd(cmd, tryexcept)
%private function

  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.

  if (nargin == 1)
    tryexcept = true;
  end

  if (~tryexcept)
    %% no error checking
    s = cmd;
  else
    %% with try-except block

    % replace blank lines w/ empty comments
    I = cellfun(@isempty, cmd);
    % cmd(I) = '#';  % fails on matlab
    cmd(I) = repmat({'#'}, 1, nnz(I));

    cmd = indent_lines(cmd, 4);

    s = { 'try:' ...
          cmd{:} ...
          'except:' ...
          '    octoutput_drv("PYTHON: Error in cmd")' ...
          '    myerr(sys.exc_info())' ...
          '    raise' };
  end



