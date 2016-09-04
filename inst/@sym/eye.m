%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym eye (@var{x})
%% @defmethod @@sym eye (@var{x}, @var{y})
%% @defmethod @@sym eye (@var{x}, @var{y}, @var{class})
%% Return an identity matrix.
%%
%% Example:
%% @example
%% @group
%% y = eye (sym(3))
%%   @result{} y = (sym 3×3 matrix)
%%  ⎡1  0  0⎤
%%  ⎢       ⎥
%%  ⎢0  1  0⎥
%%  ⎢       ⎥
%%  ⎣0  0  1⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/zeros, @@sym/ones}
%% @end defmethod

%% Source: http://docs.sympy.org/dev/modules/matrices/matrices.html

function y = eye(varargin)

  if (nargin >= 2)
    for i=1:size(varargin)(2)
      if (ischar(varargin{i}))
        y = sym(eye(cell2nosyms(varargin){:}));
        return;
      end
    end
  end

  if (nargin > 1)
    y = sym(eye(cell2nosyms(varargin){:}));
    return;
  end

  %% Be careful, varargin should be always sym.
  y = python_cmd('return eye(*_ins),', varargin{:});
end

%!test
%! y = eye(sym(2));
%! x = [1 0;0 1];
%! assert( isequal( y, sym(x)))

%!test
%! y = eye(sym(2), 1);
%! x = [1;0];
%! assert( isequal( y, sym(x)))

%!test
%! y = eye(sym(1), 2);
%! x = [1 0];
%! assert( isequal( y, sym(x)))
