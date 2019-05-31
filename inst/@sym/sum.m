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
%% @defmethod  @@sym sum (@var{x})
%% @defmethodx @@sym sum (@var{x}, @var{n})
%% Sum of symbolic expressions.
%%
%% Sum over the rows or columns of an expression.  By default, sum
%% over the rows.  Can specify row or column sums using @var{n}.
%% To perform symbolic summations, @pxref{@@sym/symsum}.
%%
%% Examples:
%% @example
%% @group
%% syms x y z
%% sum([x y z])
%%   @result{} (sym) x + y + z
%%
%% sum([x y; x z], 1)
%%   @result{} (sym) [2⋅x  y + z]  (1×2 matrix)
%%
%% sum([x y; x z], 2)
%%   @result{} (sym 2×1 matrix)
%%       ⎡x + y⎤
%%       ⎢     ⎥
%%       ⎣x + z⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/prod, @@sym/symsum}
%% @end defmethod


function y = sum(x, n)

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
          '    B[i] = sum(A.row(i))'
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


%!error <Invalid> sum (sym(1), 2, 3)
%!error <Invalid> sum (sym(1), 42)

%!shared x,y,z
%! syms x y z
%!assert (isequal (sum (x), x))
%!assert (isequal (sum ([x y z]), x+y+z))
%!assert (isequal (sum ([x; y; z]), x+y+z))
%!assert (isequal (sum ([x y z], 1), [x y z]))
%!assert (isequal (sum ([x y z], 2), x+y+z))

%!shared a,b
%! b = [1 2; 3 4]; a = sym(b);
%!assert (isequal (sum(a), sum(b)))
%!assert (isequal (sum(a,1), sum(b,1)))
%!assert (isequal (sum(a,2), sum(b,2)))

%!test
%! % weird inputs
%! a = sum('xx', sym(1));
%! assert (isequal (a, sym('xx')))
