%% Copyright (C) 2014, 2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@sym triu (@var{A})
%% @defmethodx @@sym triu (@var{A}, @var{k})
%% Upper-triangular part of a symbolic matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 3; 4 5 6; 7 8 9])
%%   @result{} A = (sym 3×3 matrix)
%%       ⎡1  2  3⎤
%%       ⎢       ⎥
%%       ⎢4  5  6⎥
%%       ⎢       ⎥
%%       ⎣7  8  9⎦
%%
%% triu(A)
%%   @result{} (sym 3×3 matrix)
%%       ⎡1  2  3⎤
%%       ⎢       ⎥
%%       ⎢0  5  6⎥
%%       ⎢       ⎥
%%       ⎣0  0  9⎦
%% @end group
%%
%% @group
%% triu(A, 1)
%%   @result{} (sym 3×3 matrix)
%%       ⎡0  2  3⎤
%%       ⎢       ⎥
%%       ⎢0  0  6⎥
%%       ⎢       ⎥
%%       ⎣0  0  0⎦
%% @end group
%% @end example
%% @seealso{@@sym/tril}
%% @end defmethod

function U = triu(A,k)

  if (nargin == 1)
    k = 0;
  end

  if ~(isa(A, 'sym'))  % k was a sym
    U = triu(A, double(k));
    return
  end

  cmd = { '(A,k) = _ins'
          'if A.is_Matrix:'
          '    A = A.as_mutable()'
          '    (n,m) = A.shape'
          '    for c in range(0,m):'
          '        for r in range(max(0,1+c-k),n):'
          '            A[r,c] = 0'
          '    return A,'
          'elif k == 0:'
          '    return A,'
          'else:'
          '    return sp.S(0),' };

  U = pycall_sympy__ (cmd, A, int32(double(k)));

end


%!test
%! % scalar
%! syms x
%! assert (isequal (triu(x), x))
%! assert (isequal (triu(x,0), x))
%! assert (isequal (triu(x,1), 0))
%! assert (isequal (triu(x,-1), 0))

%!test
%! % with symbols
%! syms x
%! A = [x 2*x; 3*x 4*x];
%! assert (isequal (triu(A), [x 2*x; 0 4*x]))

%!test
%! % diagonal shifts
%! B = round(10*rand(3,4));
%! A = sym(B);
%! assert (isequal (triu(A), triu(B)))
%! assert (isequal (triu(A,0), triu(B,0)))
%! assert (isequal (triu(A,1), triu(B,1)))
%! assert (isequal (triu(A,-1), triu(B,-1)))

%!test
%! % double array pass through
%! B = round(10*rand(3,4));
%! assert (isequal (triu(B,sym(1)), triu(B,1)))
%! assert (isa (triu(B,sym(1)), 'double'))

%!test
%! % immutable test
%! A = sym('ImmutableDenseMatrix([[Integer(1), Integer(2)], [Integer(3), Integer(4)]])');
%! assert (isequal (triu (A), sym ([1 2; 0 4])))
%! assert (isequal (tril (A), sym ([1 0; 3 4])))
