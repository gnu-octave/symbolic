%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym expm (@var{A})
%% Symbolic matrix exponential.
%%
%% Example:
%% @example
%% @group
%% A = [sym(4) 1; sym(0) 4]
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡4  1⎤
%%       ⎢    ⎥
%%       ⎣0  4⎦
%%
%% expm(A)
%%   @result{} (sym 2×2 matrix)
%%       ⎡ 4   4⎤
%%       ⎢ℯ   ℯ ⎥
%%       ⎢      ⎥
%%       ⎢     4⎥
%%       ⎣0   ℯ ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/eig}
%% @end defmethod

function z = expm(x)

  if (nargin ~= 1)
    print_usage ();
  end

  cmd = { 'x, = _ins'
          'if not x.is_Matrix:'
          '    x = sp.Matrix([[x]])'
          'return x.exp(),' };

  z = pycall_sympy__ (cmd, x);

end


%!test
%! % scalar
%! syms x
%! assert (isequal (expm(x), exp(x)))

%!test
%! % diagonal
%! A = [sym(1) 0; 0 sym(3)];
%! B = [exp(sym(1)) 0; 0 exp(sym(3))];
%! assert (isequal (expm(A), B))

%!test
%! % diagonal w/ x
%! syms x positive
%! A = [sym(1) 0; 0 x+2];
%! B = [exp(sym(1)) 0; 0 exp(x+2)];
%! assert (isequal (expm(A), B))

%!test
%! % non-diagonal
%! syms x positive
%! A = [sym(1) 2; 0 x+2];
%! B = expm(A);
%! C = double(subs(B, x, 4));
%! D = expm(double(subs(A, x, 4)));
%! assert (max (max (abs (C - D))) <= 1e-11)
