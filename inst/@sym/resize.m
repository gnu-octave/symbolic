%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym resize {(@var{a}, @var{m})}
%% @defmethodx @@sym resize {(@var{a}, @var{n}, @var{m})}
%% @defmethodx @@sym resize {(@var{a}, [@var{n} @var{m}])}
%% Resize a symbolic array, cropping or padding with zeros.
%%
%% Example
%% @example
%% @group
%% A = sym([1 2; pi 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎣π  4⎦
%% @end group
%%
%% @group
%% resize(A, 1, 4)
%%   @result{} (sym) [1  2  0  0]  (1×4 matrix)
%%
%% resize(A, [1 4])
%%   @result{} (sym) [1  2  0  0]  (1×4 matrix)
%% @end group
%%
%% @group
%% resize(A, 3)
%%   @result{} (sym 3×3 matrix)
%%       ⎡1  2  0⎤
%%       ⎢       ⎥
%%       ⎢π  4  0⎥
%%       ⎢       ⎥
%%       ⎣0  0  0⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/reshape}
%% @end defmethod


function B = resize(A, n, m)

  if ((nargin == 2) && isscalar(n))
    m = n;
  elseif ((nargin == 2) && (length(n) == 2))
    m = n(2);
    n = n(1);
  elseif ((nargin == 3) && isscalar(n) && isscalar(m))
    % no-op
  else
    print_usage ();
  end

  cmd = {
    'A, n, m = _ins'
    'if A is None or not A.is_Matrix:'
    '    A = Matrix([A])'
    'return Matrix(n, m, lambda i,j: 0 if i >= A.rows or j >= A.cols else A[i,j])'
  };

  B = pycall_sympy__ (cmd, sym(A), int32(n), int32(m));
end


%!test
%! B = sym([1 0 0; 0 0 0]);
%! assert (isequal (resize (sym(1), 2, 3), B))
%! assert (isequal (resize (sym(1), [2 3]), B))

%!test
%! B = sym([1 0; 0 0]);
%! assert (isequal (resize (sym(1), 2), B))

%!test
%! A = sym([pi 2; 3 4]);
%! assert (isequal (resize (A, 1), sym(pi)))

%!assert (isequal (size (resize (sym(1), 0, 0)), [0 0]))
%!assert (isequal (size (resize (sym(1), 6, 0)), [6 0]))
%!assert (isequal (size (resize (sym(1), 0, 3)), [0 3]))

%!error resize (sym(1))
%!error resize (sym(1), 2, 3, 4)
%!error resize (sym(1), [2 3 4])
