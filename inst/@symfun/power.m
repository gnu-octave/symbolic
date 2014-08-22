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
%% @deftypefn  {Function File}  {@var{h} =} power (@var{f}, @var{g})
%% Symbolic function componentwise exponentiation (dot^).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = power(f, g)
  [vars, s1, s2] = helper_symfun_binops(f, g);
  h = symfun(s1 .^ s2, vars);
end


%!test
%! syms x
%! f(x) = 2*x;
%! h = f.^f;
%! assert( isa(h, 'symfun'))
%! assert( isequal (h.sym, (2*x)^(2*x)))

%!test
%! syms x
%! f(x) = [x 2*x];
%! h = f.^[x 3];
%! assert( isa(h, 'symfun'))
%! assert( isequal (h.sym, [x^x 8*x^3]))

