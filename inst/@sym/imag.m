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
%% @deftypefn  {Function File} {@var{y} =} imag (@var{z})
%% Imaginary part of a symbolic expression.
%%
%% Examples:
%% @example
%% @group
%% syms z
%% imag(z)
%%   @result{} ans = (sym)
%%          ⎛    _⎞
%%       -ⅈ⋅⎝z - z⎠
%%       ───────────
%%            2
%%
%% @end group
%% @group
%% syms x real
%% imag(x)
%%   @result{} ans = (sym) 0
%% imag(1i*x)
%%   @result{} ans = (sym) x
%%
%% @end group
%% @group
%% imag([x  sym(pi) + 6i  7  3i])
%%   @result{} ans = (sym) [0  6  0  3]  (1×4 matrix)
%% @end group
%% @end example
%% @seealso{@@sym/real, @@sym/conj, @@sym/ctranspose}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function y = imag(z)

  y = (z - conj(z))/2i;

end


%!assert(isequal(imag(sym(4)+3i),3))

%!test
%! syms x y real
%! z = x + 1i*y;
%! assert(isequal(imag(z),y))

%!test
%! syms x y real
%! Z = [4  x + 1i*y; 1i*y 4+3i];
%! assert(isequal(imag(Z),[0 y; y 3]))
