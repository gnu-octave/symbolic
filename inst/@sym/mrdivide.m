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
%% @defop  Method   @@sym mrdivide {(@var{x}, @var{y})}
%% @defopx Operator @@sym {@var{x} / @var{y}} {}
%% Forward slash division of symbolic expressions.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 pi; 3 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  π⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% A / 2
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡     π⎤
%%       ⎢1/2  ─⎥
%%       ⎢     2⎥
%%       ⎢      ⎥
%%       ⎣3/2  2⎦
%% @end group
%% @end example
%%
%% The forward slash notation can be used to solve systems
%% of the form A⋅B = C using @code{A = C / B}:
%% @example
%% @group
%% B = sym([1 0; 1 2]);
%% C = A*B
%%   @result{} C = (sym 2×2 matrix)
%%       ⎡1 + π  2⋅π⎤
%%       ⎢          ⎥
%%       ⎣  7     8 ⎦
%% C / B
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡1  π⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% C * inv(B)
%%   @result{} ans = (sym 2×2 matrix)
%%       ⎡1  π⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%% @end group
%% @end example
%% @seealso{@@sym/rdivide, @@sym/mldivide}
%% @end defop


function z = mrdivide(x, y)

  % XXX: delete this when we drop support for Octave < 4.4.2
  if (isa(x, 'symfun') || isa(y, 'symfun'))
    warning('OctSymPy:sym:arithmetic:workaround42735', ...
            'worked around octave bug #42735')
    z = mrdivide(x, y);
    return
  end

  z = pycall_sympy__ ('return _ins[0]/_ins[1],', sym(x), sym(y));

  % Note: SymPy also seems to support 1/A for the inverse (although 2/A
  % not working as of 2016-01).  We don't disallow this but its not a
  % good thing to encourage for working in Octave (since it won't work
  % with doubles).

end


%!test
%! % scalar
%! syms x
%! assert (isa( x/x, 'sym'))
%! assert (isequal( x/x, sym(1)))
%! assert (isa( 2/x, 'sym'))
%! assert (isa( x/2, 'sym'))

%!test
%! % matrix / scalar
%! D = 2*[0 1; 2 3];
%! A = sym(D);
%! assert (isequal ( A/2 , D/2  ))
%! assert (isequal ( A/sym(2) , D/2  ))

%!test
%! % I/A: either invert A or leave unevaluated: not bothered which
%! A = sym([1 2; 3 4]);
%! B = sym(eye(2)) / A;
%! assert (isequal (B, inv(A))  ||  strncmpi (sympy (B), 'MatPow', 6))

%!xtest
%! % immutable test, upstream: TODO
%! A = sym([1 2; 3 4]);
%! B = sym('ImmutableDenseMatrix([[Integer(1), Integer(2)], [Integer(3), Integer(4)]])');
%! assert (isequal (A/A, B/B))

%!test
%! % A = C/B is C = A*B
%! A = sym([1 2; 3 4]);
%! B = sym([1 3; 4 8]);
%! C = A*B;
%! A2 = C / B;
%! assert (isequal (A, A2))

%!test
%! A = [1 2; 3 4];
%! B = A / A;
%! % assert (isequal (B, sym(eye(2))
%! assert (isequal (B(1,1), 1))
%! assert (isequal (B(2,2), 1))
%! assert (isequal (B(2,1), 0))
%! assert (isequal (B(1,2), 0))

%!test
%! A = sym([5 6]);
%! B = sym([1 2; 3 4]);
%! C = A*B;
%! A2 = C / B;
%! assert (isequal (A, A2))
