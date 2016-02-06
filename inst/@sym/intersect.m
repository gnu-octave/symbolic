%% Copyright (C) 2016 Colin B. Macdonald and Lagu
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
%% @deftypefn {Function File}  {@var{r} =} intersect (@var{A}, @var{B})
%% Return the common elements of two sets.
%%
%% Example:
%% @example
%% @group
%% A = finiteset(sym(1), 2, 3);
%% B = finiteset(sym(pi), 2);
%% intersect(A, B)
%%   @result{} ans = (sym) @{2@}
%% @end group
%% @end example
%%
%% The sets can also be intervals or a mixture of finite sets
%% and intervals:
%% @example
%% @group
%% C = interval(sym(2), 10);
%% intersect(A, C)
%%   @result{} ans = (sym) @{2, 3@}
%%
%% D = interval(0, sym(pi));
%% intersect(C, D)
%%   @result{} ans = (sym) [2, π]
%% @end group
%% @end example
%%
%% @seealso{union, setdiff, setxor, unique, ismember, finiteset, interval}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = intersect(a, b)

  if (nargin ~= 2)
    print_usage ();
  end

  cmd = {
         'a, b = _ins'
         'if isinstance(a, sp.Set) or isinstance(b, sp.Set):'
         '    return a & b,'
         ''
         'A = sp.FiniteSet(*(list(a) if isinstance(a, sp.MatrixBase) else [a]))'
         'B = sp.FiniteSet(*(list(b) if isinstance(b, sp.MatrixBase) else [b]))'
         'C = A & B'
         'return sp.Matrix([list(C)]),'
        };

    r = python_cmd (cmd, sym(a), sym(b));

end


%!test
%! A = sym([1 2 3]);
%! B = sym([1 2 4]);
%! C = intersect(A, B);
%! D = sym([1 2]);
%! assert (isequal (C, D))

%!test
%! % one nonsym
%! A = sym([1 2 3]);
%! B = [1 2 4];
%! C = intersect(A, B);
%! D = sym([1 2]);
%! assert (isequal (C, D))

%!test
%! % empty
%! A = sym([1 2 3]);
%! C = intersect(A, A);
%! assert (isequal (C, A))

%!test
%! % empty input
%! A = sym([1 2]);
%! C = intersect(A, []);
%! assert (isequal (C, sym([])))

%!test
%! % scalar
%! syms x
%! assert (isequal (intersect([x 1], x), x))
%! assert (isequal (intersect(x, x), x))

%!test
%! A = interval(sym(1), 3);
%! B = interval(sym(2), 5);
%! C = intersect(A, B);
%! assert( isequal( C, interval(sym(2), 3)))
