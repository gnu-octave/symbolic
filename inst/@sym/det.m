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
%% @deftypefn  {Function File} {@var{z} =} det (@var{x})
%% Symbolic determinant of a matrix.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = det(x)

  cmd = [ '(A,) = _ins\n'  ...
          'if not A.is_Matrix:\n' ...
          '    A = sp.Matrix([A])\n' ...
          'return ( A.det() ,)\n' ];

  z = python_cmd (cmd, x);

end


%!assert (isequal (det(sym([])), 1))

%!test
%! syms x y real
%! assert (isequal (det([x 5; 7 y]), x*y-35))

%!test
%! syms x
%! assert (isequal (det(x), x))
%! assert (isequal (det(sym(-6)), sym(-6)))

