%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @defmethod @@sym columns (@var{x})
%% Return the number of columns in a symbolic array.
%%
%% Example:
%% @example
%% @group
%% A = [1 2 sym(pi); 4 5 2*sym(pi)];
%% m = columns (A)
%%   @result{} m =  3
%% @end group
%% @end example
%%
%% @seealso{@@sym/rows, @@sym/size, @@sym/length, @@sym/numel}
%% @end defmethod


function n = columns(x)

  n = size(x, 2);

end


%!test
%! a = sym([1 2 3]);
%! assert (columns(a) == 3)

%!test
%! a = sym([1; 2]);
%! assert (columns(a) == 1)
