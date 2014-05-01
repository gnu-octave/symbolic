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
%% @deftypefn  {Function File}  {@var{z} =} power (@var{x}, @var{y})
%% Symbolic expression componentwise exponentiation (dot carat).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = power(x, y)

  cmd = [ '(x,y) = _ins\n'                                    ...
          'if x.is_Matrix and y.is_Matrix:\n'                 ...
          '    # FIXME need a copy?\n'                         ...
          '    for i in range(0, len(x)):\n'                  ...
          '        x[i] = x[i]**y[i]\n'                       ...
          '    return ( x ,)\n'                               ...
          'if x.is_Matrix and not y.is_Matrix:\n'             ...
          '    return ( x.applyfunc(lambda a: a**y) ,)\n'     ...
          'if not x.is_Matrix and y.is_Matrix:\n'             ...
          '    return ( y.applyfunc(lambda a: x**a) ,)\n'     ...
          'else:\n'                                           ...
          '    return ( x**y ,)' ];

  z = python_cmd(cmd, sym(x), sym(y));
