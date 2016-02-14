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

function z = uniop_helper(x, scalar_fcn)

  % String can either be the name of a function or a lambda definition
  % of a new function.  It can be multiline cell array defining a
  % a new function called "sf".
  if (iscell(scalar_fcn))
    %assert strncmp(scalar_fcn_str, 'def ', 4)
    cmd = scalar_fcn;
  else
    cmd = {['sf = ' scalar_fcn]};
  end

  % note: cmd is already cell array, hence [ concatenates with it
  cmd = [ cmd
          '(x,) = _ins'
          'if x is not None and x.is_Matrix:'
          '    return x.applyfunc(lambda a: sf(a)),'
          'else:'
          '    return sf(x),' ];

  z = python_cmd (cmd, sym(x));

end
