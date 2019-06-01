%% Copyright (C) 2015, 2016, 2019 Colin B. Macdonald
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
%% @deftypemethod  @@sym {} min (@var{a})
%% @deftypemethodx @@sym {} min (@var{a}, @var{b})
%% @deftypemethodx @@sym {} min (@var{a}, [], @var{dim})
%% @deftypemethodx @@sym {[@var{r}, @var{I}] =} min (@dots{})
%% Return minimum value of a symbolic vector or vectors.
%%
%% Example:
%% @example
%% @group
%% min(sym(1), sym(2))
%%   @result{} (sym) 1
%% m = min([1 sym(pi)/4 6])
%%   @result{} m = (sym)
%%       π
%%       ─
%%       4
%% [m, I] = min([sym(1) 0 6])
%%   @result{} m = (sym) 0
%%   @result{} I = 2
%% @end group
%% @end example
%%
%% @seealso{@@sym/max}
%% @end deftypemethod


function [z, I] = min(A, B, dim)

  if (nargout <= 1)
    if (nargin == 1)
      if (isvector(A))
        z = pycall_sympy__ ('return Min(*_ins[0])', A);
      else
        z = min(A, [], 1);
      end
    elseif (nargin == 2)
      z = elementwise_op('Min', sym(A), sym(B));
    elseif (nargin == 3)
      assert (isempty (B))
      assert (logical(dim == 1) || logical(dim == 2))

      cmd = { '(A, dim) = _ins'
              'if not A.is_Matrix:'
              '    A = sp.Matrix([A])'
              'if dim == 0:'
              '    if A.rows == 0:'
              '        return A'
              '    return Matrix([[Min(*A.col(i)) for i in range(0, A.cols)]])'
              'elif dim == 1:'
              '    if A.cols == 0:'
              '        return A'
              '    return Matrix([Min(*A.row(i)) for i in range(0, A.rows)])' };
      z = pycall_sympy__ (cmd, A, dim - 1);
    else
      print_usage ();
    end
    return
  end

  % We have second output: need the index of the minimum, can't use "Min"
  if (nargin == 1)
    if (isvector(A))
      cmd = { 'A = _ins[0]'
              'val, idx = min((val, idx) for (idx, val) in enumerate(A))'
              'return val, idx+1' };
      [z, I] = pycall_sympy__ (cmd, A);
    else
      [z, I] = min(A, [], 1);
    end
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

    [z, I] = pycall_sympy__ (cmd, A, dim - 1);
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

%!test
%! % empty without index output
%! A = sym(zeros(3, 0));
%! assert (isempty (min (A, [], 1)))
%! assert (isempty (max (A, [], 1)))
%! assert (isempty (min (A, [], 2)))
%! assert (isempty (max (A, [], 2)))
%! A = sym(zeros(0, 3));
%! assert (isempty (min (A, [], 1)))
%! assert (isempty (max (A, [], 1)))
%! assert (isempty (min (A, [], 2)))
%! assert (isempty (max (A, [], 2)))

%!test
%! % binary op form, one a scalar
%! A = sym([3 1 9]);
%! m = min(A, sym(2));
%! M = max(A, sym(2));
%! assert (isequal (m, sym([2 1 2])))
%! assert (isequal (M, sym([3 2 9])))
%! m = min(sym(2), A);
%! M = max(sym(2), A);
%! assert (isequal (m, sym([2 1 2])))
%! assert (isequal (M, sym([3 2 9])))

%!test
%! % binary op form, both scalar
%! m = min(sym(1), sym(2));
%! M = max(sym(2), sym(2));
%! assert (isequal (m, sym(1)))
%! assert (isequal (M, sym(2)))

%!test
%! syms x y
%! assert (isequal (children (min (x, y)), [x y]))

%!test
%! syms x y z
%! A = [x 1; y z];
%! assert (isequal (min (A, [], 1), [min(x, y)  min(1, z)]))
%! assert (isequal (max (A, [], 1), [max(x, y)  max(1, z)]))
%! assert (isequal (min (A, [], 2), [min(x, 1); min(y, z)]))
%! assert (isequal (max (A, [], 2), [max(x, 1); max(y, z)]))

%!test
%! syms x y positive
%! a = min([x 2 y -6]);
%! assert (isequal (a, -6))
%! a = max([x y -6]);
%! assert (isequal (a, max(x, y)))

%!test
%! syms x negative
%! a = min([x 6 10]);
%! assert (isequal (a, x))
%! a = max([x -2 6]);
%! assert (isequal (a, 6))
