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
%% @defmethod @@sym fliplr (@var{A})
%% Flip a symbolic matrix horizontally.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 pi; 4 5 6]);
%% fliplr (A)
%%   @result{} (sym 2×3 matrix)
%%       ⎡π  2  1⎤
%%       ⎢       ⎥
%%       ⎣6  5  4⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/flipud, @@sym/reshape}
%% @end defmethod


function B = fliplr (A)

  cmd = { 'A, = _ins'
          'if A is None or not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'return A[:, ::-1]' };

  B = pycall_sympy__ (cmd, sym(A));

end


%!test
%! % simple
%! syms x
%! A = [x 2; sym(pi) x];
%! B = [2 x; x sym(pi)];
%! assert (isequal (fliplr(A), B))

%!test
%! % simple, odd # cols
%! syms x
%! A = [x 2 sym(pi); x 1 2];
%! B = [sym(pi) 2 x; 2 1 x];
%! assert (isequal (fliplr(A), B))

%!test
%! % scalar
%! syms x
%! assert (isequal (fliplr(x), x))
