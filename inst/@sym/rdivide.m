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
%% @defop  Method   @@sym rdivide {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} ./ @var{y}} {}
%% Element-wise forward slash division of symbolic expressions.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = sym([1 137; 3 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  137⎤
%%       ⎢      ⎥
%%       ⎣3   4 ⎦
%% B = [x pi; 2*x 8]
%%   @result{} B = (sym 2×2 matrix)
%%       ⎡ x   π⎤
%%       ⎢      ⎥
%%       ⎣2⋅x  8⎦
%% A ./ B
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡ 1   137⎤
%%       ⎢ ─   ───⎥
%%       ⎢ x    π ⎥
%%       ⎢        ⎥
%%       ⎢ 3      ⎥
%%       ⎢───  1/2⎥
%%       ⎣2⋅x     ⎦
%% @end group
%% @end example
%%
%% Either @var{x} or @var{y} can be scalar:
%% @example
%% @group
%% A ./ 2
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡1/2  137/2⎤
%%       ⎢          ⎥
%%       ⎣3/2    2  ⎦
%% 2 ./ B
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡2   2 ⎤
%%       ⎢─   ─ ⎥
%%       ⎢x   π ⎥
%%       ⎢      ⎥
%%       ⎢1     ⎥
%%       ⎢─  1/4⎥
%%       ⎣x     ⎦
%% @end group
%% @end example
%%
%% Finally, the can both be scalar:
%% @example
%% @group
%% 2 ./ x
%%   @result{} ans = (sym)
%%       2
%%       ─
%%       x
%% @end group
%% @end example
%% @seealso{@@sym/ldivide, @@sym/mrdivide}
%% @end defop


function z = rdivide(x, y)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = rdivide(x, y);
    return
  end


  cmd = { '(x,y) = _ins'
          'if x.is_Matrix and y.is_Matrix:'
          '    return x.multiply_elementwise(y.applyfunc(lambda a: 1/a)),'
          'if not x.is_Matrix and y.is_Matrix:'
          '    return y.applyfunc(lambda a: x/a),'
          'else:'
          '    return x/y,' };

  z = pycall_sympy__ (cmd, sym(x), sym(y));

end


%!test
%! % scalar
%! syms x
%! assert (isa (x ./ 1, 'sym'))
%! assert (isa (x ./ x, 'sym'))
%! assert (isequal (x ./ 1, x))
%! assert (isequal (x ./ x, sym(1)))

%!test
%! % matrix-scalar
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal ( A./2 , D/2  ))
%! assert (isequal ( A./sym(2) , D/2  ))
%! assert (isequal ( D./sym(2) , D/2  ))

%!test
%! % matrix ./ matrix
%! D = [1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( A./A , D./D  ))
%! assert (isequal ( A./D , D./D  ))
%! assert (isequal ( D./A , D./D  ))

%!test
%! % matrix ./ matrix with symbols
%! syms x y
%! A = [x y; x^2 2*y];
%! B = [y x; x y];
%! assert (isequal ( A./A , sym(ones(2,2)) ))
%! assert (isequal ( A./B , [x/y y/x; x 2] ))

%!test
%! % scalar ./ matrix
%! D = [1 2; 3 4];
%! A = sym(D);
%! assert (isequal ( 12./A , 12./D  ))
