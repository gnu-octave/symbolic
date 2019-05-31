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
%% @defmethod  @@sym prod (@var{x})
%% @defmethodx @@sym prod (@var{x}, @var{n})
%% Product of symbolic expressions.
%%
%% Example:
%% @example
%% @group
%% syms x y z
%% prod([x y z])
%%   @result{} (sym) x⋅y⋅z
%% @end group
%% @end example
%%
%% Can specify row or column sums using @var{n}:
%% @example
%% @group
%% f = prod([x y; x z], 1)
%%   @result{} f = (sym 1×2 matrix)
%%
%%       ⎡ 2     ⎤
%%       ⎣x   y⋅z⎦
%%
%% f = prod([x y; x z], 2)
%%   @result{} f = (sym 2×1 matrix)
%%
%%       ⎡x⋅y⎤
%%       ⎢   ⎥
%%       ⎣x⋅z⎦
%%
%% @end group
%% @end example
%%
%% @seealso{@@sym/sum, @@sym/symprod}
%% @end defmethod


function y = prod(x, n)

  x = sym(x);

  if (nargin == 1)
    if (isrow(x))
      n = 2;
    elseif (iscolumn(x))
      n = 1;
    else
      n = 1;
    end
  elseif (nargin == 2)
    n = double(n);
  else
    print_usage ();
  end

  cmd = { 'A = _ins[0]'
          'if not isinstance(A, sympy.MatrixBase):'
          '    A = Matrix([A])'
          'B = sp.Matrix.zeros(A.rows, 1)'
          'for i in range(0, A.rows):'
          '    B[i] = prod(A.row(i))'
          'return B' };
  if (n == 1)
    y = pycall_sympy__ (cmd, transpose(x));
    y = transpose(y);
  elseif (n == 2)
    y = pycall_sympy__ (cmd, x);
  else
    print_usage ();
  end
end


%!error <Invalid> prod (sym(1), 2, 3)
%!error <Invalid> prod (sym(1), 42)

%!shared x,y,z
%! syms x y z
%!assert (isequal (prod (x), x))
%!assert (isequal (prod ([x y z]), x*y*z))
%!assert (isequal (prod ([x; y; z]), x*y*z))
%!assert (isequal (prod ([x y z], 1), [x y z]))
%!assert (isequal (prod ([x y z], 2), x*y*z))

%!shared a,b
%! b = [1 2; 3 4]; a = sym(b);
%!assert (isequal (prod(a), prod(b)))
%!assert (isequal (prod(a,1), prod(b,1)))
%!assert (isequal (prod(a,2), prod(b,2)))

%!test
%! % weird inputs
%! a = prod('xx', sym(1));
%! assert (isequal (a, sym('xx')))
