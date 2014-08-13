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
%% @deftypefn  {Function File} {@var{z} =} conj (@var{x})
%% Symbolic conj function.
%%
%% @seealso{ctranspose, real, imag}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = conj(x)

  # can just use .conjugate on matrix but avoids S.true err
  sf = [ 'def sf(x):\n' ...
         '    if x in (S.true, S.false):\n' ...
         '        return x\n' ...
         '    return x.conjugate()' ];

  z = uniop_helper(x, sf);

end


%!test
%! a = sym(6);
%! b = sym(5i);
%! assert (isequal (conj(a), a))
%! assert (isequal (conj(b), -b))
%! assert (isequal (conj(a+b), a-b))

%!test
%! syms x
%! assert (isequal (conj(conj(x)), x))

%!test
%! syms x real
%! assert (isequal (conj(x), x))

%!test
%! % array
%! syms x
%! A = [x 6+1i; sym(1) x+2i];
%! B = [conj(x) 6-1i; sym(1) conj(x)-2i];
%! assert (isequal (conj(A), B))

%!test
%! % true/false
%! t = sym(true);
%! f = sym(false);
%! assert (isequal ( conj(t), t))
%! assert (isequal ( conj(f), f))
