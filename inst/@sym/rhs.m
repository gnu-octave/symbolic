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
%% @deftypefn  {Function File} {@var{L} =} rhs (@var{f})
%% Right-hand side of symbolic expression.
%%
%% Gives an error if any of the symbolic objects have no right-hand side.
%%
%% @seealso{lhs, children}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function R = rhs(f)

  cmd = {
    'f, = _ins'
    'try:'
    '    if f.is_Matrix:'
    '        return (0, f.applyfunc(lambda a: a.rhs))'
    '    else:'
    '        return (0, f.rhs)'
    'except Exception as e:'
    '    return (1, type(e).__name__ + ": " + str(e))'
    };

  [flag, R] = python_cmd (cmd, f);

  if (flag)
    error(R)
  end

end


%% most tests are in lhs
%!test
%! syms x
%! f = x + 1 == 2*x;
%! assert (isequal (rhs(f), 2*x))

%!error <AttributeError: 'Symbol' object has no attribute 'rhs'>
%! syms x
%! rhs(x)
