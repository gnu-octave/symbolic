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

function s = def_each_elem_binary(x, n)
%private

  % FIXME: Deprecated? use binop_helper

  s = { 'def _each_elem_binary(x, y, f):' ...
        '    if x.is_Matrix and y.is_Matrix:' ...
        '        z = x.copy()' ...
        '        for i in range(0, len(x)):' ...
        '            z[i] = f(x[i], y[i])' ...
        '        return z,' ...
        '    if x.is_Matrix and not y.is_Matrix:' ...
        '        return x.applyfunc(lambda a: f(a, y)),' ...
        '    if not x.is_Matrix and y.is_Matrix:' ...
        '        return n.applyfunc(lambda a: f(x, a)),' ...
        '    else:' ...
        '        return f(x, y),' };

end
