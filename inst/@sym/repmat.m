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
%% @deftypefn {Function File}  {@var{B} =} repmat (@var{A}, @var{n}, @var{m})
%% Build symbolic block matrices.
%%
%% @seealso{vertcat, horzcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function B = repmat(A, n, m)

  cmd = [ '(A,n,m) = _ins\n' ...
          'if not A.is_Matrix:\n' ...
          '    A = sp.Matrix([A])\n' ...
          'L = [A]*m\n' ...
          'B = sp.Matrix.hstack(*L)\n' ...
          'L = [B]*n\n' ...
          'B = sp.Matrix.vstack(*L)\n' ...
          'return (B,)' ];

  B = python_cmd_string(cmd, sym(A), int32(n), int32(m));

end


%!test
%! % simple
%! syms x
%! A = [x x x; x x x];
%! assert (isequal (repmat(x, 2, 3), A))

%!test
%! % block cf double
%! A = [1 2 3; 4 5 6];
%! B = sym(A);
%! C = repmat(A, 2, 3);
%! D = repmat(B, 2, 3);
%! assert (isequal (C, D))

