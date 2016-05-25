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
%% @defmethod @@sym numel (@var{x})
%% Return number of elements in symbolic array.
%%
%% Example:
%% @example
%% @group
%% syms x
%% A = [1 2 x; x 3 4];
%% numel(A)
%%   @result{} 6
%% @end group
%% @end example
%%
%% @seealso{@@sym/length, @@sym/size}
%% @end defmethod

function n = numel(x)

  %disp('numel call')
  d = size(x);
  n = prod(d);

end


%!test
%! a = sym([1 2 3]);
%! assert(numel(a) == 3);

%!test
%! % 2D array
%! a = sym([1 2 3; 4 5 6]);
%! assert(numel(a) == 6);

%!test
%! % empty
%! a = sym([]);
%! assert(numel(a) == 0);
