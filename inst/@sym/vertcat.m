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
%% @defop  Method   @@sym {vertcat} {(@var{x}, @var{y}, @dots{})}
%% @defopx Operator @@sym {[@var{x}; @var{y}; @dots{}]} {}
%% Vertically concatenate symbolic arrays.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2])
%%   @result{} A = (sym) [1  2]  (1×2 matrix)
%% [A; A; 2*A]
%%   @result{} (sym 3×2 matrix)
%%       ⎡1  2⎤
%%       ⎢    ⎥
%%       ⎢1  2⎥
%%       ⎢    ⎥
%%       ⎣2  4⎦
%% @end group
%% @end example
%% @seealso{@@sym/horzcat, @@sym/cat}
%% @end defop


function h = vertcat(varargin)

  % special case for 0x0 but other empties should be checked for
  % compatibilty
  cmd = {'def is_matrix_or_array(x):'
         '    return isinstance(x, (MatrixBase, NDimArray))'
         'def number_of_columns(x):'
         '    return x.shape[1] if is_matrix_or_array(x) else 1'
         'def number_of_rows(x):'
         '    return x.shape[0] if is_matrix_or_array(x) else 1'
         'def all_equal(*ls):'
         '    return True if ls == [] else all(ls[0] == x for x in ls[1:])'
         'args = [x for x in _ins if x != zeros(0, 0)] # remove 0x0 matrices'
         'ncols = [number_of_columns(x) for x in args]'
         'nrows = [number_of_rows(x) for x in args]'
         'if not all_equal(*ncols):'
         '    msg = "vertcat: all inputs must have the same number of columns"'
         '    raise ShapeError(msg)'
         'ncol = 0 if not ncols else ncols[0]'
         'CCC = [flatten(x, levels=1) if is_matrix_or_array(x) else [x] for x in args]'
         'CC = flatten(CCC, levels=1)'
         'return _make_2d_sym(CC, shape=(sum(nrows), ncol))' };

  args = cellfun (@sym, varargin, 'UniformOutput', false);
  h = pycall_sympy__ (cmd, args{:});

end


%!test
%! % basic
%! syms x
%! A = [x; x];
%! B = vertcat(x, x);
%! C = vertcat(x, x, x);
%! assert (isa (A, 'sym'))
%! assert (isa (B, 'sym'))
%! assert (isa (C, 'sym'))
%! assert (isequal (size(A), [2 1]))
%! assert (isequal (size(B), [2 1]))
%! assert (isequal (size(C), [3 1]))

%!test
%! % basic, part 2
%! syms x
%! A = [x; 1];
%! B = [1; x];
%! C = [1; 2; x];
%! assert (isa (A, 'sym'))
%! assert (isa (B, 'sym'))
%! assert (isa (C, 'sym'))
%! assert (isequal (size(A), [2 1]))
%! assert (isequal (size(B), [2 1]))
%! assert (isequal (size(C), [3 1]))

%!test
%! % column vectors
%! a = [sym(1); 2];
%! b = [sym(3); 4];
%! assert (isequal ( [a;b] , [1; 2; 3; 4]  ))
%! assert (isequal ( [a;b;a] , [1; 2; 3; 4; 1; 2]  ))

%!test
%! % row vectors
%! a = [sym(1) 2];
%! b = [sym(3) 4];
%! assert (isequal ( [a;b] , [1 2; 3 4]  ))
%! assert (isequal ( [a;b;a] , [1 2; 3 4; 1 2]  ))

%!test
%! % row vector, other row
%! a = [sym(1) 2];
%! assert (isequal ( [a; [sym(3) 4]] , [1 2; 3 4]  ))

%!test
%! % empty vectors
%! v = [sym(1) sym(2)];
%! a = [v; []];
%! assert (isequal (a, v))
%! a = [[]; v; []];
%! assert (isequal (a, v))
%! a = [v; []; []];
%! assert (isequal (a, v))

%!test
%! % more empty vectors
%! v = [sym(1) sym(2)];
%! q = sym(ones(0, 2));
%! assert (isequal ([v; q], v))

%!error <ShapeError>
%! v = [sym(1) sym(2)];
%! q = sym(ones(0, 3));
%! w = vertcat(v, q);

%!error <ShapeError>
%! z03 = sym (zeros (0, 3));
%! z04 = sym (zeros (0, 4));
%! % Note Issue #1238: unclear error message:
%! % [z03; z04];
%! % but this gives the ShapeError
%! vertcat(z03, z04);

%!test
%! % Octave 3.6 bug: should pass on 3.8.1 and matlab
%! a = [sym(1) 2];
%! assert (isequal ( [a; [3 4]] , [1 2; 3 4]  ))
%! assert (isequal ( [a; sym(3) 4] , [1 2; 3 4]  ))
%! % more examples
%! syms x
%! [x [x x]; x x x];
%! [[x x] x; x x x];
%! [[x x] x; [x x] x];
%! [x x x; [x x] x];

%!test
%! % issue #700
%! A = sym ([1 2]);
%! B = simplify (A);
%! assert (isequal ([B; A], [A; B]))

%!test
%! % issue #1236, correct empty sizes
%! syms x
%! z00 = sym (zeros (0, 0));
%! z30 = sym (zeros (3, 0));
%! z40 = sym (zeros (4, 0));
%! z03 = sym (zeros (0, 3));
%! assert (size ([z00; z00]), [0 0])
%! assert (size ([z00; z30]), [3 0])
%! assert (size ([z30; z30]), [6 0])
%! assert (size ([z30; z40]), [7 0])
%! assert (size ([z30; z00; z30]), [6 0])
%! assert (size ([z03; z03]), [0 3])
%! assert (size ([z03; z03; z03]), [0 3])

%!test
%! % special case for the 0x0 empty: no error
%! z00 = sym (zeros (0, 0));
%! z03 = sym (zeros (0, 3));
%! [z00; z03];

%!test
%! syms x
%! a = [x; sym([]) []];
%! assert (isequal (a, x))
