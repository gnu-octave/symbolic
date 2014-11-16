%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{L} =} lhs (@var{f})
%% Left-hand side of symbolic expression.
%%
%% FIXME: could be much smarter: e.g., error if not eq, ineq.
%%
%% @seealso{rhs, children}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function L = lhs(f)

  c = children(f);
  %L = c(1)  % f$@k issue #17
  idx.type = '()';
  idx.subs = {1};
  L = subsref(c, idx);

end


%!test
%! syms x y
%! f = x + 1 == 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))

%!test
%! syms x y
%! f = x + 1 < 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))

%!test
%! syms x y
%! f = x + 1 >= 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))
