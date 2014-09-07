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

%% -*- texinfo -*-
%% @deftypefn  {Function File}  {[@var{a}, @var{b}, ...] =} python_cmd_string (@var{cmd}, @var{x}, @var{y}, ...)
%% Run some Python command on some objects and return other objects.
%%
%% Warning: deprecated, use @code{python_cmd} and a cell array
%% for multiline code.
%%
%% The string can have newlines for longer commands:
%% @example
%% cmd = [ '(x,) = _ins\n'  ...
%%         'if x.is_Matrix:\n'  ...
%%         '    return ( x.T ,)\n' ...
%%         'else:\n' ...
%%         '    return ( x ,)' ];
%% @end example
%%
%% @seealso{python_cmd}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: python

function varargout = python_cmd_string(cmd, varargin)

  newl = sprintf('\n');

  % The user might or might not have escaped newlines in the command.
  % We want to reliably indent this code to put in a Python function.
  % trouble: this expands \n to newlines within string consts
  % as well as the line endings.
  % FIXME: this is poor: e.g., should skip \\n
  cmd = strrep(cmd, '\n', newl);
  cmd = strtrim(cmd);  % don't want trailing newlines
  cmd = mystrsplit(cmd, {newl});

  [varargout{1:nargout}] = python_cmd(cmd, varargin{:});

end


%!test
%! % general test
%! x = 10; y = 6;
%! cmd = '(x,y) = _ins\nreturn (x+y,x-y)';
%! [a,b] = python_cmd_string (cmd, x, y);
%! assert (a == x + y && b == x - y)

