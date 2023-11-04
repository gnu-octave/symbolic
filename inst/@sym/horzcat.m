%% Copyright (C) 2014-2017, 2019, 2022 Colin B. Macdonald
%% Copyright (C) 2022 Alex Vong
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
%% @defop  Method   @@sym {horzcat} {(@var{x}, @var{y}, @dots{})}
%% @defopx Operator @@sym {[@var{x}, @var{y}, @dots{}]} {}
%% @defopx Operator @@sym {[@var{x} @var{y} @dots{}]} {}
%% Horizontally concatenate symbolic arrays.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2; 3 4])
%%   @result{} A = (sym 2×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎣3  4⎦
%%
%% [A A A]
%%   @result{} (sym 2×6 matrix)
%%       ⎡1  2  1  2  1  2⎤
%%       ⎢                ⎥
%%       ⎣3  4  3  4  3  4⎦
%% @end group
%% @end example
%% @seealso{@@sym/vertcat, @@sym/cat}
%% @end defop


function h = horzcat(varargin)

  args = cellfun (@transpose, varargin, 'UniformOutput', false);
  h = vertcat (args{:}).';

end


%!test
%! % basic
%! syms x
%! A = [x x];
%! B = horzcat(x, x);
%! C = horzcat(x, x, x);
%! assert (isa (A, 'sym'))
%! assert (isa (B, 'sym'))
%! assert (isa (C, 'sym'))
%! assert (isequal (size(A), [1 2]))
%! assert (isequal (size(B), [1 2]))
%! assert (isequal (size(C), [1 3]))

%!test
%! % basic, part 2
%! syms x
%! A = [x 1];
%! B = [1 x];
%! C = [1 2 x];
%! assert (isa (A, 'sym'))
%! assert (isa (B, 'sym'))
%! assert (isa (C, 'sym'))
%! assert (isequal (size(A), [1 2]))
%! assert (isequal (size(B), [1 2]))
%! assert (isequal (size(C), [1 3]))

%!test
%! % row vectors
%! a = [sym(1) 2];
%! b = [sym(3) 4];
%! assert (isequal ( [a b] , [1 2 3 4]  ))
%! assert (isequal ( [a 3 4] , [1 2 3 4]  ))
%! assert (isequal ( [3 4 a] , [3 4 1 2]  ))
%! assert (isequal ( [a [3 4]] , [1 2 3 4]  ))
%! assert (isequal ( [a sym(3) 4] , [1 2 3 4]  ))
%! assert (isequal ( [a [sym(3) 4]] , [1 2 3 4]  ))

%!test
%! % col vectors
%! a = [sym(1); 2];
%! b = [sym(3); 4];
%! assert (isequal ( [a b] , [1 3; 2 4]  ))
%! assert (isequal ( [a b a] , [1 3 1; 2 4 2]  ))

%!test
%! % empty vectors
%! v = sym(1);
%! a = [v []];
%! assert (isequal (a, v))
%! a = [[] v []];
%! assert (isequal (a, v))
%! a = [v [] []];
%! assert (isequal (a, v))

%!test
%! % more empty vectors
%! v = [sym(1) sym(2)];
%! q = sym(ones(1, 0));
%! assert (isequal ([v q], v))

%!error <ShapeError>
%! v = [sym(1) sym(2)];
%! q = sym(ones(3, 0));
%! w = horzcat(v, q);

%!error <ShapeError>
%! z30 = sym (zeros (3, 0));
%! z40 = sym (zeros (4, 0));
%! % Note Issue #1238: unclear error message:
%! % [z30 z40];
%! % but this gives the ShapeError
%! horzcat(z30, z40);

%!test
%! % special case for the 0x0 empty: no error
%! z00 = sym (zeros (0, 0));
%! z30 = sym (zeros (3, 0));
%! [z00 z30];

%!test
%! % issue #700
%! A = sym ([1 2]);
%! B = simplify (A);
%! assert (isequal ([B A], [A B]))

%!test
%! % issue #1236, correct empty sizes
%! syms x
%! z00 = sym (zeros (0, 0));
%! z30 = sym (zeros (3, 0));
%! z03 = sym (zeros (0, 3));
%! z04 = sym (zeros (0, 4));
%! assert (size ([z00 z00]), [0 0])
%! assert (size ([z00 z03]), [0 3])
%! assert (size ([z03 z03]), [0 6])
%! assert (size ([z03 z04]), [0 7])
%! assert (size ([z03 z00 z04]), [0 7])
%! assert (size ([z30 z30]), [3 0])
%! assert (size ([z30 z30 z30]), [3 0])
