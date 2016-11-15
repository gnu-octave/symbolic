%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym zeros (@var{n})
%% @defmethodx @@sym zeros (@var{n}, @var{m})
%% Return a matrix whose elements are all 0.
%%
%% Example:
%% @example
%% @group
%% y = zeros (sym(3))
%%   @result{} y = (sym 3×3 matrix)
%%       ⎡0  0  0⎤
%%       ⎢       ⎥
%%       ⎢0  0  0⎥
%%       ⎢       ⎥
%%       ⎣0  0  0⎦
%% @end group
%% @end example
%%
%% @seealso{zeros, @@sym/ones, @@sym/eye}
%% @end defmethod

%% Reference: http://docs.sympy.org/dev/modules/matrices/matrices.html


function y = zeros(varargin)

  % partial workaround for issue #13: delete when/if fixed properly
  if (strcmp (varargin{nargin}, 'sym'))
    nargin = nargin - 1;
    varargin = varargin(1:nargin);
  end

  if (isa (varargin{nargin}, 'char'))
    y = zeros (cell2nosyms (varargin){:});
    return
  end

  y = python_cmd ('return zeros(*_ins)', sym(varargin){:});

end


%!test
%! y = zeros(sym(2));
%! x = [0 0; 0 0];
%! assert( isequal( y, sym(x)))

%!test
%! y = zeros(sym(2), 1);
%! x = [0; 0];
%! assert( isequal( y, sym(x)))

%!test
%! y = zeros(sym(1), 2);
%! x = [0 0];
%! assert( isequal( y, sym(x)))

%% Check types:
%!assert( isa( zeros(sym(2), 'double'), 'double'))
%!assert( isa( zeros(3, sym(3), 'single') , 'single'))
%!assert( isa( zeros(3, sym(3)), 'sym'))
%!assert( isa( zeros(3, sym(3), 'sym'), 'sym'))

%!xtest
%! % Issue #13
%! assert( isa( zeros(3, 3, 'sym'), 'sym'))
