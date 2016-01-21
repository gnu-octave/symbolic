%% Copyright (C) 2016 Lagu
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
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{tf} =} ismember (@var{x}, @var{S})
%% @deftypefnx {Function File} {@var{Z} =}  ismember (@var{x}, @var{M})
%% Test if an object is contained within a set or a matrix.
%%
%% @seealso{lookup, unique, union, intersect, setdiff, setxor}
%% @end deftypefn

function r = ismember(x, y)

  cmd = {
         'x, y = _ins'
         'if not isinstance(x, sp.MatrixBase):'
         '    return x in y,'
         'elif len(x) == 1:'
         '    return x in y,'
         'for a, b in enumerate(x):'
         '    if x[a] in y:'
         '        x[a] = 1'
         '    else:'
         '        x[a] = 0'
         'return x,'
        };

  r = python_cmd (cmd, sym(x), sym(y));

end
