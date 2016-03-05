%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @deftypefn {Function File}  {@var{B} =} repmat (@var{A}, @var{n}, @var{m})
%% Build symbolic block matrices.
%%
%% Example:
%% @example
%% @group
%% repmat([1 2 sym(pi)], 2, 3)
%%   @result{} (sym 2×9 matrix)
%%       ⎡1  2  π  1  2  π  1  2  π⎤
%%       ⎢                         ⎥
%%       ⎣1  2  π  1  2  π  1  2  π⎦
%% @end group
%% @end example
%%
%% @seealso{vertcat, horzcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic


function B = repmat(A, n, m)

  if (nargin ~= 3)
    print_usage ();
  end

  cmd = { '(A,n,m) = _ins' ...
          'if A is None or not A.is_Matrix:' ...
          '    A = sp.Matrix([A])' ...
          'L = [A]*m' ...
          'B = sp.Matrix.hstack(*L)' ...
          'L = [B]*n' ...
          'B = sp.Matrix.vstack(*L)' ...
          'return B,' };

  B = python_cmd (cmd, sym(A), int32(n), int32(m));

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

