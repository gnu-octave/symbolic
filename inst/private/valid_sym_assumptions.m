%% Copyright (C) 2015, 2019 Colin B. Macdonald
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
%% @defun valid_sym_assumptions ()
%% Return list of valid assumptions.
%%
%% @end defun

%% Reference: http://docs.sympy.org/dev/modules/core.html

%% FIXME: Maybe in the future remove this file and replace with something else.


function L = valid_sym_assumptions()

  persistent List

  if (isempty(List))

    cmd = {'from sympy.core.assumptions import _assume_defined'
           'return list(_assume_defined),'};
    List = pycall_sympy__ (cmd);

  end

  L = List;

end
