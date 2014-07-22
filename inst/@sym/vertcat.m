%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z} =} vertcat (@var{x}, @var{y}, ...)
%% Vertically concatentate symbolic arrays.
%%
%% @seealso{horzcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = vertcat(varargin)

  cmd = [ '_proc = []\n'  ...
          'for i in _ins:\n'  ...
          '    if i.is_Matrix:\n'  ...
          '        _proc.append(i)\n'  ...
          '    else:\n'  ...
          '        _proc.append(sp.Matrix([[i]]))\n'  ...
          'M = sp.Matrix.vstack(*_proc)\n'  ...
          'return (M,)' ];

  varargin = sym(varargin);
  h = python_cmd (cmd, varargin{:});

end



%!shared x
%! syms x

%!test
%! % basic
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
%! % Octave 3.6 bug: should pass on 3.8.1 and matlab
%! a = [sym(1) 2];
%! assert (isequal ( [a; [3 4]] , [1 2; 3 4]  ))
%! assert (isequal ( [a; sym(3) 4] , [1 2; 3 4]  ))
%! % more examples
%! [x [x x]; x x x];
%! [[x x] x; x x x];
%! [[x x] x; [x x] x];
%! [x x x; [x x] x];
