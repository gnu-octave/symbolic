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
%% @defmethod @@sym rhs (@var{f})
%% Right-hand side of symbolic expression.
%%
%% Example:
%% @example
%% @group
%% syms x
%% eqn = 5*x <= 3*x + 6
%%   @result{} eqn = (sym) 5⋅x ≤ 3⋅x + 6
%% rhs(eqn)
%%   @result{} ans = (sym) 3⋅x + 6
%% @end group
%% @end example
%%
%% Gives an error if any of the symbolic objects have no right-hand side.
%%
%% @seealso{@@sym/lhs, @@sym/children, @@sym/formula, @@sym/argnames}
%% @end defmethod


function R = rhs(f)

  R = elementwise_op ('lambda a: a.rhs', f);

end


%% most tests are in lhs
%!test
%! syms x
%! f = x + 1 == 2*x;
%! assert (isequal (rhs(f), 2*x))

%!error <AttributeError>
%! syms x
%! rhs(x)
