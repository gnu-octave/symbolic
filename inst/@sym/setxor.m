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
%% @deftypefn {Function File}  {@var{r} =} setxor (@var{A}, @var{B})
%% Return the symmetric difference of two sets.
%%
%% @seealso{union, intersect, setdiff, unique, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = setxor(A, B)

  % FIXME: is it worth splitting out a "private/set_helper"?

    cmd = { 'a, b = _ins'
            'A = sp.FiniteSet(*(list(a) if isinstance(a, sp.MatrixBase) else [a]))'
            'B = sp.FiniteSet(*(list(b) if isinstance(b, sp.MatrixBase) else [b]))'
            'C = A^B'
            'return sp.Matrix([[list(C)]]),' };

  A = sym(A);
  B = sym(B);
  r = python_cmd (cmd, A, B);
  r = horzcat(r{:});

  % reshape to column if both inputs are
  if (iscolumn(A) && iscolumn(B))
    r = reshape(r, length(r), 1);
  end

end


%!test
%! A = sym([1 2 3]);
%! B = sym([1 2 4]);
%! C = setxor(A, B);
%! D1 = sym([3 4]);
%! D2 = sym([4 3]);
%! assert (isequal (C, D1) || isequal (C, D2))

%!test
%! % one nonsym
%! A = sym([1 2 3]);
%! B = [1 2 4];
%! C = setxor(A, B);
%! D1 = sym([3 4]);
%! D2 = sym([4 3]);
%! assert (isequal (C, D1) || isequal (C, D2))

%!test
%! % empty
%! A = sym([1 2 3]);
%! C = setxor(A, A);
%! assert (isempty (C))

%!test
%! % empty input
%! A = sym([1 2]);
%! C = setxor(A, []);
%! assert (isequal (C, A) || isequal (C, sym([2 1])))


%!test
%! % scalar
%! syms x
%! assert (isequal (setxor([x 1], x), sym(1)))
%! assert (isempty (setxor(x, x)))
