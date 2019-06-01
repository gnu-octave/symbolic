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
%% @deftypemethod  @@sym {@var{r} =} rref (@var{A})
%% @deftypemethodx @@sym {[@var{r}, @var{k}] =} rref (@var{A})
%% Reduced Row Echelon Form of a symbolic matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2 3; 2 3 4]);
%% rref (A)
%%   @result{} (sym 2×3 matrix)
%%
%%       ⎡1  0  -1⎤
%%       ⎢        ⎥
%%       ⎣0  1  2 ⎦
%%
%% @end group
%% @end example
%%
%% Optional second output gives the indices of pivots.
%%
%% @seealso{@@sym/rank, @@sym/null, @@sym/orth}
%% @end deftypemethod


function [r, k] = rref(A)

  cmd = { 'A = _ins[0]'
          'if not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'L = A.rref()'
          'K = sp.Matrix([L[1]])'
          'return (L[0], K)'
        };

  [r, k] = pycall_sympy__ (cmd, A);

  k = k + 1;

end


%!test
%! A = sym([1 2; 3 4]);
%! [r, k] = rref(A);
%! assert (isequal (r, eye(2)))
%! assert (isequal (k, [1 2]))

%!assert (isequal (rref(sym([2 1])), [1 sym(1)/2]))

%!assert (isequal (rref(sym([1 2; 2 4])), [1 2; 0 0]))

%!assert (isequal (rref(sym([0 0; 2 4])), [1 2; 0 0]))

%!test
%! A = sym([1 2 3; 2 3 4]);
%! [r, k] = rref(A);
%! assert (isequal (r, [1 0 -1; 0 1 2]))
%! assert (isequal (k, [1 2]));
