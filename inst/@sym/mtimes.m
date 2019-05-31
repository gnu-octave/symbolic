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
%% @defop  Method   @@sym mtimes {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} * @var{y}} {}
%% Multiply symbolic matrices.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% A = sym([1 2; 3 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% B = [x; y]
%%   @result{} B = (sym 2×1 matrix)
%%       ⎡x⎤
%%       ⎢ ⎥
%%       ⎣y⎦
%% A * B
%%   @result{} (sym 2×1 matrix)
%%       ⎡ x + 2⋅y ⎤
%%       ⎢         ⎥
%%       ⎣3⋅x + 4⋅y⎦
%% @end group
%% @end example
%% @end defop


function z = mtimes(x, y)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = mtimes(x, y);
    return
  end


  cmd = { '(x,y) = _ins'
          'return x*y,' };

  z = pycall_sympy__ (cmd, sym(x), sym(y));

end


%!test
%! % scalar
%! syms x
%! assert (isa (x*2, 'sym'))
%! assert (isequal (2*sym(3), sym(6)))
%! assert (isequal (sym(2)*3, sym(6)))

%!test
%! % matrix-scalar
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert (isa (2*A, 'sym'))
%! assert (isequal ( 2*A , 2*D  ))
%! assert (isequal ( A*2 , 2*D  ))

%!test
%! % matrix-matrix
%! D = [0 1; 2 3];
%! A = sym(D);
%! assert (isa (A*A, 'sym'))
%! assert (isequal ( A*A , D*D  ))
