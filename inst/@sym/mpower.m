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
%% @defop  Method   @@sym mpower {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} ^ @var{y}} {}
%% Symbolic expression matrix exponentiation.
%%
%% Scalar example:
%% @example
%% @group
%% syms x
%% sym('x')^3
%%   @result{} ans = (sym)
%%        3
%%       x
%% @end group
%% @end example
%%
%% The @code{^} notation is use to raise a matrix to a scalar power:
%% @example
%% @group
%% A = [sym(pi) 2; 0 x]
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡π  2⎤
%%       ⎢    ⎥
%%       ⎣0  x⎦
%% A^2
%%   @result{} (sym 2×2 matrix)
%%       ⎡ 2           ⎤
%%       ⎢π   2⋅x + 2⋅π⎥
%%       ⎢             ⎥
%%       ⎢        2    ⎥
%%       ⎣0      x     ⎦
%% A^2 == A*A
%%   @result{} (sym 2×2 matrix)
%%       ⎡True  True⎤
%%       ⎢          ⎥
%%       ⎣True  True⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/power}
%% @end defop


function z = mpower(x, y)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = mpower(x, y);
    return
  end

  cmd = { 'x, y = _ins'
          'return x**y' };

  z = pycall_sympy__ (cmd, sym(x), sym(y));

end


%!test
%! syms x
%! assert(isequal(x^(sym(4)/5), x.^(sym(4)/5)))

%!test
%! % integer powers of scalars
%! syms x
%! assert (isequal (x^2, x*x))
%! assert (isequal (x^sym(3), x*x*x))

%!test
%! % array ^ integer
%! syms x y
%! A = [x 2; y 4];
%! assert (isequal (A^2, A*A))
%! assert (isequal (simplify(A^3 - A*A*A), [0 0; 0 0]))

%!test
%! % array ^ rational
%! Ad = [1 2; 0 3];
%! A = sym(Ad);
%! B = A^(sym(1)/3);
%! Bd = Ad^(1/3);
%! assert (max(max(abs(double(B) - Bd))) < 1e-14)

%!test
%! % non-integer power
%! A = sym([1 2; 0 3]);
%! B = A^pi;
%! C = [1 -1+3^sym(pi); 0 sym(3)^pi];
%! assert (isequal (B, C))

%!test
%! % matpow
%! syms n
%! A = sym([1 2; 3 4]);
%! B = A^n;
%! C = 10 + B + B^2;
%! D = subs(C, n, 1);
%! E = 10 + A + A^2;
%! assert (isequal (simplify(D), simplify(E)))

%!test
%! % matpow, sub in zero gives identity
%! A = sym([1 2; 0 3]);
%! syms n;
%! B = A^n;
%! C = subs(B, n, 1);
%! assert (isequal (C, A))
%! C = subs(B, n, 0);
%! assert (isequal (C, sym(eye(2))))

%!test
%! % scalar^array not implemented in SymPy < 1.0
%! syms x
%! A = [1 2; 3 4];
%! B = x^A;
%! assert (strcmp (regexprep (disp (B, 'flat'), '\s+', ''), 'x**Matrix([[1,2],[3,4]])'))

%!error
%! A = sym([1 2; 3 4]);
%! B = A^A;
