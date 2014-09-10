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
%% @deftypefn  {Function File} {@var{z} =} horzcat (@var{x}, @var{y}, ...)
%% Horizontally concatentate symbolic arrays.
%%
%% @seealso{vertcat}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = horzcat(varargin)

  cmd = { '_proc = []'  ...
          'for i in _ins:'  ...
          '    if i.is_Matrix:'  ...
          '        _proc.append(i)'  ...
          '    else:'  ...
          '        _proc.append(sp.Matrix([[i]]))'  ...
          'M = sp.Matrix.hstack(*_proc)'  ...
          'return M,' };

  varargin = sym(varargin);
  h = python_cmd (cmd, varargin{:});

end


%!shared x
%! syms x

%!test
%! % basic
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

