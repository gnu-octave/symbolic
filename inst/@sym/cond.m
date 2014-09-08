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
%% @deftypefn  {Function File} {@var{k} =} cond (@var{a})
%% Symbolic condition number of a symbolic matrix.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function k = cond(A)

  cmd = [ '(A,) = _ins\n'  ...
          'if not A.is_Matrix:\n' ...
          '    A = sp.Matrix([A])\n' ...
          'return (A.condition_number(),)' ];

  k = python_cmd_string (cmd, sym(A));

end


%!test
%! A = [1 2; 3 4];
%! B = sym(A);
%! k1 = cond(A);
%! k2 = cond(B);
%! k3 = double(k2);
%! assert (k1 - k3 <= 100*eps)

%!test
%! % matrix with symbols
%! syms x positive
%! A = [x 0; sym(0) 2*x];
%! k1 = cond(A);
%! assert (isequal (k1, sym(2)))
