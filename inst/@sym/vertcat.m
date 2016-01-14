%% Copyright (C) 2014, 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z} =} vertcat (@var{x}, @var{y}, @dots{})
%% Vertically concatentate symbolic arrays.
%%
%% @seealso{horzcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = vertcat(varargin)

  % special case for 0x0 but other empties should be checked for
  % compatibilty
  cmd = {
          '_proc = []'
          'for i in _ins:'
          '    if i.is_Matrix:'
          '        if i.shape == (0, 0):'
          '            pass'
          '        else:'
          '            _proc.append(i)'
          '    else:'
          '        _proc.append(sp.Matrix([[i]]))'
          'return sp.Matrix.vstack(*_proc),'
          };

  varargin = sym(varargin);
  h = python_cmd (cmd, varargin{:});

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
%! % FIXME: clean-up when we drop 0.7.5 support (Issue #164)
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=75)
%!   disp('skipping: test passes on sympy >= 0.7.6')
%!   error('ShapeError')   % pass the test with correct error
%! else
%!   v = [sym(1) sym(2)];
%!   q = sym(ones(0, 3));
%!   w = [v; q];
%! end

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
