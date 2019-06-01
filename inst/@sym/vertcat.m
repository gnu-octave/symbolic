%% Copyright (C) 2014-2017, 2019 Colin B. Macdonald
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
%% Vertically concatentate symbolic arrays.
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
  cmd = {
          '_proc = []'
          'for i in _ins:'
          '    if i is None or not i.is_Matrix:'
          '        _proc.append(sp.Matrix([[i]]))'
          '    else:'
          '        if i.shape == (0, 0):'
          '            pass'
          '        else:'
          '            _proc.append(i)'
          'return sp.MatrixBase.vstack(*_proc),'
          };

  for i = 1:nargin
    varargin{i} = sym(varargin{i});
  end
  h = pycall_sympy__ (cmd, varargin{:});

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

%!xtest
%! % FIXME: is this Octave bug? worth worrying about
%! syms x
%! a = [x; [] []];
%! assert (isequal (a, x))

%!test
%! % more empty vectors
%! v = [sym(1) sym(2)];
%! q = sym(ones(0, 2));
%! assert (isequal ([v; q], v))

%!error <ShapeError>
%! v = [sym(1) sym(2)];
%! q = sym(ones(0, 3));
%! w = vertcat(v, q);

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
