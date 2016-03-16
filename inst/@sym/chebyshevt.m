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
%% @deftypefn  {Function File} {@var{s} =} chebyshevt (@var{x}, @var{n})
%% Find the chebyshev's first type nth polynomial in the variable x.
%%
%% Example:
%% @example
%% @group
%% >> syms x
%% >> g = chebyshevt(x, 1)
%%    @result{} g = x
%% >> g = chebyshevt(x, 2)
%%    @result{} g = 2x^2 - 1
%% @end group
%% @end example
%%
%% @seealso{chebyshevu}
%% @end deftypefn

%% Author: Abhinav Tripathi
%% Keywords: symbolic

function y = chebyshevt(x, n)
  cmd = { 'x, n = _ins'
          'return chebyshevt(int(n),x),' };
 
 y = python_cmd (cmd, x, n);
end

%!shared x
%! syms x

%!test
%! poly0 = chebyshevt(x, 0);
%! assert(isequal(poly0, sym(1)))

%!test
%! poly1 = chebyshevt(x, 1);
%! assert(isequal(poly1, x))

%!test
%! poly2 = chebyshevt(x, 2);
%! assert(isequal(poly2, 2*x*x - 1))
