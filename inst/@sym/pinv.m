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
%% @defmethod  @@sym pinv (@var{A})
%% Symbolic Moore-Penrose pseudoinverse of a matrix.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2; 3 4; 5 6])
%%   @result{} A = (sym 3×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎢3  4⎥
%%       ⎢    ⎥
%%       ⎣5  6⎦
%%
%% pinv(A)
%%   @result{} (sym 2×3 matrix)
%%       ⎡-4/3  -1/3   2/3 ⎤
%%       ⎢                 ⎥
%%       ⎢ 13              ⎥
%%       ⎢ ──   1/3   -5/12⎥
%%       ⎣ 12              ⎦
%% @end group
%% @end example
%% @end defmethod


function z = pinv(x)

  cmd = { 'x, = _ins'
          'if not x.is_Matrix:'
          '    x = sp.Matrix([[x]])'
          'return x.pinv(),' };

  z = pycall_sympy__ (cmd, x);

end


%!test
%! % scalar
%! syms x
%! assert (isequal (pinv(x), 1/x))

%!test
%! % 2x3
%! A = [1 2 3; 4 5 6];
%! assert (max (max (abs (double (pinv (sym (A))) - pinv(A)))) <= 10*eps)
