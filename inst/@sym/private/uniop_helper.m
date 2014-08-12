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

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = uniop_helper(x, scalar_fcn_str)

  % string can either be the name of a function or the definition
  % of a new function.
  if (strncmp(scalar_fcn_str, 'def ', 4))
    cmd = scalar_fcn_str;
  else
    cmd = ['sf = ' scalar_fcn_str];
  end

  cmd = [ cmd '\n' ...
          '(x,) = _ins\n' ...
          'if x.is_Matrix:\n' ...
          '    return (x.applyfunc(lambda a: sf(a)), )\n' ...
          'else:\n' ...
          '    return (sf(x), )' ];

  z = python_cmd (cmd, sym(x));

end
