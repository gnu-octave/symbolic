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
%% @defmethod  @@sym tril (@var{A})
%% @defmethodx @@sym tril (@var{A}, @var{k})
%% Lower-triangular part of a symbolic matrix.
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
%% tril(A)
%%   @result{} (sym 3×3 matrix)
%%       ⎡1  0  0⎤
%%       ⎢       ⎥
%%       ⎢4  5  0⎥
%%       ⎢       ⎥
%%       ⎣7  8  9⎦
%% @end group
%%
%% @group
%% tril(A, 1)
%%   @result{} (sym 3×3 matrix)
%%       ⎡1  2  0⎤
%%       ⎢       ⎥
%%       ⎢4  5  6⎥
%%       ⎢       ⎥
%%       ⎣7  8  9⎦
%% @end group
%% @end example
%% @seealso{@@sym/tril}
%% @end defmethod


function L = tril(A,k)

  if (nargin == 1)
    k = 0;
  end

  if ~(isa(A, 'sym'))  % k was a sym
    L = tril(A, double(k));
    return
  end

  L = triu(A.', -k);
  L = L.';

end

%!test
%! syms x
%! assert (isequal (tril(x), x))

%!test
%! % with symbols
%! syms x
%! A = [x 2*x; 3*x 4*x];
%! assert (isequal (tril(A), [x 0; 3*x 4*x]))

%!test
%! % diagonal shifts
%! B = round(10*rand(3,4));
%! A = sym(B);
%! assert (isequal (tril(A), tril(B)))
%! assert (isequal (tril(A,0), tril(B,0)))
%! assert (isequal (tril(A,1), tril(B,1)))
%! assert (isequal (tril(A,-1), tril(B,-1)))

%!test
%! % double array pass through
%! B = round(10*rand(3,4));
%! assert (isequal (tril(B,sym(1)), tril(B,1)))
%! assert (isa (tril(B,sym(1)), 'double'))
