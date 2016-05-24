%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod @@sym matlabFunction (@var{f})
%% Convert symbolic expression into a standard function.
%%
%% This is a synonym of @code{function_handle}.  For further
%% documentation, @pxref{@@sym/function_handle}
%%
%% @seealso{@@sym/function_handle}
%%
%% @end defmethod


function f = matlabFunction(varargin)

  f = function_handle(varargin{:});

end


%!test
%! % autodetect inputs
%! syms x y
%! s = warning('off', 'OctSymPy:function_handle:nocodegen');
%! h = matlabFunction(2*x*y, x+y);
%! warning(s)
%! [t1, t2] = h(3,5);
%! assert(t1 == 30 && t2 == 8)
