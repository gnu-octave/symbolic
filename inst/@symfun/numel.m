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
%% @defmethod @@symfun numel (@var{f})
%% Number of elements in a symfun.
%%
%% This behaves differently than for @@sym:
%% @example
%% @group
%% syms x y
%% f(x, y) = [1 x; y 2];
%%
%% numel(f)
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/numel}
%% @end defmethod

function n = numel(f)

  % see issue #107, #109
  n = 1;

end


%!test
%! syms x
%! f(x) = x^2;
%! assert(numel(f)==1)

%!test
%! syms x
%! f(x) = [1 x];
%! assert(numel(f)==1)
