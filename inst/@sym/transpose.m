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
%% @defop  Method   @@sym transpose {(@var{A})}
%% @defopx Operator @@sym {@var{A}.'} {}
%% Structural transpose (not conjugate) of a symbolic array.
%%
%% Example:
%% @example
%% @group
%% syms z
%% syms x real
%% A = [1 x z; sym(4) 5 6+7i]
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡1  x     z   ⎤
%%       ⎢             ⎥
%%       ⎣4  5  6 + 7⋅ⅈ⎦
%% transpose(A)
%%   @result{} (sym 3×2 matrix)
%%       ⎡1     4   ⎤
%%       ⎢          ⎥
%%       ⎢x     5   ⎥
%%       ⎢          ⎥
%%       ⎣z  6 + 7⋅ⅈ⎦
%% @end group
%% @end example
%%
%% This can be abbreviated to:
%% @example
%% @group
%% A.'
%%   @result{} (sym 3×2 matrix)
%%       ⎡1     4   ⎤
%%       ⎢          ⎥
%%       ⎢x     5   ⎥
%%       ⎢          ⎥
%%       ⎣z  6 + 7⋅ⅈ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/ctranspose}
%% @end defop


function z = transpose(x)

  if (nargin ~= 1)
    print_usage ();
  end

  cmd = { 'x = _ins[0]'
          'if x.is_Matrix:'
          '    return x.T'
          'else:'
          '    return x' };

  z = pycall_sympy__ (cmd, x);

end


%!test
%! x = sym(1);
%! assert (isequal (x.', x))

%!assert (isempty (sym([]).'))

%!test
%! syms x;
%! assert (isequal (x.', x))

%!test
%! A = [1 2; 3 4];
%! assert(isequal( sym(A).' , sym(A.') ))
%!test
%! A = [1 2] + 1i;
%! assert(isequal( sym(A).' , sym(A.') ))
