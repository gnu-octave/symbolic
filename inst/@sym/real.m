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
%% @deftypefn  {Function File} {@var{x} =} real (@var{z})
%% Real part of a symbolic expression.
%%
%% @seealso{imag, conj, ctranspose}
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function x = real(z)

  x = (z + conj(z))/2;

end


%!assert(isequal(real(sym(4)+3i),4))

%!test
%! syms x y real
%! z = x + 1i*y;
%! assert(isequal(real(z),x))

%!test
%! syms x y real
%! Z = [4  x + 1i*y; x 4+3i];
%! assert(isequal(real(Z),[4 x; x 4]))
