%% Copyright (C) 2016, 2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym unique (@var{A})
%% Return the unique elements of a symbolic matrix.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = [sym(1) 2 pi x x pi 2*sym(pi)];
%% unique(A)
%%   @result{} ans = (sym) [1  2  π  x  2⋅π]  (1×5 matrix)
%% @end group
%% @end example
%%
%% Note the @emph{output will be a matrix}.  If instead you want a
%% @emph{set}, try:
%% @example
%% @group
%% finiteset(num2cell(A))
%%   @result{} ans = (sym) @{1, 2, π, 2⋅π, x@}
%% @end group
%% @end example
%%
%% @seealso{@@sym/union, @@sym/intersect, @@sym/setdiff, @@sym/setxor,
%%          @@sym/ismember, @@sym/finiteset}
%% @end defmethod


function r = unique(A)

  if (nargin ~= 1)
    print_usage ();
  end

  r = pycall_sympy__ ('return sp.Matrix([list(uniq(*_ins))]),', A);

end


%!test
%! A = sym([1 2 3 3 5 3 2 6 5]);
%! B = sym([1 2 3 5 6]);
%! assert (isequal (unique(A), B))

%!test
%! syms x y
%! A = [1 2 3 3 4 5 5 6 7 7 x x y y];
%! B = [1  2  3  4  5  6  7  x  y];
%! assert (isequal (unique(A), B))
