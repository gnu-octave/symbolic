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
%% @defmethod @@sym ones (@var{n})
%% @defmethodx @@sym ones (@var{n}, @var{m})
%% Return a matrix whose elements are all 1.
%%
%% Example:
%% @example
%% @group
%% y = ones (sym(3))
%%   @result{} y = (sym 3×3 matrix)
%%       ⎡1  1  1⎤
%%       ⎢       ⎥
%%       ⎢1  1  1⎥
%%       ⎢       ⎥
%%       ⎣1  1  1⎦
%% @end group
%% @end example
%%
%% @seealso{ones, @@sym/zeros, @@sym/eye}
%% @end defmethod


function y = ones(varargin)

  % partial workaround for issue #13: delete when/if fixed properly
  if ((isa (varargin{nargin}, 'char')) && (strcmp (varargin{nargin}, 'sym')))
    varargin = varargin(1:(nargin-1));
  end

  if (isa (varargin{end}, 'char'))
    varargin = cell2nosyms (varargin);
    y = ones (varargin{:});
    return
  end

  for i = 1:length(varargin)
    varargin{i} = sym(varargin{i});
  end

  if (length (varargin) == 1 && ~isscalar (varargin{1}))
    y = pycall_sympy__ ('return ones(*_ins[0])', varargin{1});
  else
    y = pycall_sympy__ ('return ones(*_ins)', varargin{:});
  end

end


%!test
%! y = ones(sym(2));
%! x = [1 1; 1 1];
%! assert( isequal( y, sym(x)))

%!test
%! y = ones(sym(2), 1);
%! x = [1; 1];
%! assert( isequal( y, sym(x)))

%!test
%! y = ones(sym(1), 2);
%! x = [1 1];
%! assert( isequal( y, sym(x)))

%!test
%! y = ones (sym([2 3]));
%! x = sym (ones ([2 3]));
%! assert (isequal (y, x))

%% Check types:
%!assert( isa( ones(sym(2), 'double'), 'double'))
%!assert( isa( ones(3, sym(3), 'single') , 'single'))
%!assert( isa( ones(3, sym(3)), 'sym'))
%!assert( isa( ones(3, sym(3), 'sym'), 'sym'))

%!xtest
%! % Issue #13
%! assert( isa( ones(3, 3, 'sym'), 'sym'))
