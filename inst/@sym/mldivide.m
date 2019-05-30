%% Copyright (C) 2014, 2016, 2018-2019 Colin B. Macdonald
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
%% @defop  Method   @@sym mldivide {(@var{A}, @var{b})}
%% @defopx Operator @@sym {@var{A} \ @var{b}} {}
%% Symbolic backslash: solve symbolic linear systems.
%%
%% This operator tries to broadly match the behaviour of the
%% backslash operator for double matrices.
%% For scalars, this is just division:
%% @example
%% @group
%% sym(2) \ 1
%%   @result{} ans = (sym) 1/2
%% @end group
%% @end example
%%
%% But for matrices, it solves linear systems
%% @example
%% @group
%% A = sym([1 2; 3 4]);
%% b = sym([5; 11]);
%% x = A \ b
%%   @result{} x = (sym 2×1 matrix)
%%       ⎡1⎤
%%       ⎢ ⎥
%%       ⎣2⎦
%% A*x == b
%%   @result{} ans = (sym 2×1 matrix)
%%       ⎡True⎤
%%       ⎢    ⎥
%%       ⎣True⎦
%% @end group
%% @end example
%%
%% Over- and under-determined systems are supported:
%% @example
%% @group
%% A = sym([5 2]);
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% x = A \ 10
%%   @result{} x = (sym 2×1 matrix)
%%       ⎡    2⋅c₁⎤
%%       ⎢2 - ────⎥
%%       ⎢     5  ⎥
%%       ⎢        ⎥
%%       ⎣   c₁   ⎦
%% A*x == 10
%%   @result{} ans = (sym) True
%% @end group
%% @group
%% A = sym([1 2; 3 4; 9 12]);
%% b = sym([5; 11; 33]);
%% x = A \ b
%%   @result{} x = (sym 2×1 matrix)
%%       ⎡1⎤
%%       ⎢ ⎥
%%       ⎣2⎦
%% A*x - b
%%   @result{} ans = (sym 3×1 matrix)
%%       ⎡0⎤
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎣0⎦
%% @end group
%% @end example
%% @seealso{@@sym/ldivide, @@sym/mrdivide}
%% @end defop

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function x = mldivide(A, b)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(A, 'symfun') || isa(b, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    x = mldivide(A, b);
    return
  end

  % not for singular
  %'ans = A.LUsolve(b)'

  if (isscalar(A))
    x = b / A;
    return
  end


  cmd = {
    '(A, B) = _ins'
    'flag = 0'
    'if not A.is_Matrix:'
    '    A = sympy.Matrix([A])'
    'if not B.is_Matrix:'
    '    B = sympy.Matrix([B])'
    'if any([y.is_Float for y in A]) or any([y.is_Float for y in B]):'
    '    flag = 1'
    'M = A.cols'
    'Z = sympy.zeros(M, B.cols)'
    'for k in range(0, B.cols):'
    '    b = B.col(k)'
    '    x = [Symbol("c%d" % (j + k*M)) for j in range(0, M)]'
    '    AA = A.hstack(A, b)'
    '    d = solve_linear_system(AA, *x)'
    '    if d is None:'
    '        Z[:, k] = sympy.Matrix([S.NaN]*M)'
    '    else:'
    '        # apply dict'
    '        Z[:, k] = sympy.Matrix([d.get(c, c) for c in x])'
    'return (flag, Z)'
  };

  [flag, x] = pycall_sympy__ (cmd, sym(A), sym(b));
  if (flag ~= 0)
    warning('octsympy:backslash:vpa', ...
            'vpa backslash may not match double backslash')
  end
end

% [5 2] \ 10

%!test
%! % scalar
%! syms x
%! assert (isa( x\x, 'sym'))
%! assert (isequal( x\x, sym(1)))
%! assert (isa( 2\x, 'sym'))
%! assert (isa( x\2, 'sym'))

%!test
%! % scalar \ matrix: easy, no system
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal (  2 \ A , D/2  ))
%! assert (isequal (  sym(2) \ A , D/2  ))

%!test
%! % singular matrix
%! A = sym([1 2; 2 4]);
%! b = sym([5; 10]);
%! x = A \ b;
%! syms c1
%! y = [-2*c1 + 5; c1];
%! assert (isequal (x, y))

%!test
%! % singular matrix, mult RHS
%! A = sym([1 2; 2 4]);
%! B = sym([[5; 10] [0; 2] [0; 0]]);
%! x = A \ B;
%! syms c1 c5
%! y = [-2*c1 + 5 nan -2*c5; c1 nan c5];
%! assert (isequaln (x, y))

%!warning <vpa backslash>
%! % vpa, nearly singular matrix
%! A = sym([1 2; 2 4]);
%! A(1,1) = vpa('1.001');
%! b = sym([1; 2]);
%! x = A \ b;
%! y = [sym(0); vpa('0.5')];
%! assert (isequal (x, y))

%!warning <vpa backslash>
%! % vpa, singular rhs
%! A = sym([1 2; 2 4]);
%! b = [vpa('1.01'); vpa('2')];
%! x = A \ b;
%! assert (all(isnan(x)))
