%% Copyright (C) 2016, Abhinav Tripathi
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
%% @deftypefn  {Function File} {@var{s} =} chebyshevT (@var{n}, @var{x})
%% Find the nth symbolic Chebyshev polynomial of the first kind.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% chebyshevT(1, x)
%%   @result{} (sym) x
%% chebyshevT(2, x)
%%   @result{} (sym)
%%          2
%%       2⋅x  - 1
%% syms n
%% chebyshevT(n, x)
%%   @result{} (sym) chebyshevt(n, x)
%% @end group
%% @end example
%%
%% @seealso{chebyshevU}
%% @end deftypefn

%% Author: Abhinav Tripathi
%% Keywords: symbolic

function y = chebyshevT(n,x)
  op = { 'def _op(n, x):'
        ['    return chebyshevt(int(n), x)'] };

  y = binop_helper(n, x, op);
end

%!shared x
%! syms x

%!assert(isequal(chebyshevT(0, x), sym(1)))
%!assert(isequal(chebyshevT(1, x), x))
%!assert(isequal(chebyshevT(2, x), 2*x*x - 1))
%!assert(isequal(chebyshevU([0 1 2], x), [sym(1) 2*x (4*x*x-1)]))

