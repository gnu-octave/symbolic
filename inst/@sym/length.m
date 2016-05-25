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
%% @defmethod @@sym length (@var{x})
%% Length of a symbolic vector.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = [1 2 x; x 3 4];
%% length(A)
%%   @result{} 3
%% @end group
%% @end example
%%
%% As usual, be careful with this and matrices: you may want
%% @code{numel} instead.
%%
%% @seealso{@@sym/numel, @@sym/size}
%% @end defmethod

function n = length(x)

  d = size(x);
  n = max(d);

end


%!test
%! a = sym([1 2 3]);
%! assert(length(a) == 3);

%!test
%! % 2D array
%! a = sym([1 2 3; 4 5 6]);
%! assert(length(a) == 3);

%!test
%! % empty
%! a = sym([]);
%! assert(length(a) == 0);
