%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod  @@sym hypot (@var{x}, @var{y})
%% @defmethodx @@sym hypot (@var{x}, @var{y}, @var{z}, @dots{})
%% Return hypoteneuse (distance) from symbolic expressions.
%%
%% Example of computing distance:
%% @example
%% @group
%% syms x y real
%% syms z
%% hypot (x, y, z)
%%   @result{} (sym)
%%          ________________
%%         ╱  2    2      2
%%       ╲╱  x  + y  + │z│
%% @end group
%% @end example
%%
%% Another example involving complex numbers:
%% @example
%% @group
%% hypot (sym([12 2]), [3+4i 1+2i])
%%   @result{} (sym) [13  3]  (1×2 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/atan2}
%% @end defmethod

function h = hypot(varargin)

  % two inputs:
  %h = sqrt(abs(sym(x)).^2 + abs(sym(y)).^2);

  two = sym(2);
  L = cellfun(@(x) power(abs(sym(x)), two), varargin, 'UniformOutput', false);
  s = L{1};
  for i=2:length(L);
    s = s + L{i};
  end
  h = sqrt(s);

end


%!assert (isequal (hypot (sym(3), 4), sym(5)))

%!test
%! % compare to @double (note Matlab hypot only takes 2 inputs)
%! A = hypot (hypot ([1 2 3], [4 5 6]), [7 8 9]);
%! B = double (hypot (sym([1 2 3]), [4 5 6], [7 8 9]));
%! assert (A, B, -eps)

%!test
%! % compare to @double, with complex
%! A = hypot ([1+2i 3+4i], [1 3+1i]);
%! B = double (hypot (sym([1+2i 3+4i]), [1 3+1i]));
%! assert (A, B, -eps)

%!test
%! % matrices
%! x = sym([1 -2; 0 3]);
%! y = sym([0 0; 8 4]);
%! A = hypot (x, y);
%! B = sym([1 2; 8 5]);
%! assert (isequal (A, B))
