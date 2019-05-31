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
%% @defmethod @@sym flipud (@var{A})
%% Flip a symbolic matrix vertically.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 pi; 4 5 6]);
%% flipud (A)
%%   @result{} (sym 2×3 matrix)
%%       ⎡4  5  6⎤
%%       ⎢       ⎥
%%       ⎣1  2  π⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/fliplr, @@sym/reshape}
%% @end defmethod


function B = flipud (A)

  cmd = { 'A, = _ins'
          'if A is None or not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'return A[::-1, :]' };

  B = pycall_sympy__ (cmd, sym(A));

end


%!test
%! % simple
%! syms x
%! A = [x 2; sym(pi) x];
%! B = [sym(pi) x; x 2];
%! assert (isequal (flipud(A), B))

%!test
%! % simple, odd # rows
%! syms x
%! A = [x 2; sym(pi) x; [1 2]];
%! B = [[1 2]; sym(pi) x; x 2];
%! assert (isequal (flipud(A), B))

%!test
%! % scalar
%! syms x
%! assert (isequal (flipud(x), x))
