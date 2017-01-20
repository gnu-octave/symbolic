%% Copyright (C) 2017 Abhinav Tripathi
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
%% @defmethod  @@sym isequal (@var{f}, @var{g})
%% @defmethodx @@sym isequal (@var{f}, @var{g}, @dots{})
%% Test if contents of two or more symfuns are equal.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f(x) = x;
%% isequal (f(x), x)
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/isequal}
%% @end defmethod

function t = isequal (x, y, varargin)

  t = isequal@sym (x, y, varargin{:});

end


%!test
%! syms x;
%! f(x) = x^2;
%! g(x) = x^2;
%! assert (isequal (f(x), g(x)))
%! assert (isequal (f(x), x^2))

%!test
%! syms x y;
%! f(x) = x^2;
%! g(y) = y^2;
%! assert (isequal (f(x), g(x)))
