%% Copyright (C) 2016 Lagu
%% Copyright (C) 2017, 2019 Colin B. Macdonald
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
%% @defmethod @@sym eye (@var{n})
%% @defmethodx @@sym eye (@var{n}, @var{m})
%% Return an identity matrix.
%%
%% Example:
%% @example
%% @group
%% y = eye (sym(3))
%%   @result{} y = (sym 3×3 matrix)
%%       ⎡1  0  0⎤
%%       ⎢       ⎥
%%       ⎢0  1  0⎥
%%       ⎢       ⎥
%%       ⎣0  0  1⎦
%% @end group
%% @end example
%%
%% @seealso{eye, @@sym/zeros, @@sym/ones}
%% @end defmethod


function y = eye(varargin)

  % partial workaround for issue #13: delete when/if fixed properly
  if ((isa (varargin{nargin}, 'char')) && (strcmp (varargin{nargin}, 'sym')))
    varargin = varargin(1:(nargin-1));
  end

  if (isa (varargin{end}, 'char'))
    varargin = cell2nosyms (varargin);
    y = eye (varargin{:});
    return
  end

  for i = 1:length(varargin)
    varargin{i} = sym(varargin{i});
  end

  cmd = { 'if len(_ins) == 1:'
          '    n, = _ins'
          '    try:'
          '        n, m = iter(n)'
          '    except TypeError:'
          '        n, m = n, n'
          'else:'
          '    n, m = _ins'
          'if n == m:'
          '    return eye(n)'
          'return eye(max(n,m))[0:n,0:m]' };
  y = pycall_sympy__ (cmd, varargin{:});

end


%!test
%! y = eye(sym(2));
%! x = [1 0; 0 1];
%! assert( isequal( y, sym(x)))

%!test
%! y = eye(sym(2), 1);
%! x = [1; 0];
%! assert( isequal( y, sym(x)))

%!test
%! y = eye(sym(1), 2);
%! x = [1 0];
%! assert( isequal( y, sym(x)))

%!test
%! y = eye (sym([2 3]));
%! x = sym (eye ([2 3]));
%! assert (isequal (y, x))

%% Check types:
%!assert( isa( eye(sym(2), 'double'), 'double'))
%!assert( isa( eye(3, sym(3), 'single') , 'single'))
%!assert( isa( eye(3, sym(3)), 'sym'))
%!assert( isa( eye(3, sym(3), 'sym'), 'sym'))

%!xtest
%! % Issue #13
%! assert( isa( eye(3, 3, 'sym'), 'sym'))
