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
%% >> min(sym(1), sym(2))
%%    @result{} (sym) 1
%% >> m = min([1 sym(pi)/4 6])
%%    @result{} m = (sym)
%%        π
%%        ─
%%        4
%% >> [m, I] = min([sym(1) 0 6])
%%    @result{} m = (sym) 0
%%    @result{} I = 2
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
      cmd = { 'A = _ins[0]'
              'val, idx = min((val, idx) for (idx, val) in enumerate(A))'
              'return val, idx+1' };
      [z, I] = python_cmd (cmd, A);
    else
      [z, I] = min(A, [], 1);
    end
  elseif (nargin == 2) && (nargout <= 1)
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
            'def myargmin(z):'
            '    return min((val, idx) for (idx, val) in enumerate(z))'
            'if not A.is_Matrix:'
            '    A = sp.Matrix([A])'
            'if dim == 0:'
            '    if (A.cols == 0):'
            '        return (Matrix(0, 0, []), Matrix(0, 0, []))'
            '    if (A.rows == 0):'
            '        return (A, A)'
            '    val_idx_pairs = [myargmin(A.col(i)) for i in range(0, A.cols)]'
            '    m, I = zip(*val_idx_pairs)'
            '    return (Matrix([m]), Matrix([I]))'
            'elif dim == 1:'
            '    if (A.rows == 0):'
            '        return (Matrix(0,0,[]), Matrix(0,0,[]))'
            '    if (A.cols == 0):'
            '        return (A, A)'
            '    val_idx_pairs = [myargmin(A.row(i)) for i in range(0, A.rows)]'
            '    m, I = zip(*val_idx_pairs)'
            '    return (Matrix(m), Matrix(I))' };

    [z, I] = python_cmd (cmd, A, dim - 1);
    I = double(I);
    if (~isempty(I))
      I = I + 1;
    end
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

%!test
%! % index output is double not sym
%! [m, I] = min(sym(2), [], 1);
%! assert (strcmp(class(I), 'double'))
%! [m, I] = max(sym(2), [], 1);
%! assert (strcmp(class(I), 'double'))

%!test
%! % empty rows/columns, I is double
%! A = sym(zeros(0, 4));
%! [m, I] =  min(A, [], 1);
%! assert (strcmp(class(I), 'double'))
%! [m, I] =  max(A, [], 1);
%! assert (strcmp(class(I), 'double'))
%! A = sym(zeros(3, 0));
%! [m, I] =  min(A, [], 2);
%! assert (strcmp(class(I), 'double'))
%! [m, I] =  max(A, [], 2);
%! assert (strcmp(class(I), 'double'))

%!test
%! % index output
%! A = [0 1 9; 10 7 4];
%! B = sym(A);
%! [m1, I1] = min(A);
%! [m2, I2] = min(B);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))
%! [m1, I1] = max(A);
%! [m2, I2] = max(B);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))

%!test
%! % index output, with dim
%! A = [0 1 9; 10 7 4];
%! B = sym(A);
%! [m1, I1] = min(A, [], 1);
%! [m2, I2] = min(B, [], 1);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))
%! [m1, I1] = min(A, [], 2);
%! [m2, I2] = min(B, [], 2);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))
%! [m1, I1] = max(A, [], 1);
%! [m2, I2] = max(B, [], 1);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))
%! [m1, I1] = max(A, [], 2);
%! [m2, I2] = max(B, [], 2);
%! assert (isequal (I1, I2))
%! assert (isequal (m1, double(m2)))

%!test
%! % empty columns
%! A = sym(zeros(0, 4));
%! [m, I] =  min(A, [], 1);
%! assert (isequal (size(m), [0 4]))
%! assert (isequal (size(I), [0 4]))
%! [m, I] =  max(A, [], 1);
%! assert (isequal (size(m), [0 4]))
%! assert (isequal (size(I), [0 4]))

%!test
%! % empty rows
%! A = sym(zeros(3, 0));
%! [m, I] =  min(A, [], 2);
%! assert (isequal (size(m), [3 0]))
%! assert (isequal (size(I), [3 0]))
%! [m, I] =  max(A, [], 2);
%! assert (isequal (size(m), [3 0]))
%! assert (isequal (size(I), [3 0]))

%!test
%! % another empty case
%! % we differ slightly from double which gives 1x0/0x1
%! A = sym(zeros(3, 0));
%! [m, I] =  min(A, [], 1);
%! assert (isempty (m))
%! assert (isempty (I))
%! A = sym(zeros(0, 3));
%! [m, I] =  min(A, [], 2);
%! assert (isempty (m))
%! assert (isempty (I))
