%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@symfun argnames (@var{f})
%% Return the independent variables in a symfun.
%%
%% The counterpart of @code{argname} is @code{formula}:
%% @code{argname} for the independent
%% variables and @code{formula} for the dependent expression.
%%
%% Examples:
%% @example
%% @group
%% syms x y
%% f(x, y) = x^2;
%% argnames(f)
%%   @result{} (sym) [x  y]  (1×2 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@symfun/formula, @@symfun/symvar, findsymbols}
%% @end defmethod


function vars = argnames(F)

  vars = [F.vars{:}];

end


%!test
%! % basic test
%! syms f(x)
%! assert (isequal (argnames (f), x))

%!test
%! % Multiple variables, abstract symfun
%! syms f(t, x, y)
%! assert (isequal (argnames (f), [t x y]))

%!test
%! % Concrete symfun
%! syms x y z t
%! f(t, x, y) = x + y + z;
%! assert (isequal (argnames (f), [t x y]))
