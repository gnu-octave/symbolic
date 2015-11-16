%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{r} =} min (@var{a})
%% @deftypefnx {Function File} {@var{r} =} min (@var{a}, @var{b})
%% @deftypefnx {Function File} {@var{r} =} min (@var{a}, [], @var{dim})
%% Return minimum value of a symbolic vector or vectors.
%%
%% Example:
%% @example
%% @group
%% min(sym(1), sym(2))
%%   @result{} (sym) 1
%% m = min([1 sym(pi)/4 6])
%%   @result{} m = (sym)
%%        π
%%        ─
%%        4
%% [m, I] = min([sym(1) 0 6])   % doctest: +XFAIL
%%   @result{} m = (sym) 0
%%   @result{} I = 2
%% @end group
%% @end example
%%
%% @seealso{max}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [z, I] = min(A, B, dim)

  if (nargin == 1)
    if (isvector(A))
      z = python_cmd ('return min(_ins[0]),', A);
    else
      z = min(A, [], 1);
    end
  elseif (nargin == 2)
    A = sym(A);
    B = sym(B);
    assert (isequal (size(A), size(B)));  % TODO: WIP
    cmd = { '(A, B) = _ins'
            'if not A.is_Matrix:'
            '    A = sp.Matrix([A])'
            'if not B.is_Matrix:'
            '    B = sp.Matrix([B])'
            'M = A.copy()'
            'for i in range(0, A.rows):'
            '    for j in range(0, A.cols):'
            '        M[i,j] = min(A[i,j], B[i,j])'
            'return M,' };
    z = python_cmd (cmd, A, B);

  elseif (nargin == 3)
    assert (isempty (B))
    assert (logical(dim == 1) || logical(dim == 2))

    cmd = { '(A, dim) = _ins'
            'if not A.is_Matrix:'
            '    A = sp.Matrix([A])'
            'if dim == 0:'
            '    m = [min(A.col(i)) for i in range(0, A.cols)]'
            '    m = Matrix([m])'
            'elif dim == 1:'
            '    m = [min(A.row(i)) for i in range(0, A.rows)]'
            '    m = Matrix(m)'
            'return m,' };

    z = python_cmd (cmd, A, dim - 1);

  else
    print_usage ();
  end

end


%!test
%! % scalars with dim
%! a = min(sym(pi), [], 1);
%! b = sym(pi);
%! assert (isequal (a, b));
%! a = min(sym(pi), [], 2);
%! assert (isequal (a, b));
%! a = max(sym(pi), [], 1);
%! assert (isequal (a, b));
%! a = max(sym(pi), [], 2);
%! assert (isequal (a, b));

%!shared A, D
%! D = [0 1 2 3];
%! A = sym(D);

%!test
%! % row vectors
%! assert (isequal (min(A), sym(min(D))))
%! assert (isequal (min(A), sym(0)))
%! assert (isequal (max(A), sym(max(D))))
%! assert (isequal (max(A), sym(3)))

%!test
%! % row vectors with dim
%! assert (isequal (min(A, [], 1), sym(min(D, [], 1))))
%! assert (isequal (min(A, [], 2), sym(min(D, [], 2))))
%! assert (isequal (max(A, [], 1), sym(max(D, [], 1))))
%! assert (isequal (max(A, [], 2), sym(max(D, [], 2))))

%!test
%! % column vectors
%! A = A.';
%! D = D.';
%! assert (isequal (min(A), sym(min(D))))
%! assert (isequal (min(A), sym(0)))
%! assert (isequal (max(A), sym(max(D))))
%! assert (isequal (max(A), sym(3)))

%!test
%! % row vectors with dim
%! assert (isequal (min(A, [], 1), sym(min(D, [], 1))))
%! assert (isequal (min(A, [], 2), sym(min(D, [], 2))))
%! assert (isequal (max(A, [], 1), sym(max(D, [], 1))))
%! assert (isequal (max(A, [], 2), sym(max(D, [], 2))))

%!shared

%!test
%! % empty
%! a = min(sym([]));
%! assert(isempty(a))
%! a = max(sym([]));
%! assert(isempty(a))

%!test
%! % matrix
%! A = [1 4 6; 2 2 5];
%! A = sym(A);
%! assert (isequal (min(A), sym([1 2 5])))
%! assert (isequal (min(A, [], 1), sym([1 2 5])))
%! assert (isequal (min(A, [], 2), sym([1; 2])))
%! assert (isequal (max(A), sym([2 4 6])))
%! assert (isequal (max(A, [], 1), sym([2 4 6])))
%! assert (isequal (max(A, [], 2), sym([6; 5])))
