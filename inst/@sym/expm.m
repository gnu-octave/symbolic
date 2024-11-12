%% Copyright (C) 2014-2016, 2019, 2024 Colin B. Macdonald
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
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.8")'))
%% A = [sym(4) 1; sym(0) 4]
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡4  1⎤
%%       ⎢    ⎥
%%       ⎣0  4⎦
%%
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.8")'))
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
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.9")'))
%! syms x
%! assert (isequal (expm(x), exp(x)))
%! end

%!test
%! % diagonal
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.9")'))
%! A = [sym(1) 0; 0 sym(3)];
%! B = [exp(sym(1)) 0; 0 exp(sym(3))];
%! assert (isequal (expm(A), B))
%! end

%!test
%! % diagonal w/ x
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.9")'))
%! syms x positive
%! A = [sym(1) 0; 0 x+2];
%! B = [exp(sym(1)) 0; 0 exp(x+2)];
%! assert (isequal (expm(A), B))
%! end

%!test
%! % non-diagonal
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.9")'))
%! syms x positive
%! A = [sym(1) 2; 0 x+2];
%! B = expm(A);
%! C = double(subs(B, x, 4));
%! D = expm(double(subs(A, x, 4)));
%! assert (max (max (abs (C - D))) <= 1e-11)
%! end
