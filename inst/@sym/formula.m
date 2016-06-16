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
%% @defmethod @@sym formula (@var{f})
%% Return a symbolic expression for this object.
%%
%% For a @@sym, this simply returns the sym itself.  Subclasses
%% such as @@symfun may do more interesting things.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f = 2*x;
%% formula(f)
%%   @result{} ans = (sym) 2⋅x
%% @end group
%% @end example
%%
%% @seealso{@@symfun/formula, argnames, @@sym/argnames}
%% @end defmethod


function g = formula(f)
  g = f;
end


%!test
%! syms x
%! assert (isequal (formula(x), x))
%! assert (isequal (formula(2*x), 2*x))
