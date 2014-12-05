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

  % special case for 0x0 but other empties should be checked for
  % compatibilty
  cmd = { '_proc = []'
          'for i in _ins:'
          '    if i.is_Matrix:'
          '        if i.shape == (0, 0):'
          '            pass'
          '        else:'
          '            _proc.append(i)'
          '    else:'
          '        _proc.append(sp.Matrix([[i]]))'
          'failed = False'
          'M = "whatev"'
          'try:'
          '    M = sp.Matrix.hstack(*_proc)'
          'except ShapeError:'
          '    failed = True'
          'return (failed, M)' };

  varargin = sym(varargin);
  [flag, h] = python_cmd (cmd, varargin{:});

  if (flag)
    error('horzcat: ShapeError: incompatible sizes concatenated')
  end

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

%!#error <ShapeError>
%! % FIXME: re-introduce when we drop 0.7.5 support (Issue #164)
%! % (or if Octave gains an "xerror" test)
%! v = [sym(1) sym(2)];
%! q = sym(ones(3, 0));
%! w = [v q];
