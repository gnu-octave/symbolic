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
%% @defmethod @@sym argnames (@var{f})
%% Return the independent variables in a symfun.
%%
%% For a @@sym, this always returns the empty sym, but
%% subclasses like @@symfun do something more interesting.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% f = 2*x*y;
%% argnames(f)
%%   @result{} (sym) []  (empty 0×0 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@symfun/argnames, symvar, findsym, findsymbols}
%% @end defmethod


function vars = argnames(F)

  vars = sym([]);

end


%!test
%! % basic tests
%! syms x
%! f = 2*x;
%! assert (isempty (argnames(x)))
%! assert (isempty (argnames(f)))
